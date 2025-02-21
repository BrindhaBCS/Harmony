#!/bin/bash
expected_tcp_retries2=8    #expected value =8 (for ASCS,ERS, APP),expected value =15 (for others)
param="net.ipv4.tcp_retries2"
param_name="TCP Retries"

# Get the current value
current_value=$(sysctl -n "$param" 2>/dev/null)

if [[ -z "$current_value" ]]; then
    echo "$param = Parameter Not Found"
    
elif [[ "$current_value" -eq "$expected_tcp_retries2" ]]; then
    echo "$param = $current_value"
else
    echo "$param = $current_value (expected value $expected_tcp_retries2)"
fi
