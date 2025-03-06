#!/bin/bash

param="net.ipv4.tcp_keepalive_intvl"
# Get the current value
current_value=$(sysctl -n "$param" 2>/dev/null)
if [[ -z "$current_value" ]]; then
    echo "$param = Parameter Not Found"
else
    echo "$param = $current_value"
fi
