#!/bin/bash

# Disable bash history substitution
set +H

source functions.sh

handleSignal()
{
    handleSignal_signalCode=$1
    log "Kill signal $handleSignal_signalCode received"
    if [ -n "$pid" ]; then # If java process found
        stop=true
        killProcess $pid
    else
        log "________________________________________ CONTAINER KILLED __________________________________________"
        exit $((128 + $handleSignal_signalCode))
    fi
}
trap "handleSignal 1" SIGHUP
trap "handleSignal 2" SIGINT
trap "handleSignal 15" SIGTERM

log "________________________________________ CONTAINER STARTED _________________________________________"

# Detect OS (ubuntu or alpine)
OS=$(cat /etc/os-release | grep "ID=" | sed -En "s/^ID=(.+)$/\1/p")
OS_prettyName=$(cat /etc/os-release | grep "PRETTY_NAME=" | sed -En "s/^PRETTY_NAME=\"(.+)\"$/\1/p")
log "OS = \"$OS_prettyName\""

# JAVA version

if [ "$OS" = "alpine" ]; then
    JAVA_VERSION=$(apk -vv info | grep "openjdk.*jre")
else
    JAVA_VERSION=$(dpkg -l | grep "openjdk.*jre")
fi
log "JAVA version = \"$JAVA_VERSION\""

# Check environment variables

log "JAVA options = \"$JAVA_OPTIONS\""

if [ -z "$JD_EMAIL" ]; then
    log "WARNING" "Environment variable 'JD_EMAIL' is not set"
fi

if [ -z "$JD_PASSWORD" ]; then
    log "WARNING" "Environment variable 'JD_PASSWORD' is not set"
fi

if [ -z "$JD_DEVICENAME" ]; then
    JD_DEVICENAME=$(uname -n)
fi

JDownloaderJarFile="JDownloader.jar"
JDownloaderJarUrl="installer.jdownloader.org/$JDownloaderJarFile"
JDownloaderPidFile="JDownloader.pid"

# Check JDownloader application integrity
unzip -t $JDownloaderJarFile &> /dev/null
unzipExitCode=$?

if [ "$unzipExitCode" -ne 0 ]; then
    log "Delete any existing JDownloader installation files"
    rm -f -r $JDownloaderJarFile Core.jar ./tmp ./update
fi

# If the JDownloader jar file does not exist
if [ ! -f "./$JDownloaderJarFile" ]; then
    log "Download https://$JDownloaderJarUrl"

    curl -s -O "https://$JDownloaderJarUrl"
    curlExitCode=$?

    if [ $curlExitCode -ne 0 ]; then
        log "$JDownloaderJarFile download failed: curl exited with code '$curlExitCode'"
        
        # If https download failed, we try the http link
        if [ ! -f "./$JDownloaderJarFile" ]; then
            log "Download http://$JDownloaderJarUrl"

            curl -s -O "http://$JDownloaderJarUrl"
            curlExitCode=$?

            if [ $curlExitCode -ne 0 ]; then
                fatal "$JDownloaderJarFile download failed: curl exited with code '$curlExitCode'"
            fi
        fi
    fi
fi

./setup.sh "$JD_EMAIL" "$JD_PASSWORD" "$JD_DEVICENAME"
setupShExitCode=$?

if [ $setupShExitCode -ne 0 ]; then
    fatal "setup.sh exited with code '$setupShExitCode'"
fi

unset JD_EMAIL
unset JD_PASSWORD

# Request eventscripter install
mkdir -p ./update/versioninfo/JD
echo '["eventscripter"]' > ./update/versioninfo/JD/extensions.requestedinstalls.json

# Put setup autoupdate script
autoUpdateEventScripterSettings="org.jdownloader.extensions.eventscripter.EventScripterExtension.json"
autoUpdateEventScripterScript="org.jdownloader.extensions.eventscripter.EventScripterExtension.scripts.json"
cp "./$autoUpdateEventScripterSettings" "./cfg/$autoUpdateEventScripterSettings"
cp "./$autoUpdateEventScripterScript" "./cfg/$autoUpdateEventScripterScript"

log "Start JDownloader"

# Create logs dir if needed
if [ ! -d "/jdownloader/logs/" ]; then
    mkdir -p "/jdownloader/logs/"
fi

# Start JDownloader in a background process
java $JAVA_OPTIONS -Djava.awt.headless=true -jar $JDownloaderJarFile &> "$LOG_FILE" &
pid=$!
lastPid=""

while [ -n "$pid" ]; do
    jdrev=$(cat update/versioninfo/JD/rev 2> /dev/null)
    jdurev=$(cat update/versioninfo/JDU/rev 2> /dev/null)

    log "JDownloader ${lastPid:+re}started (${jdurev:+JDU-REV=$jdurev }${jdrev:+JD-REV=$jdrev }PID=$pid)"

    if [[ $stop ]]; then
        killProcess $pid
    fi

    waitProcess $pid
    exitCode=$?

    lastPid="$pid"

    # Get the written JDownloader PID or another running Java PID
    pid=$(pgrep -L -F $JDownloaderPidFile 2> /dev/null || pgrep -o java)
done

log "JDownloader stopped"

log "________________________________________ CONTAINER STOPPED _________________________________________"

exit $exitCode
