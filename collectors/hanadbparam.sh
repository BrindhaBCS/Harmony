#!/bin/bash

# Define the SAP HANA instance profile location
HANA_SID="H2P"                  # Your SAP HANA SID
INSTANCE="HDB00"                # Your instance name
HOSTNAME="azlsaph2pdb02"        # Your host name
PROFILE_PATH="/usr/sap/$HANA_SID/SYS/profile/${HANA_SID}_${INSTANCE}_$HOSTNAME"

# Expected value for Autostart
EXPECTED_AUTOSTART="0"

# Check if the profile file exists
if [ -f "$PROFILE_PATH" ]; then
    # Get the current value of the 'Autostart' parameter
    AUTOSTART_VALUE=$(grep -i "Autostart" "$PROFILE_PATH" | awk -F= '{print $2}' | tr -d '[:space:]')

    # Compare the current value with the expected value
    if [ "$AUTOSTART_VALUE" -eq "$EXPECTED_AUTOSTART" ]; then
        echo "Autostart is already set to = $EXPECTED_AUTOSTART."
    else
        echo "Autostart is not set to = $EXPECTED_AUTOSTART (current value: $AUTOSTART_VALUE)."
    fi
else
    echo "Profile file not found: $PROFILE_PATH"
fi

