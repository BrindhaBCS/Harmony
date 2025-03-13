#!/bin/bash
SID="$DB_SID"
parameter_name="db_block_size"
oraversion="$ora_version"    #19,121
init_file="/oracle/${SID}/${oraversion}/dbs/init.ora"

command_output=$(grep -i "^[[:space:]]*$parameter" $init_file | awk -F'=' '{gsub(/[[:space:]]*/, "", $2); print $2}')

if [ -z "$command_output" ]; then
    printf "%s = Not found\n" "$parameter_name"
else
    printf "%s = %s\n" "$parameter_name" "$command_output"
fi
