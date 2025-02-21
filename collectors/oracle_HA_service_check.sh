#!/bin/bash
SID="$DB_SID"
HA_sevice_name="$haservicename"   #BCS-HA

service_check1=$(su - oracle -c "export ORACLE_SID=${SID}; export ORACLE_BASE=/oracle/${SID}; export ORACLE_HOME=/oracle/${SID}/19; export LD_LIBRARY_PATH=/oracle/${SID}/19/lib; export PATH=/oracle/${SID}/19:/oracle/${SID}/19/bin:$PATH; export TNS_ADMIN=/oracle/${SID}/19/network/admin; echo \"SELECT NAME, NETWORK_NAME, CREATION_DATE FROM DBA_SERVICES WHERE NAME = '$HA_sevice_name';\" | sqlplus -S / as sysdba")

if [[ "$service_check1" =~ "$HA_sevice_name" ]]; then
    
    service_check2=$(su - oracle -c "export ORACLE_SID=${SID}; export ORACLE_BASE=/oracle/${SID}; export ORACLE_HOME=/oracle/${SID}/19; export LD_LIBRARY_PATH=/oracle/${SID}/19/lib; export PATH=/oracle/${SID}/19:/oracle/${SID}/19/bin:$PATH; export TNS_ADMIN=/oracle/${SID}/19/network/admin; echo \"SELECT COUNT(*) FROM DBA_SERVICES WHERE NAME = '$HA_sevice_name';\" | sqlplus -S / as sysdba")
    if [[ $service_check2 == *"0"* ]]; then
        printf 'Oracle HA Service Status = %s\n' "Inactive"
    else
        printf 'Oracle HA Service Status = %s\n' "Active"
    fi
else
    printf 'Oracle HA Service Status = %s\n' "$HA_sevice_name not found"
fi
