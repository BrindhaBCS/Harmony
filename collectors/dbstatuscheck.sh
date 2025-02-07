#!/bin/bash

# Switch to h2padm user and run sapcontrol to get the process list
su - h2padm -c "sapcontrol -nr 00 -function GetProcessList" > /tmp/sapcontrol_output.txt

# Process names to check
PROCESS_LIST=("hdbdaemon" "hdbcompileserver" "hdbindexserver" "hdbnameserver" "hdbpreprocessor" "hdbwebdispatcher" "hdbxsengine")

# Initialize flag for DB status
DB_STATUS="Green"

# Loop through process list and check status
for process in "${PROCESS_LIST[@]}"
do
    # Check if the process exists in the sapcontrol output and is marked as GREEN
    PROCESS_STATUS=$(grep "$process" /tmp/sapcontrol_output.txt | grep -i "GREEN")
    
    if [ -z "$PROCESS_STATUS" ]; then
        DB_STATUS="Red"
        break  # Exit the loop as soon as we find an issue
    fi
done

# Output overall DB status
if [ "$DB_STATUS" == "Green" ]; then
    echo "Hana DB Status = Green"
else
    echo "Hana DB Status = Red"
fi

# Clean up the temp file
rm /tmp/sapcontrol_output.txt

