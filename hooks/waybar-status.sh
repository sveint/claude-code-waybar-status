#!/bin/bash
# Waybar status updates from Claude Code hooks

STATUS_FILE="$HOME/.claude/.claude-waybar-status.json"
STATE="$1"

# Don't overwrite certain states
if [[ -f "$STATUS_FILE" ]]; then
    CURRENT_STATE=$(jq -r '.state // ""' "$STATUS_FILE" 2>/dev/null)

    # Don't overwrite needs_input with needs_permission (both mean waiting for user)
    if [[ "$STATE" == "needs_permission" && "$CURRENT_STATE" == "needs_input" ]]; then
        exit 0
    fi

    # Don't overwrite done with working (PostToolUse can fire after Stop)
    if [[ "$STATE" == "working" && "$CURRENT_STATE" == "done" ]]; then
        exit 0
    fi
fi

# Read stdin for hook context (JSON from Claude Code)
# Use timeout to avoid blocking if no input
INPUT=""
if [[ ! -t 0 ]]; then
    INPUT=$(timeout 0.1 cat 2>/dev/null || true)
fi

# Extract agent_type from hook input
AGENT_TYPE=""
if [[ -n "$INPUT" ]]; then
    AGENT_TYPE=$(echo "$INPUT" | jq -r '.agent_type // ""' 2>/dev/null)
fi

# Set status based on state
case "$STATE" in
    working)
        STATUS="Working..."
        TOOLTIP="Claude is working..."
        ;;
    done)
        STATUS="Done"
        TOOLTIP="Claude finished"
        ;;
    needs_input)
        STATUS="Claude needs input"
        TOOLTIP="Claude is asking you a question"
        ;;
    needs_permission)
        STATUS="Claude needs permission"
        TOOLTIP="Claude needs permission to proceed"
        ;;
    idle)
        STATUS=""
        TOOLTIP="Claude Code is idle"
        ;;
    subagent_start)
        STATE="working"
        STATUS="${AGENT_TYPE:-Subagent}"
        TOOLTIP="Running ${AGENT_TYPE:-subagent} agent..."
        ;;
    subagent_stop)
        STATE="working"
        STATUS="Working..."
        TOOLTIP="Subagent finished, continuing..."
        ;;
    *)
        STATUS="$STATE"
        TOOLTIP="$STATE"
        ;;
esac

TIMESTAMP=$(date -Iseconds)

jq -n \
    --arg status "$STATUS" \
    --arg tooltip "$TOOLTIP" \
    --arg state "$STATE" \
    --arg updated_at "$TIMESTAMP" \
    '{status: $status, tooltip: $tooltip, state: $state, updated_at: $updated_at}' \
    > "$STATUS_FILE"
