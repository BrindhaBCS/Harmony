#!/bin/bash
enable_unicode_normalization=$(grep -E 'enable unicode normalization' /sybase/RBT/ASE-16_0/RBT.cfg | awk -F '=' '{print $2}' | xargs)
if [[ -z "$enable_unicode_normalization" ]]; then
    printf 'enable_unicode_normalization="Parameter not found"\n'
else
    printf 'enable_unicode_normalization=%s\n' "$enable_unicode_normalization"
fi

