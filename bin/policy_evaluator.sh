#!/bin/bash

set -e  # Exit on error

# Get the directory where the current script is located
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

# Define BASE_DIR explicitly to avoid confusion from symlinks
BASE_DIR="/opt/rise/harmony/"

# Paths relative to BASE_DIR
EVAL_DIR="$BASE_DIR/evaluators"
UNIFIED_POLICY_JSON="$BASE_DIR/tmp/unified_policy.json"
CURRENT_VALUES_JSON="$BASE_DIR/tmp/current_values.json"
policy_url="$1"
policy_port="$2"

# Generate metadata: unique Document ID and a UTC timestamp
generate_metadata() {
    local doc_id=$(uuidgen)
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "$doc_id" "$timestamp"
}

# Print final results in structured JSON format
print_result() {
    local ALLOW="$1"
    local SUCCESS="$2"
    local VARIABLE_NAME="$3"
    local POLICY_NAME="$4"
    local COMPARISON_TYPE="$5"
    local PARAMETER_NAME="$6"
    local CURRENT_VALUE="$7"
    local COMPARISON_VALUE="$8"
    local MESSAGE="$9"
    local PRIORITY="${10}"
    local DOWNTIME="${11}"
    
    # Assign actual and expected values from the input
    local ACTUAL_VALUE="$CURRENT_VALUE"
    local EXPECTED_VALUE="$COMPARISON_VALUE"

    # Determine execution status based on success
    local EXECUTION_STATUS
    if [[ "$SUCCESS" == "true" ]]; then
        EXECUTION_STATUS="Success"
    else
        EXECUTION_STATUS="Failure"
    fi

    # Generate metadata
    read DOC_ID TIMESTAMP < <(generate_metadata)

    # Check if COMPARISON_TYPE is "in_list" or "not_in_list" and that EXPECTED_VALUE is valid JSON
    if [[ "$COMPARISON_TYPE" == "in_list" || "$COMPARISON_TYPE" == "not_in_list" ]]; then
        if echo "$EXPECTED_VALUE" | jq empty >/dev/null 2>&1; then
            # Valid JSON array, use --argjson
            jq -n \
                --arg doc_id "$DOC_ID" \
                --arg hostname "$(hostname)" \
                --arg policy_name "$POLICY_NAME" \
                --arg variable_name "$VARIABLE_NAME" \
                --arg param_name "$PARAMETER_NAME" \
                --argjson expected_value "$EXPECTED_VALUE" \
                --arg actual_value "$ACTUAL_VALUE" \
                --arg comparison_type "$COMPARISON_TYPE" \
                --arg allow "$ALLOW" \
                --arg timestamp "$TIMESTAMP" \
                --arg execution "$EXECUTION_STATUS" \
                --arg message "$MESSAGE" \
                --arg priority "$PRIORITY" \
                --arg downtime "$DOWNTIME" \
                --arg source "harmony" \
                '{
                    "documentId": $doc_id,
                    "hostname": $hostname,
                    "policyName": $policy_name,
                    "variableName": $variable_name,
                    "parameter": $param_name,
                    "expectedValue": $expected_value,
                    "actualValue": $actual_value,
                    "comparisonType": $comparison_type,
                    "allow": $allow,
                    "timestamp": $timestamp,
                    "executionStatus": $execution,
                    "message": $message,
                    "priority": $priority,
                    "downtime": $downtime,
                    "source": $source
                }' | jq --indent 2 | tr -d '\n' && echo "~"
        else
            echo "ERROR: Invalid JSON array for COMPARISON_TYPE '$COMPARISON_TYPE'"
            exit 1
        fi
    else
        # For other types, treat EXPECTED_VALUE as a string
        jq -n \
            --arg doc_id "$DOC_ID" \
            --arg hostname "$(hostname)" \
            --arg policy_name "$POLICY_NAME" \
            --arg variable_name "$VARIABLE_NAME" \
            --arg param_name "$PARAMETER_NAME" \
            --arg expected_value "$EXPECTED_VALUE" \
            --arg actual_value "$ACTUAL_VALUE" \
            --arg comparison_type "$COMPARISON_TYPE" \
            --arg allow "$ALLOW" \
            --arg timestamp "$TIMESTAMP" \
            --arg execution "$EXECUTION_STATUS" \
            --arg message "$MESSAGE" \
            --arg priority "$PRIORITY" \
            --arg downtime "$DOWNTIME" \
            --arg source "harmony" \
            '{
                "documentId": $doc_id,
                "hostname": $hostname,
                "policyName": $policy_name,
                "variableName": $variable_name,
                "parameter": $param_name,
                "expectedValue": $expected_value,
                "actualValue": $actual_value,
                "comparisonType": $comparison_type,
                "allow": $allow,
                "timestamp": $timestamp,
                "executionStatus": $execution,
                "message": $message,
                "priority": $priority,
                "downtime": $downtime,
                "source": $source
            }' | jq --indent 2 | tr -d '\n' && echo "~"
    fi
}

