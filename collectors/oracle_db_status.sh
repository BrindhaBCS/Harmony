#!/bin/bash
USER="ora${DB_SID,,}"
#USER="oragtq"
DB_STATUS=$(su - $USER -c "echo 'SELECT status FROM v\$instance;' | sqlplus -s / as sysdba" | grep -E 'OPEN|MOUNTED|STARTED')
# Check if the database is running
if [[ -z "$DB_STATUS" ]]; then
    echo "Oracle Database Status = DOWN"
else
    echo "Oracle Database Status = RUNNING"
fi