#!/bin/bash
#expected_keepalive_time=120
param="net.ipv4.tcp_keepalive_time"
# Get the current value
current_value=$(sysctl -n "$param" 2>/dev/null)

if [[ -z "$current_value" ]]; then
    echo "$param = Parameter Not Found"
#elif [[ "$current_value" -eq "$expected_keepalive_time" ]]; then
    #echo "$param = $current_value"
else
    echo "$param = $current_value"
fi
#expected value for ASCS, ERS, APP = 120
