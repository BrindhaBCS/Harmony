#!/bin/bash
# Assigning passed arguments
SID="$SAP_SID"
inst_no="$cs_inst_no"
vir_host="$cs_vir_host"

cs_inst_profile="/sapmnt/${SID}/profile/${SID}_ASCS${inst_no}_${vir_host}"
param_to_check="enque/deque_wait_answer"
expected_value="TRUE"
current_value=$(grep "^$param_to_check" "$cs_inst_profile" | awk -F= '{print $2}' | tr -d ' ')

if [[ -z "$current_value" ]]; then
    echo "$param_to_check = Parameter Not Found"
elif [[ "$current_value" == "$expected_value" ]]; then
    echo "$param_to_check = $current_value"
else
    echo "$param_to_check = $current_value"
fi