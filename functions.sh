#!/bin/bash

# This script defines the shared functions

# Log
log()
{
    echo "$(date -I'seconds')| $@" >&2
}

# sleep workaround
## On linux/arm/v7 systems, docker containers with insufficient permissions can generate this error :
## "sleep: cannot read realtime clock: Operation not permitted"
sleepWorkaround()
{
    seconds=$1

    if [[ ! $useSleepWorkaround ]]
    then
        sleep $seconds 2> /dev/null # sleep
        sleepRes=$?
        if [ $sleepRes -eq 0 ] # If normal sleep succeed
        then
            return 0 # We exit
        else
            log "WARNING" "Sleep failed : Switching to sleep workaround"
            useSleepWorkaround=true # Else we switch to sleep workaround
        fi
    fi

    coproc read -t $seconds && wait "$!" || true
}

# Wait for a process to stop
waitProcess()
{
    pid=$1

    # Wait process to stop
    while kill -0 "$pid" 2> /dev/null
    do
        # sleep 1
        sleepWorkaround 1
    done
}
