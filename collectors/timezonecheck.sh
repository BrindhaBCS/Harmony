#!/bin/bash
timezone=$(timedatectl | awk -F ': ' '/Time zone/ {print $2}')
if [[ -z "$timezone" ]]; then
    printf 'timezone="Parameter not found"\n'
else
    printf 'timezone=%s\n' "$timezone"
fi
#expected value America/New_York (EST, -0500)