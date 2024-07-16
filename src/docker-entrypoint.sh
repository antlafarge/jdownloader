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

group "Setup JDownloader"

cfgDir="./cfg/"

# If JDownloader cfg directory does not exist
if [ ! -d "$cfgDir" ]; then
    log "Create directory \"$cfgDir\""
    mkdir -p "$cfgDir"
fi

# Enable auto-update
autoUpdateEventScripterSettings="org.jdownloader.extensions.eventscripter.EventScripterExtension.json"
if [ ! -f "${cfgDir}${autoUpdateEventScripterSettings}" ]; then
    log "cp" "./$autoUpdateEventScripterSettings" "${cfg}${autoUpdateEventScripterSettings}"
    cp "./$autoUpdateEventScripterSettings" "${cfg}${autoUpdateEventScripterSettings}"
fi
autoUpdateEventScripterScript="org.jdownloader.extensions.eventscripter.EventScripterExtension.scripts.json"
if [ ! -f "${cfgDir}${autoUpdateEventScripterScript}" ]; then
    log "cp" "./$autoUpdateEventScripterScript" "${cfgDir}${autoUpdateEventScripterScript}"
    cp "./$autoUpdateEventScripterScript" "${cfgDir}${autoUpdateEventScripterScript}"
fi

generalSettingsFileName="org.jdownloader.settings.GeneralSettings.json"
generalSettingsFile="${cfgDir}${generalSettingsFileName}"

# If JDownloader general settings file doesn't exist
if [ ! -f $generalSettingsFile ]; then
    log "Write JDownloader download path in settings file"
    cp "./$generalSettingsFileName" "$generalSettingsFile"
    cpExitCode=$?
    if [ $cpExitCode -ne 0 ]; then
        fatal $cpExitCode "cp \"$generalSettingsFileName\" exited with code \"$cpExitCode\""
    fi
fi

myJDownloaderSettingsFileName="org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json"
myJDownloaderSettingsFile="${cfgDir}${myJDownloaderSettingsFileName}"

# If myJDownloader settings file doesn't exist
if [ ! -f $myJDownloaderSettingsFile ]; then
    log "Write myJDownloader settings file"
    cp "./$myJDownloaderSettingsFileName" "$myJDownloaderSettingsFile"
    cpExitCode=$?
    if [ $cpExitCode -ne 0 ]; then
        fatal $cpExitCode "cp \"$myJDownloaderSettingsFileName\" exited with code \"$cpExitCode\""
    fi
fi

if [ -n "$JD_EMAIL" ]; then
    log "Replace JDownloader email in myJDownloader settings file"
    replaceJsonValue $myJDownloaderSettingsFile "email" "$JD_EMAIL"
fi

if [ -n "$JD_PASSWORD" ]; then
    log "Replace JDownloader password in myJDownloader settings file"
    replaceJsonValue $myJDownloaderSettingsFile "password" "$JD_PASSWORD"
fi

if [ -n "$JD_DEVICENAME" ]; then
    log "Replace JDownloader devicename in myJDownloader settings file"
    replaceJsonValue $myJDownloaderSettingsFile "devicename" "$JD_DEVICENAME"
fi

groupEnd

unset JD_EMAIL
unset JD_PASSWORD
unset JD_DEVICENAME

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
    log "Download https://$JDownloaderJarUrl"

    curl -s -O "https://$JDownloaderJarUrl"
    curlExitCode=$?

    if [ $curlExitCode -ne 0 ]; then
        log "$JDownloaderJarFile download failed: curl exited with code \"$curlExitCode\""
        
        # If https download failed, we try the http link
        if [ ! -f "./$JDownloaderJarFile" ]; then
            log "Download http://$JDownloaderJarUrl"

            curl -s -O "http://$JDownloaderJarUrl"
            curlExitCode=$?

            if [ $curlExitCode -ne 0 ]; then
                groupEnd
                groupEnd
                fatal $curlExitCode "$JDownloaderJarFile download failed: curl exited with code \"$curlExitCode\""
            fi
        fi
    fi
fi

groupEnd

group "Start JDownloader"

# Create logs dir if needed
if [ ! -d "./logs/" ]; then
    log "Create directory \"./logs/\""
    mkdir -p "./logs/"
fi

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
