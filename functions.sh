#!/bin/bash

# Useful functions

logIndent=0

# Log
log()
{
    echo "$(date -I'seconds')| $(printf %$((2*logIndent))s)$@" >&2
}

# Group (log and increment indent)
group()
{
    log $@
    ((logIndent++))
}

# Decrement indent
groupEnd()
{
    ((logIndent>0 ? logIndent-- : (logIndent=0)))
}

# Reset indent
groupReset()
{
    ((logIndent=0))
}

# Fatal error occured : log and exit
fatal()
{
    fatal_exitCode="$1"
    fatal_log="$2"

    log "FATAL ERROR :" "$fatal_log"
    log "Get more informations here : https://github.com/antlafarge/jdownloader#troubleshooting"
    groupEnd
    log "CONTAINER TERMINATED"
    exit ${fatal_exitCode:-1}
}

# Wait for many processes to terminate
waitProcess()
{
    waitProcess_pids=$@

    # Wait processes
    if ! wait $waitProcess_pids 2> /dev/null; then
        # If a pid is not a child process
        # Wait processes with a sleep loop
        while kill -0 $waitProcess_pids 2> /dev/null; do
            sleep 1
            sleepExitCode=$?

            if [ $sleepExitCode -ne 0 ]; then
                fatal "sleep exited with code \"$sleepExitCode\""
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

# Handle signal
handleSignal()
{
    handleSignal_signalCode=$1
    log "Kill signal \"$handleSignal_signalCode\" received"
    if [ -n "$pid" ]; then # If java process found
        stop=true
        killProcess $pid
    else
        groupEnd
        log "CONTAINER KILLED"
        exit $((128 + $handleSignal_signalCode))
    fi
}

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

    if [ $sedExitCode -ne 0 ]; then
        log "ERROR" "sed exited with code \"$sedExitCode\""
        exit $sedExitCode
    fi
}
