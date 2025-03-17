#!/bin/bash
#checking HANA custom paramters in webdispatcher.ini
#Controls how often Web Dispatcher refreshes system settings from the backend.
#expected output "60" in secs

SID="$DB_SID"
parameter_name="wdisp/auto_refresh"
file_to_check="/usr/sap/${SID}/SYS/global/hdb/custom/config/webdispatcher.ini"

command_output=$(grep -E "^${parameter_name}[[:space:]]*=" "$file_to_check" 2>/dev/null | awk -F'=' '{print $2}' | awk '{print $1}')


if [ -z "$command_output" ]; then
    printf "%s = Not found\n" "$parameter_name"
else
    printf "%s = %s\n" "$parameter_name" "$command_output"
fi