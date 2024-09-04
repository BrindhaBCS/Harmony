#!/bin/bash

# Get the parameter value for 'rdisp/wp_no_vb' using precise regex to avoid matching 'rdisp/wp_no_vb2'
rdisp_wp_no_vb=$(grep -E '^rdisp/wp_no_vb[[:space:]]*=' /sapmnt/RBT/profile/RBT_D00_robotest | awk -F ' = ' '{print $2}')

# Conditional check and printing the result
if [[ -z "$rdisp_wp_no_vb" ]]; then
    printf 'rdisp/wp_no_vb="Parameter not found"\n'
else
    printf 'rdisp/wp_no_vb=%s\n' "$rdisp_wp_no_vb"
fi

exit 0

