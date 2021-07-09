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
    log "_________________________________________ CONTAINER EXITED _________________________________________"
    exit 1
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
