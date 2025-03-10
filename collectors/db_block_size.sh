#!/bin/bash
SID="$DB_SID"
parameter="db_block_size"
init_file="/oracle/${SID}/19/dbs/init.ora"

block_size_check=$(grep -i "^[[:space:]]*$parameter" $init_file | awk -F'=' '{gsub(/[[:space:]]*/, "", $2); print $2}')

if [ -z "$command_output" ]; then
    printf "%s = Not found\n" "$parameter_name"
else
    printf "%s = %s\n" "$parameter_name" "$command_output"
fi
