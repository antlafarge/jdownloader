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
    createUser_userName=$1
    createUser_uid=$2
    createUser_groupName=$3
    createUser_gid=$4
    createUser_os=$5

    if [ $createUser_os == "alpine" ]
    then
        adduser -DH -s /bin/bash -u $createUser_uid -G $createUser_groupName $createUser_userName
    else # default ubuntu
        useradd -M -s /bin/bash -u $createUser_uid -g $createUser_groupName -G $createUser_groupName $createUser_userName
    fi
}

# Delete user
deleteUser()
{
    deleteUser_userName=$1

    deluser $deleteUser_userName > /dev/null
}

# Create group
createGroup()
{
    createGroup_groupName=$1
    createGroup_gid=$2
    createGroup_os=$3

    if [ $createGroup_os == "alpine" ]
    then
        addgroup -g $createGroup_gid $createGroup_groupName
    else # default ubuntu
        groupadd -g $createGroup_gid $createGroup_groupName
    fi
}

# Delete group
deleteGroup()
{
    deleteGroup_groupName=$1
    deleteGroup_os=$2

    if [ $deleteGroup_os == "alpine" ]
    then
        delgroup $deleteGroup_groupName
    else # default ubuntu
        groupdel $deleteGroup_groupName
    fi
}

# Setup user and group in OS
setupUserAndGroup()
{
    setupUserAndGroup_uid=$1
    setupUserAndGroup_gid=$2
    setupUserAndGroup_os=$3

    log "Setting up User and Group"
    
    # Retrieve the passwd entry of the user which reserved the UID
    userInfo=$(getent passwd $setupUserAndGroup_uid)

    # Extract the user name (set the 'user' variable declared in the docker-entrypoint.sh script)
    user=$(echo "$userInfo" | cut -d":" -f1)

    # Extract the group name (set the 'group' variable declared in the docker-entrypoint.sh script)
    group=$(cut -d: -f1 < <(getent group $setupUserAndGroup_gid))

    # Extract the user primary group GID
    currentPrimaryGID=$(echo "$userInfo" | cut -d":" -f4)

    # If the user primary group GID matches the group GID
    if [ "$currentPrimaryGID" == "$setupUserAndGroup_gid" ]
    then
        # The user and the group are valid, we exit
        return
    fi

    # If a user with the user UID exists
    if [ -n "$user" ]
    then
        # Delete this user (because it reserved the user UID)
        log "Delete user '$user' (UID '$setupUserAndGroup_uid')"
        deleteUser $user
    fi

    # Retrieve the 'jduser' user UID
    jduserUID=$(id -u jduser 2> /dev/null)

    # If the 'jduser' user exists
    if [ -n "$jduserUID" ]
    then
        # Delete the 'jduser' user (because it reserved the user name)
        log "Delete user 'jduser' (UID '$jduserUID')"
        deleteUser jduser
    fi

    # If the group does not exist
    if [ -z "$group" ]
    then
        # Retrieve the 'jdgroup' group GID
        jdgroupGID=$(cut -d: -f3 < <(getent group jdgroup))

        # If the 'jdgroup' group exists
        if [ -n "$jdgroupGID" ]
        then
            # Delete the 'jdgroup' group (because it reserved the group name)
            log "Delete group 'jdgroup' (GID '$jdgroupGID')"
            deleteGroup jdgroup $setupUserAndGroup_os
        fi

        # Set default group (set the 'group' variable declared in the docker-entrypoint.sh script)
        group="jdgroup"

        # Create the 'jdgroup' group by using the group GID
        log "Create group 'jdgroup' (GID '$setupUserAndGroup_gid')"
        createGroup $group $setupUserAndGroup_gid $setupUserAndGroup_os
    fi

    # Set default user (set the 'user' variable declared in the docker-entrypoint.sh script)
    user="jduser"

    # Create the 'jduser' user by using the user UID and the group name of the group which reserved the GID
    log "Create user 'jduser' (UID '$setupUserAndGroup_uid') with primary group '$group' (GID '$setupUserAndGroup_gid')"
    createUser jduser $setupUserAndGroup_uid $group $setupUserAndGroup_gid $setupUserAndGroup_os

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
            useSleepWorkaround=true # Else we switch to sleep workaround
            log "WARNING" "Sleep failed : Switching to sleep workaround"
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
