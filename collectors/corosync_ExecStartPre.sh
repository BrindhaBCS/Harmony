#!/bin/bash
file="/etc/systemd/system/corosync.service.d/override.conf"
expected_value="/bin/sleep 60"
search_string="ExecStartPre=/bin/sleep 60"

if grep -qF "$search_string" "$file"; then
    # Check if systemctl reflects the expected ExecStartPre value
    if systemctl show corosync.service | grep -qF "$search_string"; then
        printf 'ExecStartPre = %s\n' "$expected_value"
    else
        printf 'ExecStartPre = %s\n' "Not set properly"
    fi
else
    printf 'ExecStartPre = %s\n' "Parameter not found"
fi

#use in ers and AsCS