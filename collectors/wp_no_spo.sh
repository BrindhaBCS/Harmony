#!/bin/bash

SID="$SAP_SID"
inst_no="$app_inst_no"
host="$app_host"

param="rdisp/wp_no_spo"
profile1="/sapmnt/${SID}/profile/${SID}_DVEBMGS${inst_no}_${host}"
profile2="/sapmnt/${SID}/profile/${SID}_D${inst_no}_${host}"

wp_check_1=$(grep -E "^${param}[[:space:]]*=" "$profile1" 2>/dev/null | awk -F'=' '{print $2}' | tr -d ' ')
if [[ -z "$wp_check_1" ]]; then
    wp_check_2=$(grep -E "^${param}[[:space:]]*=" "$profile2" 2>/dev/null | awk -F'=' '{print $2}' | tr -d ' ')
    if [[ -z "$wp_check_2" ]]; then
        printf '%s = "Parameter not found"\n' "$param"
    else
        printf '%s = %s\n' "$param" "$wp_check_2"
    fi
else
    printf '%s = %s\n' "$param" "$wp_check_1"
fi
