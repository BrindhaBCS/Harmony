#!/bin/bash
SID="$SAP_SID"
parameter="LISTENER_PORT"
tns_file="/sapmnt/${SID}/profile/oracle/tnsnames.ora"

Port_check=$(grep -i 'PORT' $tns_file | awk -F'PORT *= *' '{print $2}' | awk -F')' '{print $1}')

if [ -z "$Port_check" ]; then
    echo "$parameter" = "parameter not found"
else
    echo "$parameter" = "$Port_check"

fi