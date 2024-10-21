#!/bin/bash

# Function to display help message
show_help() {
cat << EOF
Usage: ${0##*/} [DECISION_ENGINE_HOST] [DECISION_ENGINE_PORT] [POLICY_NAME]...
Run the specified policies on the given Decision Engine.

    DECISION_ENGINE_HOST   the host of the Decision Engine
    DECISION_ENGINE_PORT   the port of the Decision Engine
    "*"                   run all policies
    POLICY_NAME           run a specific policy
    POLICY_NAME_1 POLICY_NAME_2 ... run multiple specified policies

Examples:
    ./${0##*/} 127.0.0.1 8080 "*"                # Run all policies on Decision Engine at 127.0.0.1:8080
    ./${0##*/} 127.0.0.1 8080 policy1            # Run the specified policy on Decision Engine at 127.0.0.1:8080
    ./${0##*/} 127.0.0.1 8080 policy1 policy2    # Run multiple specified policies on Decision Engine at 127.0.0.1:8080
EOF
}

# Temporary file pattern
TMP_FILE="tmp.$$.json"

# Ensure temporary files are removed on exit (successful or error)
trap "rm -f $TMP_FILE" EXIT

# Check if no arguments were provided
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

# Assign the first and second arguments to the respective variables
policy_url="${1}"
policy_port="${2}"

# Get the directory where the current script is located
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

# Remove the trailing "/bin" from SCRIPT_DIR to get /opt/rise/harmony, regardless of symbolic links
BASE_DIR="/opt/rise/harmony"

# Paths relative to BASE_DIR, which is always /opt/rise/harmony
POLICY_JSON_DIR="$BASE_DIR/policies"
UNIFIED_POLICY_JSON="$BASE_DIR/tmp/unified_policy.json"
DATA_COLLECTOR_SCRIPT="$BASE_DIR/bin/data_collector.sh"
POLICY_EVALUATOR_SCRIPT="$BASE_DIR/bin/policy_evaluator.sh"
CURRENT_VALUES_JSON="$BASE_DIR/tmp/current_values.json"

# Print to confirm paths
#echo "DATA_COLLECTOR_SCRIPT: $DATA_COLLECTOR_SCRIPT"
#echo "POLICY_JSON_DIR: $POLICY_JSON_DIR"
#echo "UNIFIED_POLICY_JSON: $UNIFIED_POLICY_JSON"
#echo "POLICY_EVALUATOR_SCRIPT: $POLICY_EVALUATOR_SCRIPT"
#echo "CURRENT_VALUES_JSON: $CURRENT_VALUES_JSON"

# Ensure the tmp directory exists before writing the file
if [ ! -d "$BASE_DIR/tmp" ]; then
  echo "Creating tmp directory: $BASE_DIR/tmp"
  mkdir -p "$BASE_DIR/tmp"
fi

# Check if the directory is writable
if [ -w "$BASE_DIR/tmp" ]; then
  # Initialize unified_policy.json with an empty JSON object
  echo "{}" > "$UNIFIED_POLICY_JSON"
else
  echo "Error: Cannot write to $BASE_DIR/tmp. Please check permissions."
  exit 1
fi

# Determine which policy files to process, starting from argument 3
if [[ "$3" == "*" ]]; then
    POLICY_FILES="${POLICY_JSON_DIR}/*.json"
else
    POLICY_FILES=""
    for policy_name in "${@:3}"; do
        POLICY_FILES="${POLICY_FILES} ${POLICY_JSON_DIR}/${policy_name}.json"
    done
fi

# Check if the specified policy file(s) exist
if ls $POLICY_FILES 1> /dev/null 2>&1; then
    # Merge the specified JSON files into a single unified_policy.json
    for policy_file in $POLICY_FILES; do
        if [ -f "$policy_file" ]; then
            # Merge the current policy file with the unified JSON
            tmp_content=$(jq -s '.[0] * .[1]' "$UNIFIED_POLICY_JSON" "$policy_file")
            if [ $? -ne 0 ]; then
                echo "Error: Failed to merge $policy_file."
                exit 1
            fi
            echo "$tmp_content" > "$UNIFIED_POLICY_JSON"
        else
            echo "Error: Policy file $policy_file not found."
            exit 1
        fi
    done

    # Format the JSON file to ensure proper indentation
    jq . "$UNIFIED_POLICY_JSON" > "$TMP_FILE" && mv "$TMP_FILE" "$UNIFIED_POLICY_JSON"

    # Run the data_collector.sh script after unified_policy.json is created
    "$DATA_COLLECTOR_SCRIPT" "$CURRENT_VALUES_JSON"

    # Call the policy evaluator script
    "$POLICY_EVALUATOR_SCRIPT" "$policy_url" "$policy_port"

    # Delete unified_policy.json
    #rm -f "$UNIFIED_POLICY_JSON" "$CURRENT_VALUES_JSON"
else
    echo "Error: Policy file(s) are neither found nor specified in the command line."
    exit 1
fi

