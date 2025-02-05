#!/bin/bash

# Set CPU usage thresholds
cpu_warning_threshold=75
cpu_error_threshold=90

# Get CPU usage (user + system)
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')

# Convert CPU usage to an integer (rounding is optional)
cpu_usage_int=$(printf "%.0f" "$cpu_usage")

# Determine CPU status
if (( cpu_usage_int >= cpu_error_threshold )); then
    echo "CPU usage status in % = Critical "$cpu_usage_int"% used"
elif (( cpu_usage_int >= cpu_warning_threshold )); then
    echo "CPU usage status in % = Warning "$cpu_usage_int"% used"
else
    echo "CPU usage status in % = "$cpu_usage_int""
fi