#!/bin/bash
# Set filesystem usage thresholds
#fs_warning_threshold=80
fs_error_threshold=90
# Define HANA data mount point
hana_data_mount="/hana/data"
# Get filesystem usage percentage (excluding % sign)
usage=$(df -h "$hana_data_mount" 2>/dev/null | awk 'NR==2 {print $5}' | tr -d '%')
# Check if usage is empty (in case the mount doesn't exist)
if [[ -z "$usage" ]]; then
    echo "$hana_data_mount filesystem usage = NOT FOUND"
else
    if (( usage >= fs_error_threshold )); then
       echo "$hana_data_mount filesystem usage in % = Critical ${usage}% used"
    #elif (( usage >= fs_warning_threshold )); then
       #echo "$hana_data_mount filesystem usage = Warning ${usage}% used"
    else
       echo "$hana_data_mount filesystem usage in % = ${usage}"
    fi
fi
