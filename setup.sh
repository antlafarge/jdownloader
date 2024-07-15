#!/bin/bash

# This script set up JDownloader

# Disable bash history substitution
set +H

source functions.sh

# Get variables from arguments
email="$1"
password="$2"
devicename="$3"

# Execute setup
setup "$email" "$password" "$devicename"
