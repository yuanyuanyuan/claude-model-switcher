# Claude Code Hooks Guide Documentation

*Downloaded from: https://docs.anthropic.com/en/docs/claude-code/hooks-guide*
*Download date: 2025-08-21*

---

## Overview

Claude Code hooks are user-defined shell commands that execute at various points in Claude Code's lifecycle. Hooks provide deterministic control over Claude Code's behavior, ensuring certain actions always happen rather than relying on the LLM to choose to run them.

Example use cases for hooks include:

- **Notifications**: Customize how you get notified when Claude Code is awaiting your input or permission to run something.
- **Automatic formatting**: Run `prettier` on .ts files, `gofmt` on .go files, etc. after every file edit.
- **Logging**: Track and count all executed commands for compliance or debugging.
- **Feedback**: Provide automated feedback when Claude Code produces code that does not follow your codebase conventions.
- **Custom permissions**: Block modifications to production files or sensitive directories.

By encoding these rules as hooks rather than prompting instructions, you turn suggestions into app-level code that executes every time it is expected to run.

## Hook Events Overview

Claude Code provides several hook events that run at different points in the workflow:

- **PreToolUse**: Runs before tool calls (can block them)
- **PostToolUse**: Runs after tool calls complete
- **UserPromptSubmit**: Runs when the user submits a prompt, before Claude processes it
- **Notification**: Runs when Claude Code sends notifications
- **Stop**: Runs when Claude Code finishes responding
- **Subagent Stop**: Runs when subagent tasks complete
- **PreCompact**: Runs before Claude Code is about to run a compact operation
- **SessionStart**: Runs when Claude Code starts a new session or resumes an existing session

Each event receives different data and can control Claude's behavior in different ways.

## Quickstart

In this quickstart, you'll add a hook that logs the shell commands that Claude Code runs.

### Prerequisites

Install `jq` for JSON processing in the command line.

### Step 1: Open hooks configuration

Run the `/hooks` [slash command](https://docs.anthropic.com/en/docs/claude-code/slash-commands) and select the `PreToolUse` hook event.

`PreToolUse` hooks run before tool calls and can block them while providing Claude feedback on what to do differently.

### Step 2: Add a matcher

Select `+ Add new matcher…` to run your hook only on Bash tool calls.

Type `Bash` for the matcher.

### Step 3: Add the hook

Select `+ Add new hook…` and enter this command:

```bash
echo "$(date): $CLAUDE_HOOK_TOOL_INPUT" >> ~/.claude/command_log.txt
```

### Step 4: Save your configuration

For storage location, select `User settings` since you're logging to your home directory. This hook will then apply to all projects, not just your current project.

Then press Esc until you return to the REPL. Your hook is now registered!

### Step 5: Verify your hook

Run `/hooks` again or check `~/.claude/settings.json` to see your configuration:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matchers": ["Bash"],
        "command": "echo \"$(date): $CLAUDE_HOOK_TOOL_INPUT\" >> ~/.claude/command_log.txt"
      }
    ]
  }
}
```

### Step 6: Test your hook

Ask Claude to run a simple command like `ls` and check your log file:

```bash
# Ask Claude: "Run ls"
cat ~/.claude/command_log.txt
```

You should see entries like:

```
2025-08-21T14:30:15Z: {"command":"ls","cwd":"/path/to/project"}
```

## More Examples

### Code Formatting Hook

Automatically format TypeScript files after editing:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matchers": ["Write", "MultiEdit"],
        "command": "if [[ \"$CLAUDE_HOOK_TOOL_OUTPUT\" == *\".ts\" ]]; then cd \"$CLAUDE_HOOK_CWD\" && npx prettier --write \"$CLAUDE_HOOK_TOOL_OUTPUT\"; fi"
      }
    ]
  }
}
```

### Markdown Formatting Hook

Automatically fix missing language tags and formatting issues in markdown files:

Create `.claude/hooks/markdown_formatter.py` with this content:

```python
#!/usr/bin/env python3
import json
import sys
import re
from pathlib import Path

def format_markdown(file_path):
    """Format markdown files with proper language tags and spacing"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Add language tags to unlabeled code blocks
        def add_language_tags(match):
            code_content = match.group(2)
            # Simple language detection
            if any(keyword in code_content.lower() for keyword in ['def ', 'import ', 'class ', 'if __name__']):
                language = 'python'
            elif any(keyword in code_content for keyword in ['function', 'const ', 'let ', '=>']):
                language = 'javascript'
            elif any(keyword in code_content for keyword in ['<div', '<script', 'function']):
                language = 'html'
            else:
                language = 'text'
            return f"```{language}\n{code_content}\n```"
        
        # Replace unlabeled code blocks
        content = re.sub(r'```(\w*)\n(.*?)\n```', add_language_tags, content, flags=re.DOTALL)
        
        # Fix excessive blank lines (more than 2 consecutive)
        content = re.sub(r'\n{3,}', '\n\n', content)
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
            
    except Exception as e:
        print(f"Error formatting {file_path}: {e}", file=sys.stderr)

if __name__ == "__main__":
    # Read hook data from stdin
    hook_data = json.loads(sys.stdin.read())
    
    # Get file path from tool output
    tool_output = hook_data.get('tool_output', '{}')
    output_data = json.loads(tool_output) if tool_output else {}
    
    file_path = output_data.get('path', '')
    
    # Only process markdown files
    if file_path.endswith(('.md', '.mdx')):
        format_markdown(file_path)
```

