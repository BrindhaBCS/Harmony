#!/bin/bash

# Define the Oracle profile location
PROFILE_PATH="/usr/sap/TS3/SYS/profile/DEFAULT.PFL"

# Expected value for dbms/type
EXPECTED_DBMS_TYPE="ora"

# Check if the profile file exists
if [ -f "$PROFILE_PATH" ]; then
    # Get the current value of the 'dbms/type' parameter
    DBMS_TYPE_VALUE=$(grep -i "^dbms/type" "$PROFILE_PATH" | awk -F= '{print $2}' | tr -d '[:space:]')

    # Compare the current value with the expected value
    if [ "$DBMS_TYPE_VALUE" == "$EXPECTED_DBMS_TYPE" ]; then
        echo "dbms/type is correctly set to = $EXPECTED_DBMS_TYPE"
    else
        echo "dbms/type is not set to = $EXPECTED_DBMS_TYPE (current value = $DBMS_TYPE_VALUE)"
    fi
else
    echo "Profile file not found = $PROFILE_PATH"
fi
