#!/bin/bash

# This script set up JDownloader

source functions.sh

# Disable bash history substitution
set +H

# Get variables from arguments
email=$1
password=$2
name=$3

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
}

log "Setting up JDownloader"

cfgDir="./cfg/"

# If JDownloader cfg directory does not exist
if [ ! -d $cfgDir ]
then
    log "create cfg directory"
    mkdir -p cfg
fi

generalSettingsFile="${cfgDir}org.jdownloader.settings.GeneralSettings.json"

# If JDownloader general settings file does not exist
if [ ! -f $generalSettingsFile ]
then
    log "Write JDownloader download path in settings file"
    printf "{\n\t\"defaultdownloadfolder\":\"/jdownloader/downloads\"\n}" > $generalSettingsFile
fi

myJDownloaderSettingsFile="${cfgDir}org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json"

# If myJDownloader settings file exists
if [ ! -f $myJDownloaderSettingsFile ]
then
    log "Write myJDownloader settings file"
    printf "{\n\t\"email\":\"\",\n\t\"password\":\"\",\n\t\"devicename\":\"\",\n\t\"autoconnectenabledv2\":true\n}" > $myJDownloaderSettingsFile
fi

if [ -n "$email" ]
then
    log "Replacing JDownloader email in myJDownloader settings file"
    replaceJsonValue $myJDownloaderSettingsFile "email" "$email"
fi

if [ -n "$password" ]
then
    log "Replacing JDownloader password in myJDownloader settings file"
    replaceJsonValue $myJDownloaderSettingsFile "password" "$password"
fi

if [ -n "$name" ]
then
    log "Replacing JDownloader devicename in myJDownloader settings file"
    replaceJsonValue $myJDownloaderSettingsFile "devicename" "$name"
fi

log "JDownloader set up"
