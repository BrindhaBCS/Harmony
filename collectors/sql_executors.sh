#!/bin/bash
#checking HANA custom paramters in nameserver.ini
#maximum number of threads (executors) available for executing SQL queries in SAP HANA.
#expected output "5 or above"

SID="$DB_SID"
parameter_name="sql_executors"
file_to_check="/usr/sap/${SID}/SYS/global/hdb/custom/config/nameserver.ini"

command_output=$(grep -E "^${parameter_name}[[:space:]]*=" "$file_to_check" 2>/dev/null | awk -F'=' '{print $2}' | awk '{print $1}')


if [ -z "$command_output" ]; then
    printf "%s = Not found\n" "$parameter_name"
else
    printf "%s = %s\n" "$parameter_name" "$command_output"
fi