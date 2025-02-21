#!/bin/bash
SID="$DB_SID"

DB_Status=$(su - oracle -c "export ORACLE_SID=${SID}; export ORACLE_BASE=/oracle/${SID}; export ORACLE_HOME=/oracle/${SID}/19; export LD_LIBRARY_PATH=/oracle/${SID}/19/lib; export PATH=/oracle/${SID}/19:/oracle/${SID}/19/bin:$PATH; export TNS_ADMIN=/oracle/${SID}/19/network/admin; echo 'select database_role, open_mode from v\$database;' | sqlplus -S / as sysdba")

if [[ $DB_Status == *"PRIMARY"* ]]; then
    printf 'oracle Database role = %s\n' "PRIMARY"
elif [[ $DB_Status == *"PHYSICAL STANDBY"* ]]; then
    printf 'oracle Database role = %s\n' "PHYSICAL STANDBY"
else
    printf 'oracle Database role = %s\n' "Not Found"
fi