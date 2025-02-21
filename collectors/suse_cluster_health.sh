#!/bin/bash
# Check cluster health status
clu_status_failed=$(crm status | grep FAILED)
clu_status_stopped=$(crm status | grep -i stopped)
clu_status_unclean=$(crm status | grep -i unclean)

if [[ -z ${clu_status_failed} ]] && [[ -z ${clu_status_stopped} ]] && [[ -z ${clu_status_unclean} ]]; then
    printf 'Cluster health status = "HEALTHY"\n'
else
    nod_stand=$(crm status | grep standby | awk -F "Node " '{print $2}' | awk -F ":" '{print $1}')
    if [[ -z ${nod_stand} ]]; then
        printf 'Cluster health status = "NOT-OKAY"\n'
    else
        stand_stat=$(echo $clu_status_stopped | grep -v ${nod_stand})
        if [[ -z ${stand_stat} ]]; then
            printf 'Cluster health status = "STANDBY"\n'
        else
            printf 'Cluster health status = "NOT-OKAY"\n'
        fi
    fi
fi
#expected value = HEALTHY or NOT-OKAY or STANDBY