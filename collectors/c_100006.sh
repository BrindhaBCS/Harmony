#!/bin/bash
rdisp_wp_no_btc=$(grep -E 'rdisp/wp_no_btc' /sapmnt/RBT/profile/RBT_D00_robotest | awk -F ' = ' '{print $2}')
if [[ -z "$rdisp_wp_no_btc" ]]; then
    printf 'rdisp/wp_no_btc="Parameter not found"\n'
else
    printf 'rdisp/wp_no_btc=%s\n' "$rdisp_wp_no_btc"
fi

