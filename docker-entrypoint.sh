#!/bin/bash

# Disable bash history substitution
set +H

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
        log "________________________________________ CONTAINER KILLED __________________________________________"
        exit $((128 + $handleSignal_signalCode))
    fi
}
trap "handleSignal 1" SIGHUP
trap "handleSignal 2" SIGINT
trap "handleSignal 15" SIGTERM

# Detect OS (ubuntu or alpine)
OS=$(cat /etc/os-release | grep "ID=" | sed -En "s/^ID=(.+)$/\1/p")

log "________________________________________ CONTAINER STARTED _________________________________________"

# Deprecated 'JD_NAME' environment variable
if [ -n "$JD_NAME" ] && [ -z "$JD_DEVICENAME" ]
then
    JD_DEVICENAME="$JD_NAME"
    log "WARNING" "Environment variable 'JD_NAME' is deprecated (change to 'JD_DEVICENAME')"
fi

# Check environment variables

if [ -z "$JD_EMAIL" ]
then
    log "WARNING" "Environment variable 'JD_EMAIL' not set"
fi

if [ -z "$JD_PASSWORD" ]
then
    log "WARNING" "Environment variable 'JD_PASSWORD' not set"
fi

if [ -z "$JD_DEVICENAME" ]
then
    JD_DEVICENAME=$(uname -n)
fi

if [ -z "$UID" ]
then
    log "WARNING" "Environment variable 'UID' not set (changed to '1000')"
    UID=1000
fi

if [ -z "$GID" ]
then
    log "WARNING" "Environment variable 'GID' not set (changed to '1000')"
    GID=1000
fi

user="" # it is set in the setupUserAndGroup function
group="" # it is set in the setupUserAndGroup function

setupUserAndGroup $UID $GID $OS
setupUserExitCode=$?

if [ $setupUserExitCode -ne 0 ]
then
    fatal "User setup exited with code '$setupUserExitCode'"
fi

if [ -z "$user" ]
then
    fatal "No user selected"
fi

if [ -z "$group" ]
then
    fatal "No group selected"
fi

JDownloaderJarFile="JDownloader.jar"
JDownloaderJarUrl="http://installer.jdownloader.org/$JDownloaderJarFile"
JDownloaderPidFile="JDownloader.pid"

# If the JDownloader jar file does not exist
if [ ! -f "./$JDownloaderJarFile" ]
then
    log "Download $JDownloaderJarFile"
    
    curl -s -O "$JDownloaderJarUrl"
    curlExitCode=$?

    if [ $curlExitCode -ne 0 ]
    then
        fatal "$JDownloaderJarFile download failed: curl exited with code '$curlExitCode'"
    fi
fi

./setup.sh "$JD_EMAIL" "$JD_PASSWORD" "$JD_DEVICENAME"
setupShExitCode=$?

if [ $setupShExitCode -ne 0 ]
then
    fatal "setup.sh exited with code '$setupShExitCode'"
fi

log "Set up permissions on the current directory"

chown -R $user:$group .
chmod -R 770 .

log "Start JDownloader as user '$user'"

# Start JDownloader in a background process as $user
su -p $user -s /bin/bash -c "java -Djava.awt.headless=true -jar $JDownloaderJarFile &> /dev/null &"
suExitCode=$?

if [ $suExitCode -ne 0 ]
then
    fatal "su exited with code '$suExitCode'"
fi

running=true
while [ $running == true ]
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

log "________________________________________ CONTAINER STOPPED _________________________________________"

exit $exitCode
