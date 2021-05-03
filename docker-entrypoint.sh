#!/bin/bash

# Disable bash history substitution
set +H

# Set locales to support UTF-8
export LANG="C.UTF-8"
export LC_ALL="C.UTF-8"

source functions.sh

handleSignal()
{
    handleSignal_signalCode=$1
    log "Kill signal $handleSignal_signalCode received"
    if [ -n "$pid" ] # If java process found
    then
        stop=true
        killProcess $pid
    else
        log "========================================= CONTAINER KILLED ========================================="
        exit $((128 + $handleSignal_signalCode))
    fi
}
trap "handleSignal 1" SIGHUP
trap "handleSignal 2" SIGINT
trap "handleSignal 15" SIGTERM

# Detect OS (ubuntu or alpine)
OS=$(cat /etc/os-release | grep "ID=" | sed -En "s/^ID=(.+)$/\1/p")

log "======================================== CONTAINER STARTED ========================================="

# Check deprecated parameters

if [ -d "/downloads" ]
then
    log "WARNING" "'/downloads' directory path deprecated, please use '/jdownloader/downloads' instead"

    if [ ! -d "/jdownloader/downloads" ]
    then
        ln -s "/downloads" "/jdownloader/downloads"
    fi
fi

# Check environment variables

if [ -z "$JD_EMAIL" ]
then
    log "ERROR" "Environment variable 'JD_EMAIL' not set (JD_EMAIL='$JD_EMAIL')"
fi

if [ -z "$JD_PASSWORD" ]
then
    log "WARNING" "Environment variable 'JD_PASSWORD' not set (JD_PASSWORD='$JD_PASSWORD')"
    # Do not exit here, only display a warning, because the password could be placed by the user in the settings file
fi

if [ -z "$JD_NAME" ]
then
    log "WARNING" "Environment variable 'JD_NAME' not set (JD_NAME='$JD_NAME')"
fi

if [ -z "$UID" ]
then
    log "WARNING" "Environment variable 'UID' not set (UID='$UID')"
    UID=0
fi

if [ -z "$GID" ]
then
    log "WARNING" "Environment variable 'GID' not set (GID='$GID')"
    GID=0
fi

user="" # it is set in setupUserAndGroup
group="" # it is set in setupUserAndGroup

setupUserAndGroup $UID $GID $OS

if [ -z "$user" || -z "$group" ]
then
    log "User setup failed, exiting the container..."
    log "========================================= CONTAINER EXITED ========================================="
    exit 1
fi

log "----------------------------------------"

./setup.sh "$JD_EMAIL" "$JD_PASSWORD" "$JD_NAME"

log "----------------------------------------"

JDownloaderJarFile="JDownloader.jar"
JDownloaderJarUrl="http://installer.jdownloader.org/$JDownloaderJarFile"
JDownloaderPidFile="JDownloader.pid"

# If JDownloader jar file does not exist
if [ ! -f "./$JDownloaderJarFile" ]
then
    log "Downloading $JDownloaderJarFile"
    curl -O $JDownloaderJarUrl 2> /dev/null
    log "$JDownloaderJarFile downloaded"
fi

log "Setup access rights to current directory"
chown -R $user:$group .
chmod -R 770 .

log "----------------------------------------"

log "Starting JDownloader"
su $user -c "java -Djava.awt.headless=true -jar $JDownloaderJarFile &> /dev/null &" # Start JDownloader in background

running=true
while [ $running = true ]
do
    lastPid="$pid"

    # Get the written JDownloader PID or another running Java PID
    pid=$(pgrep -L -F $JDownloaderPidFile 2> /dev/null || pgrep -o java)

    if [ -n "$pid" ]
    then
        log "JDownloader ${lastPid:+re}started (PID $pid)"
        if [[ $stop ]]
        then
            killProcess $pid
        fi
        waitProcess $pid
        exitCode=$?
    else
        running=false
    fi
done

log "JDownloader stopped"

log "======================================== CONTAINER STOPPED ========================================="

exit $exitCode
