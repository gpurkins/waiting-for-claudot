#!/bin/bash

# Disable autopilot sounds for Claude Code
# Removes the hooks configuration

SETTINGS_FILE="$HOME/.claude/settings.json"

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed."
    echo "Install with: brew install jq"
    exit 1
fi

# Check if settings file exists
if [[ ! -f "$SETTINGS_FILE" ]]; then
    echo "No settings file found. Nothing to disable."
    exit 0
fi

# Remove hooks from settings
jq 'del(.hooks)' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" \
    && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"

echo "Autopilot sounds disabled!"
