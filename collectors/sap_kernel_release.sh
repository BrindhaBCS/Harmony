#!/bin/bash

USER="${SAP_SID,,}adm"

sap_kernel_release=$(su - "$USER" -c "disp+work -version" 2>&1 | grep -oP 'kernel release\s+\K[0-9]+')

if [[ -z "$sap_kernel_release" ]]; then
    printf 'SAP kernel release = "not found"\n'
else
    printf 'SAP kernel release = %s\n' "$sap_kernel_release"
fi