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

# Log OS pretty name
OS_prettyName=$(cat /etc/os-release | grep "PRETTY_NAME=" | sed -En "s/^PRETTY_NAME=(.+)$/\1/p")
log "OS is $OS_prettyName"

# Check environment variables

if [ -z "$JD_EMAIL" ]
then
    log "WARNING" "Environment variable 'JD_EMAIL' is not set"
fi

if [ -z "$JD_PASSWORD" ]
then
    log "WARNING" "Environment variable 'JD_PASSWORD' is not set"
fi

if [ -z "$JD_DEVICENAME" ]
then
    JD_DEVICENAME=$(uname -n)
fi

JDownloaderJarFile="JDownloader.jar"
JDownloaderJarUrl="http://installer.jdownloader.org/$JDownloaderJarFile"
JDownloaderPidFile="JDownloader.pid"

JDownloaderJarFileSize=$(ls -l JDownloader.jar 2> /dev/null | awk '{print $5}')

# If the JDownloader.jar file does not exist or is corrupted (file size equals zero)
if [ ! -f "./$JDownloaderJarFile" ] || [ "$JDownloaderJarFileSize" = "0" ]
then
    log "Delete any existing JDownloader installation files"
    rm -f -r JDownloader.jar Core.jar ./tmp ./update
fi

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

log "Start JDownloader"

# Start JDownloader in a background process
java -Djava.awt.headless=true -jar $JDownloaderJarFile &> /dev/null &
pid=$!
lastPid=""

while [ -n "$pid" ]
do
    log "JDownloader ${lastPid:+re}started (PID $pid)"
    
    if [[ $stop ]]
    then
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
