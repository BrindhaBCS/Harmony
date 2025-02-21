#!/bin/bash

SID="${DB_SID}"
priservicename="${primaryservicename}"

# Run the DGMGRL command as Oracle user
command_output=$(su - oracle -c "/oracle/${SID}/19.0.0/bin/dgmgrl /@$priservicename AS SYSDBA \"show configuration\"")

# Check for SUCCESS or WARNING in the output
if [[ "$command_output" =~ .*"SUCCESS".* ]]; then
    printf 'DG Status in Obs = %s\n' "Success"
elif [[ "$command_output" =~ .*"WARNING".* ]]; then
	printf 'DG Status in Obs = %s\n' "Warning"
else
    printf 'DG Status in Obs = %s\n' "Error"
fi