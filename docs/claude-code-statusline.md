# Claude Code Status Line Configuration Documentation

*Downloaded from: https://docs.anthropic.com/en/docs/claude-code/statusline*
*Download date: 2025-08-21*

---

## Overview

Create a custom status line for Claude Code to display contextual information.

Make Claude Code your own with a custom status line that displays at the bottom of the Claude Code interface, similar to how terminal prompts (PS1) work in shells like Oh-my-zsh.

## Create a custom status line

You can either:

- **Run `/statusline`** to ask Claude Code to help you set up a custom status line. By default, it will try to reproduce your terminal's prompt, but you can provide additional instructions about the behavior you want Claude Code, such as `/statusline show the model name in orange`

- **Directly add a `statusLine` command** to your `.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0 // Optional: set to 0 to let status line go to edge
  }
}
```

## How it Works

- The status line is updated when the conversation messages update
- Updates run at most every 300ms
- The first line of stdout from your command becomes the status line text
- ANSI color codes are supported for styling your status line
- Claude Code passes contextual information about the current session (model, directories, etc.) as JSON to your script via stdin

## JSON Input Structure

Your status line command receives structured data via stdin in JSON format:

```json
{
  "hook_event_name": "Status",
  "session_id": "abc123...",
  "transcript_path": "/path/to/transcript.json",
  "cwd": "/current/working/directory",
  "model": {
    "id": "claude-opus-4-1",
    "display_name": "Opus"
  },
  "workspace": {
    "current_dir": "/current/working/directory",
    "project_dir": "/original/project/directory"
  },
  "version": "1.0.80",
  "output_style": {
    "name": "default"
  },
  "cost": {
    "total_cost_usd": 0.01234,
    "total_duration_ms": 45000,
    "total_api_duration_ms": 2300,
    "total_lines_added": 156,
    "total_lines_removed": 23
  }
}
```

## Example Scripts

### Simple Status Line

```bash
#!/bin/bash
# Read JSON input from stdin
input=$(cat)

# Extract values using jq
MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir')

echo "[$MODEL_DISPLAY] 📁 ${CURRENT_DIR##*/}"
```

### Git-Aware Status Line

```bash
#!/bin/bash
# Read JSON input from stdin
input=$(cat)

# Extract values using jq
MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir')

# Show git branch if in a git repo
GIT_BRANCH=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        GIT_BRANCH=" | 🌿 $BRANCH"
    fi
fi

echo "[$MODEL_DISPLAY] 📁 ${CURRENT_DIR##*/}$GIT_BRANCH"
```

### Python Example

```python
#!/usr/bin/env python3
import json
import sys
import os

# Read JSON from stdin
data = json.load(sys.stdin)

# Extract values
model = data['model']['display_name']
current_dir = os.path.basename(data['workspace']['current_dir'])

# Check for git branch
git_branch = ""
if os.path.exists('.git'):
    try:
        with open('.git/HEAD', 'r') as f:
            ref = f.read().strip()
            if ref.startswith('ref: refs/heads/'):
                git_branch = f" | 🌿 {ref.replace('ref: refs/heads/', '')}"
    except:
        pass

print(f"[{model}] 📁 {current_dir}{git_branch}")
```

### Node.js Example

```javascript
#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Read JSON from stdin
let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
    const data = JSON.parse(input);
    
    // Extract values
    const model = data.model.display_name;
    const currentDir = path.basename(data.workspace.current_dir);
    
    // Check for git branch
    let gitBranch = '';
    try {
        const headContent = fs.readFileSync('.git/HEAD', 'utf8').trim();
        if (headContent.startsWith('ref: refs/heads/')) {
            gitBranch = ` | 🌿 ${headContent.replace('ref: refs/heads/', '')}`;
        }
    } catch (e) {
        // Not a git repo or can't read HEAD
    }
    
    console.log(`[${model}] 📁 ${currentDir}${gitBranch}`);
});
```

### Helper Function Approach

For more complex bash scripts, you can create helper functions:

```bash
#!/bin/bash
# Read JSON input once
input=$(cat)

# Helper functions for common extractions
get_model_name() { echo "$input" | jq -r '.model.display_name'; }
get_current_dir() { echo "$input" | jq -r '.workspace.current_dir'; }
get_project_dir() { echo "$input" | jq -r '.workspace.project_dir'; }
get_version() { echo "$input" | jq -r '.version'; }
get_cost() { echo "$input" | jq -r '.cost.total_cost_usd'; }
get_duration() { echo "$input" | jq -r '.cost.total_duration_ms'; }
get_lines_added() { echo "$input" | jq -r '.cost.total_lines_added'; }
get_lines_removed() { echo "$input" | jq -r '.cost.total_lines_removed'; }

# Use the helpers
MODEL=$(get_model_name)
DIR=$(get_current_dir)
echo "[$MODEL] 📁 ${DIR##*/}"
```

