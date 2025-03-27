#!/bin/bash

hostagent_kernel_patch=$(/usr/sap/hostctrl/exe/saphostctrl -function ExecuteOperation -name versioninfo 2>/dev/null |  grep -i "patch number" | awk '{print $NF}')

if [[ -z "$hostagent_kernel_patch" ]]; then
    printf 'hostagent kernel patch = "not found"\n'
else
    printf 'hostagent kernel patch = %s\n' "$hostagent_kernel_patch"
fi
