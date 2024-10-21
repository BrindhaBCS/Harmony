#!/bin/bash
rdisp_wp_no_dia=$(grep -E 'rdisp/wp_no_dia' /sapmnt/RBT/profile/RBT_D00_robotest | awk -F ' = ' '{print $2}')
if [[ -z "$rdisp_wp_no_dia" ]]; then
    printf 'rdisp/wp_no_dia="Parameter not found"\n'
else
    printf 'rdisp/wp_no_dia=%s\n' "$rdisp_wp_no_dia"
fi

