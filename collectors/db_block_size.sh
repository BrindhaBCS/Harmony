#!/bin/bash
SID="$DB_SID"
parameter="db_block_size"
init_file="/oracle/${SID}/19/dbs/init.ora"

block_size_check=$(grep -i "^[[:space:]]*$parameter" $init_file | awk -F'=' '{gsub(/[[:space:]]*/, "", $2); print $2}')

if [ -z "$block_size_check" ]; then
    echo "$parameter" = "parameter not found"
else
    echo "$parameter" = "$block_size_check"
fi
