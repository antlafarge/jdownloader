#!/bin/bash

# This script defines the shared functions

# Log
log()
{
    echo "$(date -I'seconds')| $@" >&2
}

# Fatal error occured, we log and exit the script
fatal()
{
    fatal_log="$1"

    log "FATAL ERROR" "$fatal_log"
    log "Get more informations here : https://github.com/antlafarge/jdownloader#troubleshooting"
    log "========================================= CONTAINER EXITED ========================================="
    exit 1
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

    useraddExitCode=$?

    if [ $useraddExitCode -ne 0 ]
    then
        if [ $createUser_os == "alpine" ]
        then
            fatal "adduser exited with code '$useraddExitCode'"
        else # default ubuntu
            fatal "useradd exited with code '$useraddExitCode'"
        fi
    fi
}

# Delete user
deleteUser()
{
    deleteUser_userName=$1

    deluser $deleteUser_userName > /dev/null
    deluserExitCode=$?

    if [ $deluserExitCode -ne 0 ]
    then
        fatal "deluserExitCode exited with code '$deluserExitCode'"
    fi
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
    
    groupaddExitCode=$?

    if [ $groupaddExitCode -ne 0 ]
    then
        if [ $createUser_os == "alpine" ]
        then
            fatal "addgroup exited with code '$groupaddExitCode'"
        else # default ubuntu
            fatal "groupadd exited with code '$groupaddExitCode'"
        fi
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
    
    groupdelExitCode=$?

    if [ $groupdelExitCode -ne 0 ]
    then
        if [ $createUser_os == "alpine" ]
        then
            fatal "delgroup exited with code '$groupdelExitCode'"
        else # default ubuntu
            fatal "groupdel exited with code '$groupdelExitCode'"
        fi
    fi
}

# Setup user and group in OS
setupUserAndGroup()
{
    setupUserAndGroup_uid=$1
    setupUserAndGroup_gid=$2
    setupUserAndGroup_os=$3

    # Retrieve the passwd entry of the user which reserved the UID
    userInfo=$(getent passwd $setupUserAndGroup_uid)

    # Extract the user name (set the '$user' variable declared in the docker-entrypoint.sh script)
    user=$(echo "$userInfo" | cut -d":" -f1)

    # Extract the group name (set the '$group' variable declared in the docker-entrypoint.sh script)
    group=$(cut -d: -f1 < <(getent group $setupUserAndGroup_gid))

    # Extract the user primary group GID
    currentPrimaryGID=$(echo "$userInfo" | cut -d":" -f4)

    # If the user which uses the wanted user UID has a primary group GID which matches the wanted group GID
    if [ "$currentPrimaryGID" == "$setupUserAndGroup_gid" ]
    then
        # The user and the group are valid, we exit
        log "User '$user' (UID '$setupUserAndGroup_uid') with primary group '$group' (GID '$currentPrimaryGID') already set up"
        return
    fi

    # From here we have to (re)create the user and the group

    # If a user owns the UID
    if [ -n "$user" ]
    then
        # Delete the user
        log "Delete user '$user' (UID '$setupUserAndGroup_uid')"
        deleteUser $user
    fi

    # Retrieve the 'jduser' user UID
    jduserUID=$(id -u jduser 2> /dev/null)

    # If a user owns the 'jduser' name
    if [ -n "$jduserUID" ]
    then
        # Delete the user
        log "Delete user 'jduser' (UID '$jduserUID')"
        deleteUser jduser
    fi

    # If no group owns the GID
    if [ -z "$group" ]
    then
        # Retrieve the 'jdgroup' group GID
        jdgroupGID=$(cut -d: -f3 < <(getent group jdgroup))

        # If the group owns the 'jdgroup' group name
        if [ -n "$jdgroupGID" ]
        then
            # Delete the 'jdgroup' group
            log "Delete group 'jdgroup' (GID '$jdgroupGID')"
            deleteGroup jdgroup $setupUserAndGroup_os
        fi

        # Set default group (set the '$group' variable declared in the docker-entrypoint.sh script)
        group="jdgroup"

        # Create the 'jdgroup' group with the wanted group GID
        log "Create group 'jdgroup' (GID '$setupUserAndGroup_gid')"
        createGroup $group $setupUserAndGroup_gid $setupUserAndGroup_os
    fi

    # Set default user (set the '$user' variable declared in the docker-entrypoint.sh script)
    user="jduser"

    # Create the 'jduser' user with the wanted user UID and group GID as primary group
    log "Create user 'jduser' (UID '$setupUserAndGroup_uid') with primary group '$group' (GID '$setupUserAndGroup_gid')"
    createUser jduser $setupUserAndGroup_uid $group $setupUserAndGroup_gid $setupUserAndGroup_os
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
            sleep 1
            sleepExitCode=$?

            if [ $sleepExitCode -ne 0 ]
            then
                fatal "sleep exited with code '$sleepExitCode'"
            fi
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
