#!/bin/bash

# Get the directory where the data_collector.sh script is located
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

# Define BASE_DIR to remove "/bin" from SCRIPT_DIR
BASE_DIR="/opt/rise/harmony"

# Define paths relative to BASE_DIR
POLICY_JSON_DIR="$BASE_DIR/policies"
COLLECTORS_DIR="$BASE_DIR/collectors"
UNIFIED_POLICY_JSON="$BASE_DIR/tmp/unified_policy.json"
CURRENT_VALUES_JSON="$1"

# Initialize current_values.json
echo "{" > "$CURRENT_VALUES_JSON"
FIRST=true

# Check if unified_policy.json exists
if [ ! -f "$UNIFIED_POLICY_JSON" ]; then
    echo "Error: Unified policy JSON not found."
    exit 1
fi

# Extract keys from the unified policy JSON
KEYS=$(jq -r 'keys[]' "$UNIFIED_POLICY_JSON")

# Run only the specified collector scripts and gather output into current_values.json
for key in $KEYS; do
    script="$COLLECTORS_DIR/${key}.sh"
    if [[ -x "$script" ]]; then
        OUTPUT=$("$script")
        FILENAME=$(basename "$script" .sh)
        while IFS= read -r line; do
            KEY=$(echo "$line" | cut -d= -f1 | xargs)
            VALUE=$(echo "$line" | cut -d= -f2- | xargs)

            # Ensure proper JSON formatting for keys and values
            if [ "$FIRST" = false ]; then
                echo "," >> "$CURRENT_VALUES_JSON"
            fi
            FIRST=false

            # Check if VALUE should be a number or a string
            if [[ "$VALUE" =~ ^[0-9]+$ ]]; then
                echo "\"$FILENAME\": {\"value\": $VALUE, \"parameter\": \"$KEY\"}" >> "$CURRENT_VALUES_JSON"
            else
                echo "\"$FILENAME\": {\"value\": \"$VALUE\", \"parameter\": \"$KEY\"}" >> "$CURRENT_VALUES_JSON"
            fi

        done <<< "$OUTPUT"
    else
        echo "Warning: Collector script for $key not found or not executable."
    fi
done

# Close the JSON object
echo "}" >> "$CURRENT_VALUES_JSON"

# Format the JSON file to ensure proper indentation
jq . "$CURRENT_VALUES_JSON" > "tmp.$$.json" && mv "tmp.$$.json" "$CURRENT_VALUES_JSON"

#echo "Current values JSON created at $CURRENT_VALUES_JSON"

