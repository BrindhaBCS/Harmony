#!/bin/bash

# Pass the expected timezone as an argument
EXPECTED_TIMEZONE=$1

# Get the current timezone
CURRENT_TIMEZONE=$(timedatectl | grep "Time zone" | awk '{print $3}')

# Compare with the expected timezone
if [[ "$CURRENT_TIMEZONE" == "$EXPECTED_TIMEZONE" ]]; then
    echo "Time zone correct = $CURRENT_TIMEZONE"
else
    echo "Time zone not correct = $CURRENT_TIMEZONE (Expected: $EXPECTED_TIMEZONE)"
fi
