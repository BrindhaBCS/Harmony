#!/bin/bash

# Set RAM usage thresholds
ram_warning_threshold=75
ram_error_threshold=90

# Get memory info in MB
memory_info=$(free -m)

# Extract total, used, and free memory
total_memory=$(echo "$memory_info" | awk 'NR==2 {print $2}')
used_memory=$(echo "$memory_info" | awk 'NR==2 {print $3}')

# Calculate memory usage percentage (using bc for precision)
memory_usage_percentage=$(echo "scale=2; $used_memory * 100 / $total_memory" | bc)

# Determine RAM status
if (( $(echo "$memory_usage_percentage >= $ram_error_threshold" | bc -l) )); then
    echo "RAM memory usage = Critical $memory_usage_percentage% used"
elif (( $(echo "$memory_usage_percentage >= $ram_warning_threshold" | bc -l) )); then
    echo "RAM memory usage = Warning $memory_usage_percentage% used"
else
    echo "RAM memory usage = Normal"
fi
