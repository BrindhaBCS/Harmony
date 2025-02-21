#!/bin/bash
# Define the expected value and parameter
SID="$SAP_SID"
expected_value=120
parameter="SQLNET.INBOUND_CONNECT_TIMEOUT"
sql_file="/sapmnt/${SID}/profile/oracle/sqlnet.ora"

# Extract the actual value (ignoring case)
ACTUAL_TIMEOUT=$(grep -i "^$parameter" "$sql_file" 2>/dev/null | awk -F '=' '{print $2}' | tr -d ' ')

# Check if the configuration file exists
if [ ! -f "$sql_file" ] || [ -z "$ACTUAL_TIMEOUT" ]; then
    echo "$parameter" = "parameter not found or file missing"

else
    if [ "$ACTUAL_TIMEOUT" -eq "$expected_value" ]; then
        echo "$parameter" = "$ACTUAL_TIMEOUT"
    else
        echo "$parameter" = "$ACTUAL_TIMEOUT (expected value = $expected_value)"
    fi
fi