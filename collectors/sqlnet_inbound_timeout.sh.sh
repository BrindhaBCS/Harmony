#!/bin/bash
SID="$SAP_SID"
parameter="SQLNET.INBOUND_CONNECT_TIMEOUT"
sql_file="/sapmnt/${SID}/profile/oracle/sqlnet.ora"

# Extract the actual value (ignoring case)
ACTUAL_TIMEOUT=$(grep -i "^$parameter" "$sql_file" 2>/dev/null | awk -F '=' '{print $2}' | tr -d ' ')

if [ ! -f "$sql_file" ] || [ -z "$ACTUAL_TIMEOUT" ]; then
    echo "$parameter" = "parameter not found or file missing"
else
    echo "$parameter" = "$ACTUAL_TIMEOUT"
fi