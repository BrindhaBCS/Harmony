#!/bin/bash

USER="${SAP_SID,,}adm"
instance_no="$ascs_inst_no"

HAActive=$(su - "$USER" -c "sapcontrol -nr $instance_no -function HAGetFailoverConfig" 2>&1 | awk -F': ' '/HAActive/ {print $2}')

if [[ -z "$HAActive" ]]; then
    printf 'HAActive = "not found"\n'
else
    printf 'HAActive = %s\n' "$HAActive"
fi