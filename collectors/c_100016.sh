#!/bin/bash
path="$1"
os_version=$(grep 'VERSION_ID' "$path" | cut -d '"' -f 2)
if [[ -z "$os_version" ]]; then
    printf 'os_version="Parameter not found"\n'
else
    printf 'os_version=%s\n' "$os_version"
fi