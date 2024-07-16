#!/bin/bash

# Disable bash history substitution
set +H

source functions.sh

trap "handleSignal 1" SIGHUP
trap "handleSignal 2" SIGINT
trap "handleSignal 15" SIGTERM

group "CONTAINER STARTED"

# Detect OS (ubuntu or alpine)

OS=$(cat /etc/os-release | grep "ID=" | sed -En "s/^ID=(.+)$/\1/p")
OS_prettyName=$(cat /etc/os-release | grep "PRETTY_NAME=" | sed -En "s/^PRETTY_NAME=\"(.+)\"$/\1/p")
log "OS = \"$OS_prettyName\""

# JAVA

if [ "$OS" = "ubuntu" ]; then
    JAVA_VERSION="$(dpkg -l | grep "openjdk.*jre" | cut -d" " -f3,4)"
else
    JAVA_VERSION="$(apk -vv info | grep "openjdk.*jre" | cut -d" " -f1)"
fi

log "JAVA version = \"$JAVA_VERSION\""

if [ -n "$JAVA_OPTIONS" ]; then
    log "JAVA options = \"$JAVA_OPTIONS\""
fi

# Retrieve JD_EMAIL

if [ -f "/run/secrets/JD_EMAIL" ]; then
    JD_EMAIL=$(cat /run/secrets/JD_EMAIL)
elif [ -z "$JD_EMAIL" ]; then
    log "WARNING" "Secret \"JD_EMAIL\" not found, use environment variable"
else
    log "WARNING" "\"JD_EMAIL\" not found"
fi

# Retrieve JD_PASSWORD

if [ -f "/run/secrets/JD_PASSWORD" ]; then
    JD_PASSWORD=$(cat /run/secrets/JD_PASSWORD)
elif [ -z "$JD_PASSWORD" ]; then
    log "WARNING" "Secret \"JD_PASSWORD\" not found, use environment variable"
else
    log "WARNING" "\"JD_PASSWORD\" not found"
fi

# Rerieve JD_DEVICENAME

if [ -f "/run/secrets/JD_DEVICENAME" ]; then
    JD_DEVICENAME=$(cat /run/secrets/JD_DEVICENAME)
elif [ -z "$JD_DEVICENAME" ]; then
    JD_DEVICENAME=$(uname -n)
fi

# UMASK

if [ -n "$UMASK" ]; then
    log "Apply umask $UMASK"
    umask $UMASK
fi

JDownloaderJarFile="JDownloader.jar"
JDownloaderJarUrl="installer.jdownloader.org/$JDownloaderJarFile"

group "Check \"$JDownloaderJarFile\""

# Check JDownloader application integrity
unzip -t $JDownloaderJarFile &> /dev/null
unzipExitCode=$?
if [ "$unzipExitCode" -ne 0 ]; then
    log "Delete any existing JDownloader installation files"
    rm -f -r $JDownloaderJarFile Core.jar ./tmp ./update
fi

# If the JDownloader jar file does not exist
if [ ! -f "./$JDownloaderJarFile" ]; then
    downloadFile "https://$JDownloaderJarUrl" "$JDownloaderJarFile"
    downloadFileExitCode=$?
    if [ $downloadFileExitCode -ne 0 ]; then
        downloadFile "http://$JDownloaderJarUrl" "$JDownloaderJarFile"
        downloadFileExitCode=$?
        if [ $downloadFileExitCode -ne 0 ]; then
            fatal $downloadFileExitCode "Download JDownloader failed"
        fi
    fi
fi

groupEnd

group "Setup JDownloader"

# Create directory logs if applicable
if [ ! -d "./logs/" ]; then
    log "Create directory \"./logs/\""
    mkdir -p "./logs/"
fi

installFile "org.jdownloader.extensions.eventscripter.EventScripterExtension.json" "./cfg/"

installFile "org.jdownloader.extensions.eventscripter.EventScripterExtension.scripts.json" "./cfg/"

installFile "org.jdownloader.settings.GeneralSettings.json" "./cfg/"

installFile "org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json" "./cfg/"

installFile "extensions.requestedinstalls.json" "./update/versioninfo/JD/"

if [ -n "$JD_EMAIL" ]; then
    log "Set JDownloader email"
    replaceJsonValue "./cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json" "email" "$JD_EMAIL"
    exitCode=$?
    if [ $exitCode -ne 0 ]; then
        fatal $exitCode "Set JD email failed"
    fi
fi

if [ -n "$JD_PASSWORD" ]; then
    log "Set JDownloader password"
    replaceJsonValue "./cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json" "password" "$JD_PASSWORD"
    exitCode=$?
    if [ $exitCode -ne 0 ]; then
        fatal $exitCode "Set JD password failed"
    fi
fi

if [ -n "$JD_DEVICENAME" ]; then
    log "Set JDownloader devicename"
    replaceJsonValue "./cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json" "devicename" "$JD_DEVICENAME"
    exitCode=$?
    if [ $exitCode -ne 0 ]; then
        fatal $exitCode "Set JD device name failed"
    fi
fi

groupEnd

unset JD_EMAIL
unset JD_PASSWORD
unset JD_DEVICENAME

group "Start JDownloader"

# Start JDownloader in a background process
java $JAVA_OPTIONS -Djava.awt.headless=true -jar $JDownloaderJarFile &> "$LOG_FILE" &
pid=$!
lastPid=""
JDownloaderPidFile="JDownloader.pid"

while [ -n "$pid" ]; do
    jdrev=$(cat update/versioninfo/JD/rev 2> /dev/null)
    jdurev=$(cat update/versioninfo/JDU/rev 2> /dev/null)

    log "JDownloader ${lastPid:+re}started [PID=$pid]${jdurev:+ [JDU-REV=$jdurev]}${jdrev:+ [JD-REV=$jdrev]}"

    if [[ $stop ]]; then
        killProcess $pid
    fi

    waitProcess $pid
    exitCode=$?

    lastPid="$pid"

    # Get the written JDownloader PID or another running java PID
    pid=$(pgrep -L -F $JDownloaderPidFile 2> /dev/null || pgrep -o java)
done

log "JDownloader stopped"

groupEnd

groupEnd

log "CONTAINER STOPPED"

exit $exitCode
