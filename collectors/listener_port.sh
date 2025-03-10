#!/bin/bash
SID="$SAP_SID"
parameter="LISTENER_PORT"
tns_file="/sapmnt/${SID}/profile/oracle/tnsnames.ora"

command_output=$(grep -i 'PORT' $tns_file | awk -F'PORT *= *' '{print $2}' | awk -F')' '{print $1}')

if [ -z "$command_output" ]; then
    printf "%s = Not found\n" "$parameter_name"
else
    printf "%s = %s\n" "$parameter_name" "$command_output"
fi
