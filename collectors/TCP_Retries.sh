#!/bin/bash

if [[ "$servertype" == "app" ]] || [[ "$servertype" == "ascs" ]] || [[ "$servertype" == "ers" ]]; then
    expected_tcp_retries2=8
else
    expected_tcp_retries2=15
fi

param="net.ipv4.tcp_retries2"
param_name="TCP Retries"

# Get the current value
current_value=$(sysctl -n "$param" 2>/dev/null)

if [[ -z "$current_value" ]]; then
    echo "$param_name = Parameter Not Found"
    
elif [[ "$current_value" -eq "$expected_tcp_retries2" ]]; then
    echo "$param_name = $current_value"
else
    echo "$param_name = $current_value"
fi