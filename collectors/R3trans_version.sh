#!/bin/bash
#updated by murugan for harmony github public repo test

USER="${SAP_SID,,}adm"

R3trans_version=$(su - "$USER" -c "R3trans -v" 2>&1 | awk '/This is R3trans version/ {print $5}')

if [[ -z "$R3trans_version" ]]; then
    printf 'R3trans version = "not found"\n'
else
    printf 'R3trans version = %s\n' "$R3trans_version"

fi
