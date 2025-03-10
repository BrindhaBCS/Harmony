#!/bin/bash
USER="ora${DB_SID,,}"
#USER="oragtq"
parameter_name=shared_pool_size

command_output=$(su - "$USER" -c "echo 'show parameter $parameter_name' | sqlplus -s / as sysdba | awk '\$1 == \"$parameter_name\" {print \$4}'")

#expected output "4352M"

if [[ -z "$command_output" ]]; then
    echo "$parameter_name = Not found"
else
    echo "$parameter_name = $command_output"
fi