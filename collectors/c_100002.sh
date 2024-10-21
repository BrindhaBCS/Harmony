#!/bin/bash
ram=$(free -g | awk '/^Mem:/{print $2}')
if [[ -z "$ram" ]]; then
    printf 'ram="Parameter not found"\n'
else
    printf 'ram=%s\n' "$ram"
fi

