#!/usr/bin/env python3
"""Waybar module for displaying Claude Code status."""

import json
from datetime import datetime, timezone
from pathlib import Path

STATUS_FILE = Path.home() / ".claude" / ".claude-waybar-status.json"
STALE_SECONDS = 43200  # Consider status stale after 12 hours

ICONS = {
    "working": "⚙",
    "needs_input": "?",
    "needs_permission": "⊘",
    "done": "✓",
    "idle": "●",
}


def main():
    if not STATUS_FILE.exists():
        print(json.dumps({"text": "", "tooltip": "Claude Code inactive", "class": "inactive"}))
        return

    try:
        data = json.loads(STATUS_FILE.read_text())
    except (json.JSONDecodeError, OSError):
        print(json.dumps({"text": "", "tooltip": "Status file error", "class": "error"}))
        return

    state = data.get("state", "idle")
    status = data.get("status", "")
    tooltip = data.get("tooltip", status)
    updated_at = data.get("updated_at", "")

    # Check staleness
    if updated_at:
        try:
            dt = datetime.fromisoformat(updated_at)
            if dt.tzinfo is None:
                dt = dt.replace(tzinfo=timezone.utc)
            now = datetime.now(timezone.utc)
            age = (now - dt).total_seconds()

            if age > STALE_SECONDS:
                # Stale - assume idle
                print(json.dumps({"text": "", "tooltip": f"Stale ({int(age)}s)", "class": "inactive"}))
                return

            tooltip = f"{tooltip}\n\nUpdated: {dt.strftime('%H:%M:%S')}"
        except ValueError:
            pass

    icon = ICONS.get(state, "")
    text = f"{icon} {status}" if status else icon

    print(json.dumps({"text": text, "tooltip": tooltip, "class": state}))


if __name__ == "__main__":
    main()
