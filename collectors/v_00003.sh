#!/bin/bash
cpu=$(lscpu | awk '/^CPU\(s\)/{print $2}')
if [[ -z "$cpu" ]]; then
    printf 'cpu="Parameter not found"\n'
else
    printf 'cpu=%s\n' "$cpu"
fi

