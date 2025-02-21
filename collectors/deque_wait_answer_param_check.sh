#!/bin/bash
# Set Variables
SID="$SAP_SID"
inst_no="$app_inst_no"
host="$app_host"
param_to_check="enque/deque_wait_answer"
expected_value="TRUE"

# Define profile paths in order of priority
profiles=(
    "/sapmnt/${SID}/profile/DEFAULT.PFL"
    "/sapmnt/${SID}/profile/${SID}_DVEBMGS${inst_no}_${host}"
    "/sapmnt/${SID}/profile/${SID}_D${inst_no}_${host}"
)

found_value=""  # Variable to store the found value

# Check profiles one by one
for profile in "${profiles[@]}"; do
    if [[ -f "$profile" ]]; then
        parameter_value=$(grep -E "^${param_to_check}[[:space:]]*=" "$profile" | awk -F= '{print $2}' | tr -d ' ')

        if [[ -n "$parameter_value" ]]; then
            found_value="$parameter_value"
            break  # Stop checking further profiles
        fi
    fi
done

# Print the final result (only one output)
if [[ -n "$found_value" ]]; then
        if [[ "$found_value" == "$expected_value" ]]; then
                echo "$param_to_check = $found_value"
        else
                echo "$param_to_check = $found_value (expected value = $expected_value)"
        fi
else
    echo "$param_to_check = Not found"
fi
