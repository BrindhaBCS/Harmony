#!/bin/bash
expected_keepalive_probes=9
param="net.ipv4.tcp_keepalive_probes"
# Get the current value
current_value=$(sysctl -n "$param" 2>/dev/null)
if [[ -z "$current_value" ]]; then
    echo "$param = Parameter Not Found"
    
elif [[ "$current_value" -eq "$expected_keepalive_probes" ]]; then
    echo "$param = $current_value"
else
    echo "$param = $current_value (expected value $expected_keepalive_probes)"
fi