#!/bin/bash
enable_unicode_conversions=$(grep -E 'enable unicode conversions' /sybase/RBT/ASE-16_0/RBT.cfg | awk -F '=' '{print $2}' | xargs)
if [[ -z "$enable_unicode_conversions" ]]; then
    printf 'enable_unicode_conversions="Parameter not found"\n'
else
    printf 'enable_unicode_conversions=%s\n' "$enable_unicode_conversions"
fi

