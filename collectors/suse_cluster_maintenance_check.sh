#!/bin/bash
# Get cluster maintenance mode status
clust_status=$(crm configure show | awk -F "=" '/maintenance-mode/{gsub(/[[:space:]]|\\/, "", $2); print $2}')
# Check cluster maintenance mode status
if [[ "$clust_status" == "false" ]]; then
    printf 'cluster maintenance = "%s"\n' "$clust_status"
elif [[ "$clust_status" == "true" ]]; then
    printf 'cluster maintenance = "%s"\n' "$clust_status"
else
    printf 'cluster maintenance = "%s"\n' "Invalid maintenance mode"
fi
#expected value = true or false