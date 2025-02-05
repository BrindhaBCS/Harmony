#!/bin/bash
#ORACLE_USER="ora${ORACLE_SID,,}"
ORACLE_USER="orats3"
DB_STATUS=$(su - $ORACLE_USER -c "echo 'SELECT status FROM v\$instance;' | sqlplus -s / as sysdba" | grep -E 'OPEN|MOUNTED|STARTED')
# Check if the database is running
if [[ -z "$DB_STATUS" ]]; then
    echo "Oracle Database Status = DOWN"
else
    echo "Oracle Database Status = RUNNING"
fi
