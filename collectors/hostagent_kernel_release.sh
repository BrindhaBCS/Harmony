#!/bin/bash

USER="${SAP_SID,,}adm"

hostagent_kernel_release=$(/usr/sap/hostctrl/exe/saphostctrl -function ExecuteOperation -name versioninfo 2>/dev/null |  grep -i "kernel release" | awk '{print $NF}')

if [[ -z "$hostagent_kernel_release" ]]; then
    printf 'hostagent kernel release = "not found"\n'
else
    printf 'hostagent kernel release = %s\n' "$hostagent_kernel_release"
fi