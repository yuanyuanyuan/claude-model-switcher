# Claude Code Interactive Mode Documentation

*Downloaded from: https://docs.anthropic.com/en/docs/claude-code/interactive-mode*
*Download date: 2025-08-21*

---

## Keyboard shortcuts

### General controls

| Shortcut | Description | Context |
|----------|-------------|---------|
| `Ctrl+C` | Cancel current input or generation | Standard interrupt |
| `Ctrl+D` | Exit Claude Code session | EOF signal |
| `Ctrl+L` | Clear terminal screen | Keeps conversation history |
| `Up/Down arrows` | Navigate command history | Recall previous inputs |
| `Esc` + `Esc` | Edit previous message | Double-escape to modify |

### Multiline input

| Method | Shortcut | Context |
|--------|----------|---------|
| Quick escape | `\` + `Enter` | Works in all terminals |
| macOS default | `Option+Enter` | Default on macOS |
| Terminal setup | `Shift+Enter` | After `/terminal-setup` |
| Control sequence | `Ctrl+J` | Line feed character for multiline |
| Paste mode | Paste directly | For code blocks, logs |

### Quick commands

| Shortcut | Description | Notes |
|----------|-------------|-------|
| `#` at start | Memory shortcut - add to CLAUDE.md | Prompts for file selection |
| `/` at start | Slash command | See [slash commands](https://docs.anthropic.com/en/docs/claude-code/slash-commands) |

## Vim mode

Enable vim-style editing with `/vim` command or configure permanently via `/config`.

### Mode switching

| Command | Action | From mode |
|----------|---------|-----------|
| `Esc` | Enter NORMAL mode | INSERT |
| `i` | Insert before cursor | NORMAL |
| `I` | Insert at beginning of line | NORMAL |
| `a` | Insert after cursor | NORMAL |
| `A` | Insert at end of line | NORMAL |
| `o` | Open line below | NORMAL |
| `O` | Open line above | NORMAL |

### Navigation (NORMAL mode)

| Command | Action |
|----------|---------|
| `h`/`j`/`k`/`l` | Move left/down/up/right |
| `w` | Next word |
| `e` | End of word |
| `b` | Previous word |
| `0` | Beginning of line |
| `$` | End of line |
| `^` | First non-blank character |
| `gg` | Beginning of input |
| `G` | End of input |

### Editing (NORMAL mode)

| Command | Action |
|----------|---------|
| `x` | Delete character |
| `dd` | Delete line |
| `D` | Delete to end of line |
| `dw`/`de`/`db` | Delete word/to end/back |
| `cc` | Change line |
| `C` | Change to end of line |
| `cw`/`ce`/`cb` | Change word/to end/back |
| `.` | Repeat last change |

## Command history

Claude Code maintains command history for the current session:

- History is stored per working directory
- Cleared with `/clear` command
- Use Up/Down arrows to navigate (see keyboard shortcuts above)
- **Ctrl+R**: Reverse search through history (if supported by terminal)
- **Note**: History expansion (`!`) is disabled by default

## Session Management

### Starting a Session

```bash
# Start new session
claude

# Start with initial prompt
claude "Explain this project"

# Continue most recent conversation
claude --continue

# Resume specific session
claude --resume "session-id-here"
```

### Session Features

- **Persistent context**: Maintains conversation history
- **Working directory awareness**: Remembers project context
- **Memory integration**: Loads CLAUDE.md files automatically
- **Tool state**: Maintains tool permissions and MCP server connections

### Ending a Session

```bash
# Graceful exit
Ctrl+D

# Cancel current operation
Ctrl+C

# Clear and exit
/clear
Ctrl+D
```

## Input Modes

### Standard Input Mode

- **Single line**: Default for most queries
- **Multiline**: Use escape sequences for longer inputs
- **Code blocks**: Paste directly or use multiline mode

### Advanced Input Features

#### Multiline Input Methods

1. **Backslash + Enter**: `\` followed by Enter
2. **Option+Enter**: macOS default
3. **Shift+Enter**: After terminal setup
4. **Ctrl+J**: Line feed character

#### Code Block Handling

```python
# Paste code blocks directly
def example_function():
    return "Hello, World!"

# Claude will automatically detect and format
```

#### Large Text Input

```bash
# Use file redirection for large inputs
claude -p "$(cat large_file.txt)" "Analyze this content"

# Or use pipes
cat large_file.txt | claude -p "Process this data"
```

## Navigation and Editing

### Cursor Movement

- **Arrow keys**: Navigate through input
- **Home/End**: Jump to start/end of line
- **Ctrl+Left/Right**: Word navigation (in supported terminals)

### Text Editing

- **Backspace/Delete**: Remove characters
- **Ctrl+U**: Delete to beginning of line
- **Ctrl+K**: Delete to end of line
- **Ctrl+W**: Delete previous word

### Selection and Clipboard

- **Shift+Arrows**: Select text (in supported terminals)
- **Ctrl+Shift+C**: Copy selection
- **Ctrl+Shift+V**: Paste clipboard

## Interactive Features

### Real-time Feedback

- **Typing indicators**: Shows when Claude is processing
- **Progress indicators**: Displays during long operations
- **Streaming output**: See responses as they're generated
- **Error messages**: Clear error reporting and suggestions

### Conversation Context

- **Message history**: Scroll through previous exchanges
- **Context indicators**: Shows current model and session info
- **Memory status**: Displays loaded CLAUDE.md files
- **Tool usage**: Shows which tools are being used

### Customization Options

#### Prompt Customization

```bash
# Add memory during conversation
# This will be added to CLAUDE.md
Use 2-space indentation for Python files

# Use system prompts
/append-system-prompt "Focus on security aspects"
```

#### Mode Switching

```bash
# Switch permission modes
/permission-mode plan
/permission-mode acceptEdits

# Toggle features
/vim  # Enable vim mode
/verbose  # Enable verbose logging
```

## Advanced Interactive Features

### Subagent Integration

```bash
# Use specialized subagents
Ask the code-reviewer to check this function
Use the data-scientist to analyze these results
```

### MCP Tool Usage

```bash
# Interact with MCP servers
Check Sentry for recent errors
Query the database for user information
```

### Multi-turn Conversations

```bash
# Build on previous context
Now add error handling to that function
What are the security implications?
Create tests for this code
```

## Troubleshooting Interactive Mode

### Common Issues

1. **Multiline input not working**
   - Try `\` + `Enter`
   - Run `/terminal-setup` for Shift+Enter
   - Check terminal compatibility

2. **History not available**
   - Use Up/Down arrows
   - Check if `/clear` was used recently
   - Verify working directory permissions

3. **Vim mode not responding**
   - Press `Esc` to enter NORMAL mode
   - Check if vim mode is enabled (`/vim`)
   - Verify terminal key handling

### Debug Commands

```bash
# Check current session info
/session

# View loaded memories
/memory

# Check configuration
/config list

# Test terminal features
/terminal-setup

# Verify vim mode status
/vim
```

### Performance Issues

- **Slow response times**: Check network connectivity
- **High memory usage**: Clear conversation history with `/clear`
- **Terminal lag**: Reduce verbose logging or switch terminal

## Terminal Compatibility

### Supported Terminals

- **iTerm2** (macOS): Full feature support
- **Terminal.app** (macOS): Basic support
- **GNOME Terminal** (Linux): Good support
- **Konsole** (Linux): Good support
- **Windows Terminal**: Good support
- **Alacritty**: Excellent support
- **WezTerm**: Excellent support

### Terminal Setup

```bash
# Configure terminal for optimal experience
/terminal-setup

# This will:
# - Enable Shift+Enter for multiline
# - Configure key bindings
# - Test terminal capabilities
```

## Accessibility Features

### Keyboard Navigation

- **Full keyboard control**: Navigate without mouse
- **Consistent shortcuts**: Standard key combinations
- **Mode indicators**: Visual feedback for current mode

### Visual Feedback

- **High contrast modes**: Available through terminal themes
- **Clear status indicators**: Shows current state and mode
- **Error highlighting**: Visual distinction for errors

### Screen Reader Support

- **Structured output**: Compatible with screen readers
- **Status announcements**: Important changes are announced
- **Error reporting**: Clear error messages for assistive technologies

## Best Practices

### Efficient Usage

1. **Use keyboard shortcuts**: Learn common shortcuts for faster interaction
2. **Leverage history**: Use Up/Down arrows to repeat similar commands
3. **Organize conversations**: Use `/clear` between unrelated topics
4. **Customize settings**: Configure vim mode and other preferences

### Productivity Tips

1. **Template commands**: Save common queries for reuse
2. **Batch operations**: Use multiple related queries in sequence
3. **Context maintenance**: Keep related work in single sessions
4. **Memory management**: Use `#` shortcut for frequent instructions

### Collaboration Features

1. **Session sharing**: Share session IDs with team members
2. **Consistent configurations**: Use project-level settings.json
3. **Memory standardization**: Use CLAUDE.md for team guidelines
4. **Tool coordination**: Configure MCP servers for team workflows

## Integration with Other Tools

### IDE Integration

```bash
# Use from VS Code integrated terminal
# Features work seamlessly with IDE workflows

# Configure VS Code tasks for common operations
# See IDE integration documentation
```

### Git Integration

```bash
# Use in git workflows
git add .
claude "Review staged changes"
git commit -m "Changes reviewed by Claude"
```

### CI/CD Integration

```bash
# Use in automated pipelines
claude -p "Validate configuration" --output-format json
# Parse JSON output for CI decisions
```

## See Also

- [Slash commands](https://docs.anthropic.com/en/docs/claude-code/slash-commands) - Interactive session commands
- [CLI reference](https://docs.anthropic.com/en/docs/claude-code/cli-reference) - Command-line flags and options
- [Settings](https://docs.anthropic.com/en/docs/claude-code/settings) - Configuration options
- [Memory management](https://docs.anthropic.com/en/docs/claude-code/memory) - Managing CLAUDE.md files
- [CLI reference](https://docs.anthropic.com/en/docs/claude-code/cli-reference) - Command-line interface documentation
- [Slash commands](https://docs.anthropic.com/en/docs/claude-code/slash-commands) - Interactive commands reference

---

*This documentation was downloaded from Anthropic docs and saved locally for reference.*