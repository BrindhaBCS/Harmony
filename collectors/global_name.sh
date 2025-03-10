#!/bin/bash
SID="$SAP_SID"
parameter="GLOBAL_NAME"
tns_file="/sapmnt/${SID}/profile/oracle/tnsnames.ora"

global_name_check=$(grep -i 'GLOBAL_NAME' $tns_file | awk -F'GLOBAL_NAME *= *' '{print $2}' | awk -F')' '{print $1}')

if [ -z "$global_name_check" ]; then
    echo "$parameter" = "parameter not found"
else
    echo "$parameter" = "$global_name_check"

fi