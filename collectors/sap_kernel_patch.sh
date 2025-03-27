#!/bin/bash

USER="${SAP_SID,,}adm"

sap_kernel_patch=$(su - "$USER" -c "disp+work -version" 2>&1 | grep -oP 'patch number\s+\K[0-9]+')

if [[ -z "$sap_kernel_patch" ]]; then
    printf 'SAP kernel patch = "not found"\n'
else
    printf 'SAP kernel patch = %s\n' "$sap_kernel_patch"
fi