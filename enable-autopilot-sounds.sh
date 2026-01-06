#!/bin/bash

# Enable autopilot sounds for Claude Code
# Adds hooks to play Autopilot Engage/Disengage sounds

SETTINGS_FILE="$HOME/.claude/settings.json"
SOUND_DIR="$(cd "$(dirname "$0")" && pwd)"
NOTIFICATIONS=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --notifications)
            NOTIFICATIONS=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--notifications]"
            echo ""
            echo "Options:"
            echo "  --notifications  Enable macOS notifications when Claude finishes"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage"
            exit 1
            ;;
    esac
done

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed."
    echo "Install with: brew install jq"
    exit 1
fi

# Check if settings file exists
if [[ ! -f "$SETTINGS_FILE" ]]; then
    echo "{}" > "$SETTINGS_FILE"
fi

# Build the stop command based on options
STOP_CMD="afplay -v 0.2 \"$SOUND_DIR/Autopilot Disengage.wav\""
if [[ "$NOTIFICATIONS" == true ]]; then
    STOP_CMD="$STOP_CMD; printf '\\\\a'; osascript -e 'display notification \"Claude Done\" with title \"Claude Code\"'"
fi

# Create the hooks configuration
HOOKS_CONFIG=$(cat <<EOF
{
  "UserPromptSubmit": [
    {
      "matcher": "",
      "hooks": [
        {
          "type": "command",
          "command": "afplay -v 0.2 \"$SOUND_DIR/Autopilot Engage.wav\""
        }
      ]
    }
  ],
  "Stop": [
    {
      "matcher": "",
      "hooks": [
        {
          "type": "command",
          "command": "$STOP_CMD"
        }
      ]
    }
  ]
}
EOF
)

# Update settings with hooks
jq --argjson hooks "$HOOKS_CONFIG" '.hooks = $hooks' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" \
    && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"

echo "Autopilot sounds enabled!"
echo "  - Engage sound: $SOUND_DIR/Autopilot Engage.wav"
echo "  - Disengage sound: $SOUND_DIR/Autopilot Disengage.wav"
if [[ "$NOTIFICATIONS" == true ]]; then
    echo "  - Notifications: enabled"
fi
