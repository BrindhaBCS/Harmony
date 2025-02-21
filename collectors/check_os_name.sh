#!/bin/bash
os_file='/etc/os-release'

if [[ -f "$os_file" ]]; then
    os_name=$(grep '^NAME=' "$os_file" | cut -d= -f2 | tr -d '"')
    echo "OS_Name=$os_name"
else
    echo "OS_Name=Unknown"
fi