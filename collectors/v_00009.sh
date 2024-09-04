#!/bin/bash
rdisp_wp_no_spo=$(grep -E 'rdisp/wp_no_spo' /sapmnt/RBT/profile/RBT_D00_robotest | awk -F ' = ' '{print $2}')
if [[ -z "$rdisp_wp_no_spo" ]]; then
    printf 'rdisp/wp_no_spo="Parameter not found"\n'
else
    printf 'rdisp/wp_no_spo=%s\n' "$rdisp_wp_no_spo"
fi

