#!/bin/bash

# This script defines the shared functions

# Log
log()
{
    echo "$(date -I'seconds')| $@" >&2
}

# Create user
createUser()
{
    createUser_UID=$1
    createUser_OS=$2

    if [ $createUser_OS = "alpine" ]
    then
        adduser -DH -s /bin/bash -u $createUser_UID -G jdgroup jduser
    else # default ubuntu
        useradd -M -s /bin/bash -u $createUser_UID -G jdgroup jduser
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
    createGroup_GID=$1
    createGroup_OS=$2

    if [ $createGroup_OS = "alpine" ]
    then
        addgroup -g $createGroup_GID jdgroup
    else # default ubuntu
        groupadd -g $createGroup_GID jdgroup
    fi
}

# Delete group
deleteGroup()
{
    deleteGroup_OS=$1

    if [ $deleteGroup_OS = "alpine" ]
    then
        delgroup jdgroup
    else # default ubuntu
        groupdel jdgroup
    fi
}

# Setup user and group in OS
setupUserAndGroup()
{
    setupUserAndGroup_UID=$1
    setupUserAndGroup_GID=$2
    setupUserAndGroup_OS=$3

    log "Setting up User and Group"

    currentUID=$(id -u jduser 2> /dev/null)

    currentGID=$(cut -d: -f3 < <(getent group jdgroup))

    # If current UID does not match OR If current GID does not match
    if [ "$currentUID" != "$setupUserAndGroup_UID" ] || [ "$currentGID" != "$setupUserAndGroup_GID" ]
    then
        log "UID or GID does not match (currentUID='$currentUID', UID='$setupUserAndGroup_UID', currentGID='$currentGID', GID='$setupUserAndGroup_GID')"

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
            deleteGroup $setupUserAndGroup_OS
        fi

        log "Create group with GID '$setupUserAndGroup_GID'"
        createGroup $setupUserAndGroup_GID $setupUserAndGroup_OS

        log "Create user with UID '$setupUserAndGroup_UID'"
        createUser $setupUserAndGroup_UID $setupUserAndGroup_OS
    fi

    log "User and group set up"
}

# sleep workaround
## On linux/arm/v7 systems, docker containers with insufficient permissions can generate this error :
## "sleep: cannot read realtime clock: Operation not permitted"
sleepWorkaround()
{
    sleepWorkaround_seconds=$1

    if [[ ! $useSleepWorkaround ]] # Try sleep
    then
        if sleep $sleepWorkaround_seconds 2> /dev/null # If sleep succeed
        then
            return 0 # We exit
        else
            log "WARNING" "Sleep failed : Switching to sleep workaround"
            useSleepWorkaround=true # Else we switch to sleep workaround
        fi
    fi

    # sleep workaround
    coproc read -t $sleepWorkaround_seconds && wait $! || true
    wait $!
}

# Wait for many processes to terminate
waitProcess()
{
    waitProcess_pids=$@

    # Wait processes
    if ! wait $waitProcess_pids 2> /dev/null
    then
        # If a pid is not a child process
        # Wait processes with a sleep loop
        while kill -0 $waitProcess_pids 2> /dev/null
        do
            # sleep 1
            sleepWorkaround 1
        done
    fi
}

# Kill many processes
killProcess()
{
    killProcess_pids=$@

    log "Send SIGTERM to process $killProcess_pids"
    kill -SIGTERM $killProcess_pids 2> /dev/null
}
