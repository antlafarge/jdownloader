#!/bin/bash

# This script set up JDownloader

# Disable bash history substitution
set +H

source functions.sh

# Get variables from arguments
email=$1
password=$2
devicename=$3

cfgDir="./cfg/"

# If JDownloader cfg directory does not exist
if [ ! -d $cfgDir ]
then
    log "Create cfg directory"
    mkdir -p cfg
fi

generalSettingsFile="${cfgDir}org.jdownloader.settings.GeneralSettings.json"

# If JDownloader general settings file does not exist
if [ ! -f $generalSettingsFile ]
then
    log "Write JDownloader download path in settings file"

    printf "{\n\t\"defaultdownloadfolder\":\"/jdownloader/downloads\"\n}" > $generalSettingsFile
    printfExitCode=$?

    if [ $printfExitCode -ne 0 ]
    then
        log "ERROR" "printf exited with code '$printfExitCode'"
        exit $printfExitCode
    fi
fi

myJDownloaderSettingsFile="${cfgDir}org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json"

# If myJDownloader settings file exists
if [ ! -f $myJDownloaderSettingsFile ]
then
    log "Write myJDownloader settings file"

    printf "{\n\t\"email\":\"\",\n\t\"password\":\"\",\n\t\"devicename\":\"\",\n\t\"autoconnectenabledv2\":true\n}" > $myJDownloaderSettingsFile
    printfExitCode=$?

    if [ $printfExitCode -ne 0 ]
    then
        log "ERROR" "printf exited with code '$printfExitCode'"
        exit $printfExitCode
    fi
fi

if [ -n "$email" ]
then
    log "Replace JDownloader email in myJDownloader settings file"
    jq --arg email $email '.email = $email' $myJDownloaderSettingsFile > temp.json && mv temp.json $myJDownloaderSettingsFile
fi

if [ -n "$password" ]
then
    log "Replace JDownloader password in myJDownloader settings file"
    jq --arg password $password '.password = $password' $myJDownloaderSettingsFile > temp.json && mv temp.json $myJDownloaderSettingsFile
fi

if [ -n "$devicename" ]
then
    log "Replace JDownloader devicename in myJDownloader settings file"
    jq --arg devicename $devicename '.devicename = $devicename' $myJDownloaderSettingsFile > temp.json && mv temp.json $myJDownloaderSettingsFile
fi