# Process the result returned from the evaluator script
process_result() {
    local RESULT="$1"
    local VARIABLE_NAME="$2"
    local POLICY_NAME="$3"
    local COMPARISON_TYPE="$4"
    local PARAMETER_NAME="$5"
    local CURRENT_VALUE="$6"
    local COMPARISON_VALUE="$7"
    local PRIORITY="$8"
    local DOWNTIME="$9"

    # Extract allow and success fields from the result
    local ALLOW=$(echo "$RESULT" | jq -r '.allow // false')
    local SUCCESS=$(echo "$RESULT" | jq -r '.success // false')

    # Call print_result to print the final output
    print_result "$ALLOW" "$SUCCESS" "$VARIABLE_NAME" "$POLICY_NAME" "$COMPARISON_TYPE" "$PARAMETER_NAME" "$CURRENT_VALUE" "$COMPARISON_VALUE" "OK" "$PRIORITY" "$DOWNTIME"
}

# Check if required JSON files exist and are not empty
for file in "$UNIFIED_POLICY_JSON" "$CURRENT_VALUES_JSON"; do
    if [[ ! -s "$file" ]]; then
        echo "ERROR: File $file is empty or does not exist. Exiting."
        exit 1
    fi
done

# Loop through each key in the current values JSON
jq -r 'keys[]' "$CURRENT_VALUES_JSON" | while read key; do
    # Extract current values and policy details for each variable
    VARIABLE_NAME="$key"
    PARAMETER_NAME=$(jq -r --arg key "$key" '.[$key].parameter' "$CURRENT_VALUES_JSON")
    CURRENT_VALUE=$(jq -r --arg key "$key" '.[$key].value' "$CURRENT_VALUES_JSON")
    COMPARISON_OBJECT=$(jq -r --arg key "$key" '.[$key]' "$UNIFIED_POLICY_JSON")
    POLICY_NAME=$(echo "$COMPARISON_OBJECT" | jq -r '.policy_id')
    COMPARISON_VALUE=$(echo "$COMPARISON_OBJECT" | jq -r '.value')
    COMPARISON_TYPE=$(echo "$COMPARISON_OBJECT" | jq -r '.comparison_type')
    DOWNTIME=$(jq -r --arg key "$key" '.[$key].downtime' "$UNIFIED_POLICY_JSON")
    PRIORITY=$(jq -r --arg key "$key" '.[$key].priority' "$UNIFIED_POLICY_JSON")

    #echo "POLICY_NAME: $POLICY_NAME"
    # Ensure null values are handled properly
    [[ "$CURRENT_VALUE" == "null" ]] && CURRENT_VALUE=null
    [[ "$COMPARISON_VALUE" == "null" ]] && COMPARISON_VALUE=null

    # Check if evaluator script exists and is executable
    if [[ -x "$EVAL_DIR/$COMPARISON_TYPE.sh" ]]; then
        RESULT=$("$EVAL_DIR/$COMPARISON_TYPE.sh" "$PARAMETER_NAME" "$CURRENT_VALUE" "$COMPARISON_VALUE" "$COMPARISON_TYPE" "$POLICY_NAME" "$policy_url" "$policy_port")
        EXEC_STATUS=$?
        #echo "RESULT: $RESULT"


        # If execution failed, print an error
        if [ $EXEC_STATUS -ne 0 ]; then
            print_result "false" "false" "$VARIABLE_NAME" "$POLICY_NAME" "$COMPARISON_TYPE" "$PARAMETER_NAME" "$CURRENT_VALUE" "$COMPARISON_VALUE" "Error executing $COMPARISON_TYPE.sh (Exit status: $EXEC_STATUS)" "$PRIORITY" "$DOWNTIME"
        # If the result is valid JSON, process it
        elif echo "$RESULT" | jq . >/dev/null 2>&1; then
            process_result "$RESULT" "$VARIABLE_NAME" "$POLICY_NAME" "$COMPARISON_TYPE" "$PARAMETER_NAME" "$CURRENT_VALUE" "$COMPARISON_VALUE" "$PRIORITY" "$DOWNTIME"
        # If result is invalid, print an error
        else
            print_result "false" "false" "$VARIABLE_NAME" "$POLICY_NAME" "$COMPARISON_TYPE" "$PARAMETER_NAME" "$CURRENT_VALUE" "$COMPARISON_VALUE" "Invalid JSON returned from $COMPARISON_TYPE.sh" "$PRIORITY" "$DOWNTIME"
        fi
    # Handle case where evaluator script is not found
    else
        print_result "false" "false" "$VARIABLE_NAME" "$POLICY_NAME" "$COMPARISON_TYPE" "$PARAMETER_NAME" "$CURRENT_VALUE" "$COMPARISON_VALUE" "Evaluator script for $COMPARISON_TYPE not found." "$PRIORITY" "$DOWNTIME"
    fi
done

