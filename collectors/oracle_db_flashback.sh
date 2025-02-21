#!/bin/bash
SID="$DB_SID"

# Query to check flashback status
DB_flashback_Status=$(su - oracle -c "export ORACLE_SID=$SID; export ORACLE_BASE=/oracle/$SID; export ORACLE_HOME=/oracle/$SID/19; export LD_LIBRARY_PATH=/oracle/$SID/19/lib; export PATH=/oracle/$SID/19:/oracle/$SID/19/bin:$PATH; export TNS_ADMIN=/oracle/$SID/19/network/admin; echo 'SELECT FLASHBACK_ON FROM V\$DATABASE;' | sqlplus -S / as sysdba")

# Check the output for 'YES' or 'NO' to determine the status
if [[ $DB_flashback_Status == *"YES"* ]]; then
    printf 'Oracle Database flashback = %s\n' "ON"
elif [[ $DB_flashback_Status == *"NO"* ]]; then
    printf 'Oracle Database flashback = %s\n' "OFF"
else
    printf 'Oracle Database flashback = %s\n' "Not Found"
fi