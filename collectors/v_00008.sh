#!/bin/bash
rdisp_wp_no_vb2=$(grep -E 'rdisp/wp_no_vb2' /sapmnt/RBT/profile/RBT_D00_robotest | awk -F ' = ' '{print $2}')
if [[ -z "$rdisp_wp_no_vb2" ]]; then
    printf 'rdisp/wp_no_vb2="Parameter not found"\n'
else
    printf 'rdisp/wp_no_vb2=%s\n' "$rdisp_wp_no_vb2"
fi

