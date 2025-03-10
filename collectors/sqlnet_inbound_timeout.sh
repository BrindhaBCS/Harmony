#!/bin/bash
SID="$SAP_SID"
parameter="SQLNET.INBOUND_CONNECT_TIMEOUT"
sql_file="/sapmnt/${SID}/profile/oracle/sqlnet.ora"

# Extract the actual value (ignoring case)
ACTUAL_TIMEOUT=$(grep -i "^$parameter" "$sql_file" 2>/dev/null | awk -F '=' '{print $2}' | tr -d ' ')

if [ -z "$command_output" ]; then
    printf "%s = Not found\n" "$parameter_name"
else
    printf "%s = %s\n" "$parameter_name" "$command_output"
fi
