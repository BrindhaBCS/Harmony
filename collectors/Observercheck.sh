#!/bin/bash
SID="$DB_SID"
priservicename="$primaryservicename"

# Run the DGMGRL command as Oracle user
command_output=$(su - oracle -c "/oracle/${SID}/19.0.0/bin/dgmgrl /@$priservicename AS SYSDBA \"show observer\"")

# Check for SUCCESS or WARNING in the output
if [[ "$command_output" =~ .*"sec".* ]]; then
    printf 'Observer status = %s\n' "Success"
else
    printf 'Observer status = %s\n' "Error"
fi