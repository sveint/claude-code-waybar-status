# Claude Waybar Status

Display Claude Code status in Waybar using hooks for automatic updates.

<p align="center">
  <img src="images/working.png" width="268"><br>
  <img src="images/needs_permission.png" width="358"><br>
  <img src="images/done.png" width="227">
</p>

## How it Works

Claude Code hooks automatically update a status file (`~/.claude/.claude-waybar-status.json`) when:

- **UserPromptSubmit** - User sends a message → "Claude is working..."
- **PreToolUse (AskUserQuestion)** - Claude asks a question → "Claude needs input"
- **PermissionRequest** - Claude needs tool permission → "Claude needs permission"
- **PostToolUse** - Tool completes → Back to "Claude is working..."
- **Stop** - Claude finishes responding → "Done"
- **SubagentStart** - Subagent spawns → Shows agent type (Explore, Plan, etc.)
- **SubagentStop** - Subagent finishes → Back to "Claude is working..."

Staleness detection marks status as inactive if no update in 12 hours.

## Requirements

- Python 3
- jq

## Installation

### 1. Install the hook script

```bash
cp hooks/waybar-status.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/waybar-status.sh
```

### 2. Configure Claude Code hooks

Add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/waybar-status.sh working" }]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "AskUserQuestion",
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/waybar-status.sh needs_input" }]
      }
    ],
    "PermissionRequest": [
      {
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/waybar-status.sh needs_permission" }]
      }
    ],
    "PostToolUse": [
      {
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/waybar-status.sh working" }]
      }
    ],
    "Stop": [
      {
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/waybar-status.sh done" }]
      }
    ],
    "SubagentStart": [
      {
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/waybar-status.sh subagent_start" }]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/waybar-status.sh subagent_stop" }]
      }
    ]
  }
}
```

### 3. Add Waybar module

Add to your waybar config:

```json
"custom/claude-status": {
    "exec": "/path/to/waybar-claude-status.py",
    "return-type": "json",
    "interval": 1
}
```

### 4. Style it (optional)

Example CSS:

```css
#custom-claude-status {
    padding: 4px 12px;
    margin: 5px 10px 5px 4px;
    border-radius: 12px;
}
#custom-claude-status.working {
    color: #ffffff;
    background-color: rgba(122, 162, 247, 0.8);
}
#custom-claude-status.needs_input {
    color: #ffffff;
    background-color: rgba(204, 52, 54, 0.9);
}
#custom-claude-status.needs_permission {
    color: #ffffff;
    background-color: rgba(255, 152, 0, 0.9);
}
#custom-claude-status.done {
    color: #ffffff;
    background-color: rgba(45, 204, 54, 0.8);
}
#custom-claude-status.inactive {
    color: #6c7086;
}
```

## Files

- `waybar-claude-status.py` - Waybar module that reads status file and outputs JSON
- `hooks/waybar-status.sh` - Hook script that writes to status file

## Status File Format

`~/.claude/.claude-waybar-status.json`:

```json
{
  "status": "Claude is working...",
  "tooltip": "Claude is working...",
  "state": "working",
  "updated_at": "2025-01-27T17:40:10+01:00"
}
```

States: `working`, `done`, `needs_input`, `needs_permission`, `idle`
