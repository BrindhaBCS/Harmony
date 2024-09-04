#!/bin/bash
does_not_exist_param=$(grep -E 'does_not_exist_param' /sybase/RBT/ASE-16_0/RBT.cfg | awk -F '=' '{print $2}' | xargs)
printf 'does_not_exist_param=%s\n' "$does_not_exist_param"
#if [[ -z "$does_not_exist_param" ]]; then
#    printf 'does_not_exist_param="does_not_exist"\n'
#else
#    printf 'does_not_exist_param="exists"\n'
#fi


