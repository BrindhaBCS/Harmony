#!/bin/bash

# Pass the expected timezone as an argument
TIMEZONE=$1

# Get the current timezone
CURRENT_TIMEZONE=$(timedatectl | grep "Time zone" | awk '{print $3}')

# Compare with the provided timezone
if [[ "$CURRENT_TIMEZONE" == "$TIMEZONE" ]]; then
    echo "Time zone correct = $CURRENT_TIMEZONE"
else
    echo "Time zone not correct = $CURRENT_TIMEZONE (Expected: $TIMEZONE)"
fi