Make the script executable:

```bash
chmod +x .claude/hooks/markdown_formatter.py
```

Then add to your hooks configuration:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matchers": ["Write", "MultiEdit"],
        "command": "python3 .claude/hooks/markdown_formatter.py"
      }
    ]
  }
}
```

This hook automatically:

- Detects programming languages in unlabeled code blocks
- Adds appropriate language tags for syntax highlighting
- Fixes excessive blank lines while preserving code content
- Only processes markdown files (`.md`, `.mdx`)

### Custom Notification Hook

Get desktop notifications when Claude needs input:

```json
{
  "hooks": {
    "Notification": [
      {
        "matchers": ["*"],
        "command": "if command -v notify-send >/dev/null 2>&1; then notify-send 'Claude Code' \"$CLAUDE_HOOK_NOTIFICATION_MESSAGE\"; fi"
      }
    ]
  }
}
```

### File Protection Hook

Block edits to sensitive files:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matchers": ["Write", "MultiEdit", "Edit"],
        "command": "echo '$CLAUDE_HOOK_TOOL_INPUT' | jq -r '.path // empty' | grep -E '^(prod/|production/|\\.env\\.)' && echo 'BLOCKED: Cannot modify production files' >&2 && exit 1 || exit 0"
      }
    ]
  }
}
```

## Hook Environment Variables

Hooks have access to several environment variables that provide context about the current operation:

### General Variables
- `CLAUDE_HOOK_CWD`: Current working directory
- `CLAUDE_HOOK_SESSION_ID`: Current session identifier
- `CLAUDE_HOOK_EVENT`: The hook event that triggered execution

### Tool-Specific Variables
- `CLAUDE_HOOK_TOOL_NAME`: Name of the tool being called
- `CLAUDE_HOOK_TOOL_INPUT`: Input parameters for the tool (JSON string)
- `CLAUDE_HOOK_TOOL_OUTPUT`: Output from the tool (JSON string, for PostToolUse)

### User Interaction Variables
- `CLAUDE_HOOK_USER_PROMPT`: The user's submitted prompt
- `CLAUDE_HOOK_NOTIFICATION_MESSAGE`: Notification message content

### Session Variables
- `CLAUDE_HOOK_COMPACT_THRESHOLD`: Token threshold for compact operations
- `CLAUDE_HOOK_SUBAGENT_NAME`: Name of the subagent (if applicable)

## Hook Return Codes

Hooks can control Claude Code's behavior through their exit codes:

- **Exit code 0**: Success - allow the operation to continue
- **Exit code 1**: Block the operation (for PreToolUse hooks)
- **Exit code 2**: Provide feedback to Claude and retry
- **Other codes**: Treated as errors

## Hook Security Considerations

- **Input validation**: Always validate and sanitize hook inputs
- **Path safety**: Be careful with file paths to prevent directory traversal attacks
- **Command injection**: Avoid executing user-provided strings directly
- **Permissions**: Run hooks with appropriate user permissions
- **Logging**: Consider logging hook executions for audit purposes

## Best Practices

1. **Keep hooks simple**: Complex hooks are harder to debug and maintain
2. **Use absolute paths**: Avoid relying on current working directory
3. **Handle errors gracefully**: Use try/catch or error checking
4. **Test thoroughly**: Test hooks with various scenarios and edge cases
5. **Document your hooks**: Add comments explaining what each hook does
6. **Version control**: Store hook configurations and scripts in version control
7. **Performance**: Consider the performance impact of hooks, especially for frequent operations

## Troubleshooting

### Common Issues

1. **Hook not executing**: Check matchers and event types
2. **Permission errors**: Ensure hook scripts are executable
3. **Path issues**: Use absolute paths in hook configurations
4. **Environment variables**: Verify variable names and availability
5. **JSON parsing**: Ensure proper JSON formatting in tool inputs/outputs

### Debugging Techniques

1. **Add logging**: Insert echo statements to trace hook execution
2. **Test manually**: Run hook commands outside of Claude Code
3. **Check configuration**: Verify JSON syntax in settings files
4. **Monitor logs**: Check Claude Code logs for hook-related errors
5. **Isolate issues**: Test hooks one at a time to identify problems

## Learn more

- For reference documentation on hooks, see [Hooks reference](https://docs.anthropic.com/en/docs/claude-code/hooks).
- For comprehensive security best practices and safety guidelines, see [Security Considerations](https://docs.anthropic.com/en/docs/claude-code/hooks#security-considerations) in the hooks reference documentation.
- For troubleshooting steps and debugging techniques, see [Debugging](https://docs.anthropic.com/en/docs/claude-code/hooks#debugging) in the hooks reference documentation.

---

*This documentation was downloaded from Anthropic docs and saved locally for reference.*