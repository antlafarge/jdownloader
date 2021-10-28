#!/bin/bash

# This script set up JDownloader

# Disable bash history substitution
set +H

source functions.sh

# Get variables from arguments
email=$1
password=$2
devicename=$3

# Replace a JSON value by searching its field in a JSON file
# Usage : replaceJsonValue file field value
replaceJsonValue()
{
    file=$1
    field=$(printf "%s" "$2" | sed -e 's/\\/\\\\/g' -e 's/[]\/$*.^[]/\\&/g') # this field will be compared to a value from a json file, so we need to double escape the backslashes \\\\    And this field will be used in a sed regex, so we escape regex special characters ]\/$*.^[
    newValue=$(printf "%s" "$3" | sed -e 's/[\/&]/\\&/g' -e 's/"/\\\\"/g') # this value will be used in a sed replace, so we escape replace special characters \/&    And this value will be stored in a json file, so finally we double escape the quotes \\\\"

    fieldPart="\($field\)" # match the field
    valuePart="\([^\\\"]\|\\\\.\)*" # match the value. This looks complicated because it can contain escaped quotes \" because of json format.

    search="\"$fieldPart\"\s*:\s*\"$valuePart\""
    replace="\"\1\":\"$newValue\""

    sed -i "s/$search/$replace/g" $file
    sedExitCode=$?

    if [ $sedExitCode -ne 0 ]
    then
        log "ERROR" "sed exited with code '$sedExitCode'"
        exit $sedExitCode
    fi
}

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
    replaceJsonValue $myJDownloaderSettingsFile "email" "$email"
fi

if [ -n "$password" ]
then
    log "Replace JDownloader password in myJDownloader settings file"
    replaceJsonValue $myJDownloaderSettingsFile "password" "$password"
fi

if [ -n "$devicename" ]
then
    log "Replace JDownloader devicename in myJDownloader settings file"
    replaceJsonValue $myJDownloaderSettingsFile "devicename" "$devicename"
fi
