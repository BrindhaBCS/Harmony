#!/bin/bash
USER="ora${DB_SID,,}"
#USER="oragtq"
parameter_name=control_file_record_keep_time

command_output=$(su - "$USER" -c "echo 'show parameter $parameter_name' | sqlplus -s / as sysdba | awk '\$1 == \"$parameter_name\" {print \$3}'")

#expected output numerical value eg:30

if [[ -z "$command_output" ]]; then
    echo "$parameter_name = Not found"
else
    echo "$parameter_name = $command_output"
fi