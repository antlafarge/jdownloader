#!/bin/bash

# Disable bash history substitution
set +H

# Log
log()
{
    if [ $OS = "alpine" ]; then

        echo "$(date -I'seconds')|JDownloader script| $@"

    else # default ubuntu

        echo "$(date --iso-8601=seconds)|JDownloader script| $@"
        
    fi
}

# Log errors
logErr()
{
    log $@
}

# Create user
createUser()
{
    if [ $OS = "alpine" ]; then

        adduser -DH -s /bin/bash -u $UID -G jdgroup jduser

    else # default ubuntu

        useradd -M -s /bin/bash -u $UID -G jdgroup jduser

    fi
}

# Delete user
deleteUser()
{
    deluser jduser
}

# Create group
createGroup()
{
    if [ $OS = "alpine" ]; then

        addgroup -g $GID jdgroup

    else # default ubuntu

        groupadd -g $GID jdgroup

    fi
}

# Delete group
deleteGroup()
{
    if [ $OS = "alpine" ]; then

        delgroup jdgroup

    else # default ubuntu

        groupdel jdgroup

    fi
}

# Setup user and group in OS
setupUserAndGroup()
{
    log "Setting up User and Group"

    log "Get current UID"

    # Get current UID
    currentUID=$(id -u jduser 2> /dev/null)

    log "Get current GID"

    # Get current GID
    currentGID=$(cut -d: -f3 < <(getent group jdgroup))

    # If current UID does not match OR If current GID does not match
    if [ "$currentUID" != "$UID" ] || [ "$currentGID" != "$GID" ]; then

        log "UID or GID does not match (currentUID='$currentUID', UID='$UID', currentGID='$currentGID', GID='$GID')"

        # If current UID is set (not null or not empty)
        if [ -n "$currentUID" ]; then

            log "Delete user"

            # delete user
            deleteUser

            log "User deleted"

        fi

        # If current GID is set (not null or not empty)
        if [ -n "$currentGID" ]; then

            log "Delete group"

            # Delete group
            deleteGroup

            log "Group deleted"

        fi

        log "Create group with GID '$GID'"

        # Create group
        createGroup

        log "Group created"

        log "Create user with UID '$UID'"

        # Create user and add to group
        createUser

        log "User created"

    fi

    log "User and group set up"
}

# Setup and start JDownloader
startJDownloader()
{
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

    cfgDir="./cfg/"

    # If JDownloader cfg directory does not exist
    if [ ! -d $cfgDir ]; then

        log "create cfg directory"

        # Create cfg directory
        mkdir -p cfg

    fi

    generalSettingsFile="${cfgDir}org.jdownloader.settings.GeneralSettings.json"

    # If JDownloader general settings file does not exist
    if [ ! -f $generalSettingsFile ]; then

        log "Write JDownloader download path in settings file"

        # Write JDownloader download path in settings file
        printf "{\n\t\"defaultdownloadfolder\":\"/downloads\"\n}" > $generalSettingsFile

    fi

    myJDownloaderSettingsFile="${cfgDir}org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json"

    # If myJDownloader settings file exists
    if [ ! -f $myJDownloaderSettingsFile ]; then

        log "Write myJDownloader settings file"

        # Write myJdownloader settings file
        printf "{\n\t\"email\":\"\",\n\t\"password\":\"\",\n\t\"devicename\":\"\",\n\t\"autoconnectenabledv2\":true\n}" > $myJDownloaderSettingsFile

    fi

    log "Replacing JDownloader email, devicename and password in myJDownloader settings file"

    # Replacing JDownloader email, devicename and password in myJDownloader settings file
    replaceJsonValue $myJDownloaderSettingsFile "email" "$JD_EMAIL"

    replaceJsonValue $myJDownloaderSettingsFile "devicename" "$JD_NAME"
    
    if [ -n "$JD_PASSWORD" ]; then

        replaceJsonValue $myJDownloaderSettingsFile "password" "$JD_PASSWORD"

    fi

    # On linux/arm/v7 systems, sleep could generate this error :
    # "sleep: cannot read realtime clock: Operation not permitted"
    # This is a workaround
    sleepWorkaround()
    {
        seconds=$1

        read -t $seconds < /dev/zero || true
    }

    # Wait for a process to stop
    waitProcess()
    {
        pid=$1

        # Wait process to stop
        while kill -0 "$pid" 2> /dev/null; do

            # sleep 1
            sleepWorkaround 1

        done
    }

    JDownloaderJarFile="JDownloader.jar"
    JDownloaderJarUrl="http://installer.jdownloader.org/$JDownloaderJarFile"
    JDownloaderPidFile="JDownloader.pid"

    # If JDownloader jar file does not exist
    if [ ! -f "./$JDownloaderJarFile" ]; then

        log "Downloading $JDownloaderJarFile"

        # Download JDownloader
        curl -O $JDownloaderJarUrl 2> /dev/null

        log "$JDownloaderJarFile downloaded"

    fi

    log "Starting JDownloader"

    # Start JDownloader in background
    java -Djava.awt.headless=true -jar $JDownloaderJarFile &> /dev/null &

    # Get PID
    pid=$!

    jdrunning=true

    while [ $jdrunning = true ]; do

        log "JDownloader started (PID $pid)"

        waitProcess $pid
        
        log "JDownloader stopped (PID $pid)"

        # Get the written JDownloader PID or the next running Java PID
        pid=$(pgrep -L -F $JDownloaderPidFile 2> /dev/null || pgrep "java" | head -n 1)

        # If no PID found
        if [ -z "$pid" ]; then

            # No running proces found, exit script
            jdrunning=false
            
        fi

    done

    log "JDownloader exited"
}

log "======== SCRIPT STARTED ========"

# Check environment variables
if [ -z "$JD_EMAIL" ]; then
    logErr "Environment variable JD_EMAIL has not been set (JD_EMAIL='$JD_EMAIL')"
    exit 1
fi
if [ -z "$JD_PASSWORD" ]; then
    logErr "Warning: Environment variable JD_PASSWORD has not been set (JD_PASSWORD='$JD_PASSWORD')"
    # Do not exit here, only display a warning, because the password could be placed by the user in the settings file
fi
if [ -z "$JD_NAME" ]; then
    logErr "Environment variable JD_NAME has not been set (JD_NAME='$JD_NAME')"
    exit 1
fi
if [ -z "$UID" ]; then
    logErr "Environment variable UID has not been set (UID='$UID')"
    exit 1
fi
if [ -z "$GID" ]; then
    logErr "Environment variable GID has not been set (GID='$GID')"
    exit 1
fi

setupUserAndGroup

log "Setup access rights to current directory"

# Set access rigths
chown -R jduser:jdgroup .
chmod -R 770 .

su jduser -c "$(declare -f startJDownloader log); startJDownloader"

log "======== SCRIPT EXITED ========"
