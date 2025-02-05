#!/bin/bash

# Set filesystem usage thresholds
#fs_warning_threshold=85
fs_error_threshold=90

# Define HANA data mount point
mount="$filesystem"

# Get filesystem usage percentage (excluding % sign)
usage=$(df -h "$mount" 2>/dev/null | awk 'NR==2 {print $5}' | tr -d '%')

# Check if usage is empty (in case the mount doesn't exist)
if [[ -z "$usage" ]]; then
    echo "$mount filesystem usage in % = NOT FOUND"
else
    if (( usage >= fs_error_threshold )); then
        echo "$mount filesystem usage in % = Critical ${usage}% used"
    #elif (( usage >= fs_warning_threshold )); then
        #echo "$hana_data_mount filesystem in % = Warning ${usage}% used"
    else
        echo "$mount filesystem usage in % = ${usage}"
    fi
fi
