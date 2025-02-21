#!/bin/bash
os_file='/etc/os-release'
if [[ -f "$os_file" ]]; then
    os_version=$(grep '^VERSION_ID=' "$os_file" | cut -d= -f2 | tr -d '"')
    echo "OS_Version=$os_version"
else
    echo "OS_Version=Unknown"
fi