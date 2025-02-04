#!/bin/bash

# Set filesystem usage thresholds
fs_warning_threshold=85
fs_error_threshold=90

# Define Oracle TS3 mount point
oracle_ts3_mount="/oracle/TS3"

# Get filesystem usage percentage (excluding % sign)
usage=$(df -h "$oracle_ts3_mount" 2>/dev/null | awk 'NR==2 {print $5}' | tr -d '%')

# Check if usage is empty (in case the mount doesn't exist)
if [[ -z "$usage" ]]; then
    echo "$oracle_ts3_mount filesystem usage = NOT FOUND"
else
    if (( usage >= fs_error_threshold )); then
        echo "$oracle_ts3_mount filesystem usage = Critical ${usage}% used"
    elif (( usage >= fs_warning_threshold )); then
        echo "$oracle_ts3_mount filesystem usage = Warning ${usage}% used"
    else
        echo "$oracle_ts3_mount filesystem usage = OK"
    fi
fi

