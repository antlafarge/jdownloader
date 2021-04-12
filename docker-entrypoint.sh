#!/bin/bash

source functions.sh

OS=$(cat /etc/os-release | grep "ID=" | sed -En "s/^ID=(.+)$/\1/p")

# Create user
createUser()
{
    if [ $OS = "alpine" ]
    then
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
    if [ $OS = "alpine" ]
    then
        addgroup -g $GID jdgroup
    else # default ubuntu
        groupadd -g $GID jdgroup
    fi
}

# Delete group
deleteGroup()
{
    if [ $OS = "alpine" ]
    then
        delgroup jdgroup
    else # default ubuntu
        groupdel jdgroup
    fi
}

# Setup user and group in OS
setupUserAndGroup()
{
    log "Setting up User and Group"

    currentUID=$(id -u jduser 2> /dev/null)

    currentGID=$(cut -d: -f3 < <(getent group jdgroup))

    # If current UID does not match OR If current GID does not match
    if [ "$currentUID" != "$UID" ] || [ "$currentGID" != "$GID" ]
    then
        log "UID or GID does not match (currentUID='$currentUID', UID='$UID', currentGID='$currentGID', GID='$GID')"

        # If current UID is set (not null or not empty)
        if [ -n "$currentUID" ]
        then
            log "Delete user"
            deleteUser
        fi

        # If current GID is set (not null or not empty)
        if [ -n "$currentGID" ]
        then
            log "Delete group"
            deleteGroup
        fi

        log "Create group with GID '$GID'"
        createGroup

        log "Create user with UID '$UID'"
        createUser
    fi

    log "User and group set up"
}

handleSignal()
{
    log "Kill signal received"
    if [ -n "$pid" ]
    then
        pids=$(pgrep java | tr '\n' ' ')
        if [ -n "$pids" ]
        then
            kill -SIGTERM $pids
            log "SIGTERM sent to java process $pids"
        fi
    else
        log "======== CONTAINER KILLED ========"
        exit 0
    fi
}
trap handleSignal SIGTERM SIGINT

# Disable bash history substitution
set +H

log "======== CONTAINER STARTED ========"

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

setupUserAndGroup

log "--------------------------------"

./setup.sh "$JD_EMAIL" "$JD_PASSWORD" "$JD_NAME"

log "Setup access rights to current directory"

# Set access rigths
chown -R jduser:jdgroup .
chmod -R 770 .

log "--------------------------------"

su jduser -s "./start.sh" &

pid=$!
wait $pid
trap - TERM INT
wait $pid
exitStatus=$?

log "======== CONTAINER STOPPED ========"

exit $exitStatus