## Advanced Status Line Examples

### Cost-Aware Status Line

```bash
#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir | basename')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd')
DURATION=$(echo "$input" | jq -r '.cost.total_duration_ms')

# Format cost with color
if (( $(echo "$COST > 0.01" | bc -l) )); then
    COST_DISPLAY="\033[31m$$COST\033[0m"
else
    COST_DISPLAY="\033[32m$$COST\033[0m"
fi

echo "[$MODEL] 📁 $DIR | 💰$COST_DISPLAY | ⏱️ ${DURATION}ms"
```

### Environment-Aware Status Line

```bash
#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir | basename')
PYTHON_VERSION=$(python3 --version 2>/dev/null | cut -d' ' -f2)
NODE_VERSION=$(node --version 2>/dev/null | cut -d'v' -f2)

ENV_INFO=""
if [ -n "$PYTHON_VERSION" ]; then
    ENV_INFO=" | 🐍 $PYTHON_VERSION"
fi
if [ -n "$NODE_VERSION" ]; then
    ENV_INFO="$ENV_INFO | 🟢 $NODE_VERSION"
fi

echo "[$MODEL] 📁 $DIR$ENV_INFO"
```

### MCP Server Status

```bash
#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir | basename')

# Check if MCP servers are configured
MCP_COUNT=$(echo "$input" | jq '.mcp_servers // [] | length')
MCP_INFO=""
if [ "$MCP_COUNT" -gt 0 ]; then
    MCP_INFO=" | 🔌 $MCP_COUNT MCP"
fi

echo "[$MODEL] 📁 $DIR$MCP_INFO"
```

### Project Type Detection

```bash
#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir | basename')

PROJECT_TYPE=""
if [ -f "package.json" ]; then
    PROJECT_TYPE=" | 📦 Node.js"
elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    PROJECT_TYPE=" | 🐍 Python"
elif [ -f "Cargo.toml" ]; then
    PROJECT_TYPE=" | 🦀 Rust"
elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
    PROJECT_TYPE=" | ☕ Java"
elif [ -f "go.mod" ]; then
    PROJECT_TYPE=" | 🔷 Go"
fi

echo "[$MODEL] 📁 $DIR$PROJECT_TYPE"
```

## Tips

- **Keep your status line concise** - it should fit on one line
- **Use emojis** (if your terminal supports them) and colors to make information scannable
- **Use `jq` for JSON parsing** in Bash (see examples above)
- **Test your script manually** by running it with mock JSON input: `echo '{"model":{"display_name":"Test"},"workspace":{"current_dir":"/test"}}' | ./statusline.sh`
- **Consider caching expensive operations** (like git status) if needed
- **Use appropriate colors** for different types of information (green for good, red for warnings, etc.)
- **Make it responsive** to different terminal widths

## Color and Styling

### ANSI Color Codes

```bash
#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir | basename')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd')

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Color cost based on amount
if (( $(echo "$COST > 0.05" | bc -l) )); then
    COST_COLOR=$RED
elif (( $(echo "$COST > 0.02" | bc -l) )); then
    COST_COLOR=$YELLOW
else
    COST_COLOR=$GREEN
fi

echo -e "${BOLD}${BLUE}[$MODEL]${NC} 📁 $DIR | 💰${COST_COLOR}$$COST${NC}"
```

### Icon Usage

```bash
#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir | basename')

# Different icons for different models
case $MODEL in
    "Opus") MODEL_ICON="🚀" ;;
    "Sonnet") MODEL_ICON="⚡" ;;
    "Haiku") MODEL_ICON="🌸" ;;
    *) MODEL_ICON="🤖" ;;
esac

echo "$MODEL_ICON [$MODEL] 📁 $DIR"
```

## Performance Optimization

### Caching Expensive Operations

