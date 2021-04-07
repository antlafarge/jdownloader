#!/bin/bash

# This script defines the shared functions

# Log
log()
{
    echo "$(date -I'seconds')| $@" >&2
}
