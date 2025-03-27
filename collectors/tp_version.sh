#!/bin/bash

USER="${SAP_SID,,}adm"

tp_version=$(su - "$USER" -c "tp -v" 2>&1 | awk '/This is tp version/ {print $5}')

if [[ -z "$tp_version" ]]; then
    printf 'tp version = "not found"\n'
else
    printf 'tp version = %s\n' "$tp_version"
fi