```bash
#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir | basename')

# Cache git branch info to avoid repeated git commands
CACHE_DIR="/tmp/claude-statusline"
CACHE_FILE="$CACHE_DIR/git-branch-$(echo $DIR | tr '/' '_').txt"

# Create cache directory if it doesn't exist
mkdir -p "$CACHE_DIR"

# Check cache age (5 minutes)
if [ -f "$CACHE_FILE" ] && [ $(find "$CACHE_FILE" -mmin -5 2>/dev/null) ]; then
    GIT_BRANCH=$(cat "$CACHE_FILE")
else
    GIT_BRANCH=""
    if git rev-parse --git-dir > /dev/null 2>&1; then
        BRANCH=$(git branch --show-current 2>/dev/null)
        if [ -n "$BRANCH" ]; then
            GIT_BRANCH=" | 🌿 $BRANCH"
            echo "$GIT_BRANCH" > "$CACHE_FILE"
        fi
    fi
fi

echo "[$MODEL] 📁 ${DIR##*/}$GIT_BRANCH"
```

### Minimal Version

```bash
#!/bin/bash
# Fast, minimal version for slow systems
read input
MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir' | cut -d'/' -f5)
echo "[$MODEL] $DIR"
```

## Troubleshooting

### Common Issues

1. **Status line doesn't appear**
   - Check that your script is executable: `chmod +x ~/.claude/statusline.sh`
   - Ensure your script outputs to stdout (not stderr)
   - Verify the path in your settings.json is correct

2. **Status line is blank**
   - Make sure your script outputs exactly one line
   - Check for errors in your script by running it manually
   - Verify JSON parsing is working correctly

3. **Colors not displaying**
   - Ensure your terminal supports ANSI color codes
   - Check that color codes are properly formatted
   - Test colors with a simple script: `echo -e "\033[31mRed\033[0m"`

4. **Performance issues**
   - Reduce complexity of your script
   - Add caching for expensive operations
   - Avoid external commands that are slow to execute

### Debug Commands

```bash
# Test your status line script manually
echo '{"model":{"display_name":"Test"},"workspace":{"current_dir":"/test"}}' | ~/.claude/statusline.sh

# Check if script is executable
ls -la ~/.claude/statusline.sh

# Verify settings.json configuration
cat ~/.claude/settings.json | jq '.statusLine'

# Test with real data (run during Claude Code session)
echo "Current session data:" > /tmp/statusline-debug.json
# Paste real JSON data and test
cat /tmp/statusline-debug.json | ~/.claude/statusline.sh
```

### Error Handling

```bash
#!/bin/bash
# Robust status line with error handling
set -euo pipefail

input=$(cat 2>/dev/null || echo '{}')

# Safe extraction with defaults
MODEL=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
DIR=$(echo "$input" | jq -r '.workspace.current_dir // "/unknown"' | xargs basename)

echo "[$MODEL] 📁 $DIR" 2>/dev/null || echo "[Claude] 📁 unknown"
```

## Integration with Other Features

### Memory Integration

```bash
#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir | basename')

# Check for CLAUDE.md in current directory
MEMORY_INFO=""
if [ -f "CLAUDE.md" ]; then
    MEMORY_INFO=" | 📝 CLAUDE.md"
fi

echo "[$MODEL] 📁 $DIR$MEMORY_INFO"
```

### MCP Server Status

```bash
#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir | basename')

# Count MCP servers from input
MCP_COUNT=$(echo "$input" | jq '.mcp_servers // [] | length')
MCP_INFO=""
if [ "$MCP_COUNT" -gt 0 ]; then
    MCP_INFO=" | 🔌 $MCP_COUNT servers"
fi

echo "[$MODEL] 📁 $DIR$MCP_INFO"
```

## Configuration Options

### Settings.json Configuration

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0,
    "updateInterval": 300
  }
}
```

### Built-in Status Line

For a simple built-in status line without custom scripts:

```json
{
  "statusLine": {
    "type": "builtin"
  }
}
```

### Multiple Status Lines

You can create different status lines for different contexts:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline-context-aware.sh"
  }
}
```

Then in your script:

```bash
#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir | basename')
PROJECT_TYPE=$(echo "$input" | jq -r '.project_type // "unknown"')

case $PROJECT_TYPE in
    "node") PROJECT_ICON="📦" ;;
    "python") PROJECT_ICON="🐍" ;;
    "rust") PROJECT_ICON="🦀" ;;
    *) PROJECT_ICON="📁" ;;
esac

echo "[$MODEL] $PROJECT_ICON $DIR"
```

## See Also

- [Memory management](https://docs.anthropic.com/en/docs/claude-code/memory) - Context and preference management
- [CLI reference](https://docs.anthropic.com/en/docs/claude-code/cli-reference) - Command-line interface documentation
- [Settings](https://docs.anthropic.com/en/docs/claude-code/settings) - Configuration options
- [Terminal configuration](https://docs.anthropic.com/en/docs/claude-code/terminal-config) - Terminal setup and customization

---

*This documentation was downloaded from Anthropic docs and saved locally for reference.*