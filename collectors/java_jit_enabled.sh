#!/bin/bash
USER="ora${DB_SID,,}"
#USER="oragtq"
parameter_name=java_jit_enabled

command_output=$(su - "$USER" -c "echo 'show parameter $parameter_name' | sqlplus -s / as sysdba | awk '\$1 == \"$parameter_name\" {print \$3}'")

#expected output "TRUE or FALSE"

if [[ -z "$command_output" ]]; then
    echo "$parameter_name = Not found"
else
    echo "$parameter_name = $command_output"
fi