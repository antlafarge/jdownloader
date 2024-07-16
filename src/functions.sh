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
    logIndent=0
}

# Fatal error occured : log and exit
fatal()
{
    local exitCode="$1"
    local log1="$2"
    local log2="$3"
    log "FATAL ERROR :" "$log1" "$log2"
    log "Get more informations here : https://github.com/antlafarge/jdownloader#troubleshooting"
    groupReset
    log "CONTAINER TERMINATED"
    exit ${exitCode:-1}
}

# Wait for many processes to terminate
waitProcess()
{
    local pids=$@
    # Wait processes
    if ! wait $pids 2> /dev/null; then
        # If a pid is not a child process
        # Wait processes with a sleep loop
        while kill -0 $pids 2> /dev/null; do
            sleep 1
            local exitCode=$?
            if [ $exitCode -ne 0 ]; then
                fatal $exitCode "sleep exited with code \"$exitCode\""
            fi
        done
    fi
}

# Kill many processes
killProcess()
{
    local pids=$@
    log "Send SIGTERM to process \"$pids\""
    kill -SIGTERM $pids 2> /dev/null
}

# Handle signal
handleSignal()
{
    local signalCode=$1
    log "Kill signal \"$signalCode\" received"
    if [ -n "$pid" ]; then # If java process found
        stop=true
        killProcess $pid
    else
        groupReset
        log "CONTAINER KILLED"
        exit $((128 + $signalCode))
    fi
}

# Install a file in a directory
installFile()
{
    local fileName="$1"
    local targetDir="$2"
    local targetFile="${targetDir}${fileName}"
    # Create directory if applicable
    if [ ! -d "$targetDir" ]; then
        log "Create directory \"$targetDir\""
        mkdir -p "$targetDir"
    fi
    # Copy file if applicable
    if [ ! -f "$targetFile" ]; then
        log "Install \"$targetFile\""
        cp "./$fileName" "$targetFile"
        local exitCode=$?
        if [ $exitCode -ne 0 ]; then
            log "ERROR :" "cp exited with code \"$exitCode\""
            return $exitCode
        fi
    fi
}

# Replace a JSON value by searching its field in a JSON file
# Usage : replaceJsonValue file field value
replaceJsonValue()
{
    local file=$1
    local field=$(printf "%s" "$2" | sed -e 's/\\/\\\\/g' -e 's/[]\/$*.^[]/\\&/g') # this field will be compared to a value from a json file, so we need to double escape the backslashes \\\\    And this field will be used in a sed regex, so we escape regex special characters ]\/$*.^[
    local newValue=$(printf "%s" "$3" | sed -e 's/[\/&]/\\&/g' -e 's/"/\\\\"/g') # this value will be used in a sed replace, so we escape replace special characters \/&    And this value will be stored in a json file, so finally we double escape the quotes \\\\"
    local fieldPart="\($field\)" # match the field
    local valuePart="\([^\\\"]\|\\\\.\)*" # match the value. This looks complicated because it can contain escaped quotes \" because of json format.
    local search="\"$fieldPart\"\s*:\s*\"$valuePart\""
    local replace="\"\1\":\"$newValue\""
    sed -i "s/$search/$replace/g" $file
    local exitCode=$?
    if [ $exitCode -ne 0 ]; then
        log "ERROR :" "sed exited with code \"$exitCode\""
        return $exitCode
    fi
}

# Download a file
downloadFile()
{
    local fileUrl="$1"
    local targetFile="$2"
    if [ ! -f "./$targetFile" ]; then
        log "Download \"$fileUrl\""
        curl -s -o "$targetFile" "$fileUrl"
        curlExitCode=$?
        if [ $curlExitCode -ne 0 ]; then
            log "ERROR :" "curl exited with code \"$curlExitCode\""
        fi
    fi
}
