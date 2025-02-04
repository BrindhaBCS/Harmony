#!/bin/bash

# Define the Oracle Linux release file path
OS_RELEASE_FILE="/etc/os-release"    # Path to the OS release file

# Check if the OS release file exists
if [ -f "$OS_RELEASE_FILE" ]; then
    # Get the PRETTY_NAME from the os-release file and remove the quotes
    PRETTY_NAME=$(grep "^PRETTY_NAME=" "$OS_RELEASE_FILE" | awk -F= '{print $2}' | tr -d '[:space:]' | sed 's/"//g')

    # Print the PRETTY_NAME without quotes
    echo "PRETTY_NAME = $PRETTY_NAME"
else
    echo "OS release file not found = $OS_RELEASE_FILE"
fi
