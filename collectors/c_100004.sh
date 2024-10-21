#!/bin/bash
uname_info=$(uname -a)
if [[ -z "$uname_info" ]]; then
    printf 'uname="Parameter not found"\n'
else
    printf 'uname="%s"\n' "$uname_info"
fi

