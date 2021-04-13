#!/bin/bash

# This script start JDownloader

source functions.sh

handleSignal()
{
    echo "start.sh| Kill signal received"
    if [ -n "$pid" ]
    then
        kill -SIGTERM $pid 2> /dev/null
        echo "start.sh| SIGTERM sent to start.sh process $pid"
    else
        echo "start.sh| Killed"
        exit 0
    fi
}
trap handleSignal SIGTERM SIGINT

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

log "Starting JDownloader"
java -Djava.awt.headless=true -jar $JDownloaderJarFile &> /dev/null & # Start JDownloader in background
pid=$! # Get java PID

jdrunning=true

while [ $jdrunning = true ]
do
    if [ -z "$lastPid" ]
    then
        log "JDownloader started (PID $pid)"
    else
        log "JDownloader restarted (PID $pid)"
    fi

    waitProcess $pid

    # Get the written JDownloader PID or the next running Java PID
    lastPid="$pid"
    pid=$(pgrep -L -F $JDownloaderPidFile 2> /dev/null || pgrep -n java)

    # If no PID found
    if [ -z "$pid" ]
    then
        # No running proces found, exit script
        jdrunning=false
    fi
done

log "JDownloader stopped"
