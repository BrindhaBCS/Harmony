#!/bin/bash
exists_param=$(grep -E 'enable unicode normalization' /sybase/RBT/ASE-16_0/RBT.cfg | awk -F '=' '{print $2}' | xargs)
#if [[ -z "$exists_param" ]]; then
#    printf 'exists_param="does_not_exist"\n'
#else
#    printf 'exists_param="exists"\n'
#fi
printf 'exists_param=%s\n' "$exists_param"
