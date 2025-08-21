# Claude Code CLI Reference Documentation

*Downloaded from: https://docs.anthropic.com/en/docs/claude-code/cli-reference*
*Download date: 2025-08-21*

---

## CLI commands

| Command | Description | Example |
|---------|-------------|---------|
| `claude` | Start interactive REPL | `claude` |
| `claude "query"` | Start REPL with initial prompt | `claude "explain this project"` |
| `claude -p "query"` | Query via SDK, then exit | `claude -p "explain this function"` |
| `cat file | claude -p "query"` | Process piped content | `cat logs.txt | claude -p "explain"` |
| `claude -c` | Continue most recent conversation | `claude -c` |
| `claude -c -p "query"` | Continue via SDK | `claude -c -p "Check for type errors"` |
| `claude -r "<session-id>" "query"` | Resume session by ID | `claude -r "abc123" "Finish this PR"` |
| `claude update` | Update to latest version | `claude update` |
| `claude mcp` | Configure Model Context Protocol (MCP) servers | See the [Claude Code MCP documentation](https://docs.anthropic.com/en/docs/claude-code/mcp). |

## CLI flags

Customize Claude Code's behavior with these command-line flags:

| Flag | Description | Example |
|------|-------------|---------|
| `--add-dir` | Add additional working directories for Claude to access (validates each path exists as a directory) | `claude --add-dir ../apps ../lib` |
| `--allowedTools` | A list of tools that should be allowed without prompting the user for permission, in addition to [settings.json](https://docs.anthropic.com/en/docs/claude-code/settings) files | `"Bash(git log:*)" "Bash(git diff:*)" "Read"` |
| `--disallowedTools` | A list of tools that should be disallowed without prompting the user for permission, in addition to [settings.json](https://docs.anthropic.com/en/docs/claude-code/settings) files | `"Bash(git log:*)" "Bash(git diff:*)" "Edit"` |
| `--print`, `-p` | Print response without interactive mode (see [SDK documentation](https://docs.anthropic.com/en/docs/claude-code/sdk) for programmatic usage details) | `claude -p "query"` |
| `--append-system-prompt` | Append to system prompt (only with `--print`) | `claude --append-system-prompt "Custom instruction"` |
| `--output-format` | Specify output format for print mode (options: `text`, `json`, `stream-json`) | `claude -p "query" --output-format json` |
| `--input-format` | Specify input format for print mode (options: `text`, `stream-json`) | `claude -p --output-format json --input-format stream-json` |
| `--verbose` | Enable verbose logging, shows full turn-by-turn output (helpful for debugging in both print and interactive modes) | `claude --verbose` |
| `--max-turns` | Limit the number of agentic turns in non-interactive mode | `claude -p --max-turns 3 "query"` |
| `--model` | Sets the model for the current session with an alias for the latest model (`sonnet` or `opus`) or a model's full name | `claude --model claude-sonnet-4-20250514` |
| `--permission-mode` | Begin in a specified [permission mode](https://docs.anthropic.com/en/docs/claude-code/iam#permission-modes) | `claude --permission-mode plan` |
| `--permission-prompt-tool` | Specify an MCP tool to handle permission prompts in non-interactive mode | `claude -p --permission-prompt-tool mcp_auth_tool "query"` |
| `--resume` | Resume a specific session by ID, or by choosing in interactive mode | `claude --resume abc123 "query"` |
| `--continue` | Load the most recent conversation in the current directory | `claude --continue` |
| `--dangerously-skip-permissions` | Skip permission prompts (use with caution) | `claude --dangerously-skip-permissions` |

For detailed information about print mode (`-p`) including output formats, streaming, verbose logging, and programmatic usage, see the [SDK documentation](https://docs.anthropic.com/en/docs/claude-code/sdk).

## Advanced CLI Usage

### Multiple Directories

```bash
# Add multiple directories for Claude to access
claude --add-dir ../shared-components ../utils ./src

# Use with project-specific contexts
claude --add-dir ../../common-libraries
```

### Tool Permission Management

```bash
# Allow specific git operations without prompting
claude --allowedTools "Bash(git log:*)" "Bash(git diff:*)" "Bash(git status)" "Read"

# Disallow potentially dangerous operations
claude --disallowedTools "Bash(rm:*)" "Bash(mv:*)" "WebFetch"

# Combine allowed and disallowed tools
claude --allowedTools "Read,Write,Edit" --disallowedTools "Bash(curl:*)"
```

### Output Format Examples

```bash
# JSON output for programmatic processing
claude -p "Analyze this code" --output-format json

# Streaming JSON for real-time processing
claude -p "Process this large file" --output-format stream-json

# Text output (default)
claude -p "Explain this concept" --output-format text
```

### Session Management

```bash
# Continue the most recent conversation
claude --continue

# Continue with additional query
claude --continue -p "Now add error handling"

# Resume specific session
claude --resume "abc123-def456" "Complete the implementation"

# List available sessions (interactive mode)
claude --resume
```

### Model Selection

```bash
# Use model aliases
claude --model sonnet
claude --model opus

# Use specific model versions
claude --model claude-sonnet-4-20250514
claude --model claude-opus-4-1

# Combine with other flags
claude --model sonnet --max-turns 5 -p "Implement this feature"
```

### Permission Modes

```bash
# Plan mode - read only analysis
claude --permission-mode plan

# Accept edits mode - auto-approve file changes
claude --permission-mode acceptEdits

# Bypass permissions - use with extreme caution
claude --dangerously-skip-permissions
```

### System Prompt Customization

```bash
# Add custom instructions to system prompt
claude -p "Review this code" --append-system-prompt "Focus on security vulnerabilities and performance issues"

# Multiple custom instructions
claude -p "Refactor this function" --append-system-prompt "Use functional programming patterns. Include comprehensive error handling."
```

## Input/Output Format Examples

### Standard Text Input/Output

```bash
# Basic query
claude -p "What does this function do?"

# Piped input
cat function.py | claude -p "Explain this code"

# File input
claude -p "$(cat config.json)" "Parse this configuration"
```

### JSON Input/Output

```bash
# JSON output for parsing
RESULT=$(claude -p "Generate a summary" --output-format json)
echo "$RESULT" | jq -r '.result'

# Streaming JSON input
echo '{"type":"user","message":{"role":"user","content":[{"type":"text","text":"Analyze this data"}]}}' | \
  claude -p --output-format stream-json --input-format stream-json
```

## Debugging and Development

### Verbose Mode

```bash
# Enable verbose logging for debugging
claude --verbose

# Verbose with specific query
claude -p "Debug this issue" --verbose

# Verbose session continuation
claude --continue --verbose
```

### Development Flags

```bash
# Limit turns for testing
claude -p --max-turns 2 "Simple task"

# Skip permissions for development (use cautiously)
claude --dangerously-skip-permissions -p "Make these changes"

# Test with specific model
claude --model claude-haiku-4-1 -p "Quick test"
```

## Configuration Files

### CLI Configuration in Settings

You can also set CLI preferences in your `settings.json` file:

```json
{
  "model": "claude-sonnet-4-20250514",
  "maxTurns": 5,
  "verbose": false,
  "permissionMode": "acceptEdits",
  "allowedTools": ["Read", "Write", "Edit", "Bash(git diff:*)"]
}
```

### Environment Variables

Set environment variables for global CLI behavior:

```bash
# Set default model
export ANTHROPIC_MODEL=claude-sonnet-4-20250514

# Enable verbose logging
export CLAUDE_VERBOSE=1

# Set default max turns
export CLAUDE_MAX_TURNS=3
```

## Batch Processing

### Multiple Queries

```bash
# Process multiple files
for file in src/*.py; do
    echo "Processing $file"
    claude -p "Add type hints to $(basename $file)" < "$file"
done

# Batch with different models
echo "Review with Sonnet" | claude --model sonnet -p "Code review"
echo "Review with Haiku" | claude --model haiku -p "Quick check"
```

### Automated Workflows

```bash
# Pre-commit hook example
#!/bin/bash
FILES=$(git diff --cached --name-only --diff-filter=AM | grep -E '\.(py|js|ts)$')
if [ -n "$FILES" ]; then
    echo "$FILES" | claude -p "Review these staged files for issues"
fi
```

## Error Handling

### Common Error Scenarios

```bash
# Handle authentication errors
claude -p "test" 2>&1 | grep -q "authentication" && echo "Please login first"

# Handle timeout issues
timeout 30 claude -p "Complex task" || echo "Operation timed out"

# Retry failed operations
for i in {1..3}; do
    claude -p "Retry operation" && break || sleep 1
done
```

### Exit Codes

```bash
# Check exit codes for scripting
if claude -p "Test this"; then
    echo "Success"
else
    echo "Failed with exit code $?"
fi

# Use in CI/CD pipelines
claude -p "Validate configuration" || exit 1
```

## Performance Optimization

### Resource Management

```bash
# Limit output tokens for faster responses
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=1000

# Use smaller model for simple tasks
claude --model haiku -p "Quick analysis"

# Cache expensive operations
claude -p "Analyze once" --output-format json > analysis.json
```

### Parallel Processing

```bash
# Run multiple Claude instances in parallel
(
    claude -p "Analyze module A" < module_a.py &
    claude -p "Analyze module B" < module_b.py &
    wait
)
```

## Integration Examples

### Git Integration

```bash
# Git alias for Claude review
git config --global alias.review '!f() { git diff --cached | claude -p "Review staged changes"; }; f'

# Use in git workflow
git add .
git review
git commit -m "Changes reviewed by Claude"
```

### IDE Integration

```bash
# VS Code task
{
    "label": "Claude Code Review",
    "type": "shell",
    "command": "claude",
    "args": ["-p", "Review the current file: ${file}"],
    "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "new"
    }
}
```

### CI/CD Pipeline

```yaml
# GitHub Actions example
- name: Claude Code Review
  run: |
    git diff origin/main...HEAD | claude -p "Review these changes for issues" --output-format json > review.json
    echo "Review complete"
```

## Best Practices

### Security

- Never use `--dangerously-skip-permissions` in production
- Use specific tool allowlists rather than broad permissions
- Review Claude's suggestions before applying them
- Keep API keys and sensitive data out of CLI history

### Performance

- Use appropriate models for task complexity (Haiku for simple, Sonnet/Opus for complex)
- Limit output tokens when not needed
- Cache results of expensive operations
- Use parallel processing for independent tasks

### Reliability

- Handle errors and timeouts gracefully
- Use exit codes for automation scripts
- Test CLI commands in development before production
- Monitor resource usage and costs

### Maintainability

- Use configuration files for consistent settings
- Document custom CLI usage in project README
- Use meaningful aliases and shortcuts
- Keep CLI scripts version controlled

## Troubleshooting

### Common Issues

1. **Authentication errors**
   ```bash
   claude login  # Re-authenticate
   ```

2. **Permission denied**
   ```bash
   claude --allowedTools "Read,Write"  # Add necessary tools
   ```

3. **Timeout issues**
   ```bash
   timeout 60 claude -p "task"  # Increase timeout
   ```

4. **Model not found**
   ```bash
   claude --model sonnet  # Use model alias
   ```

### Debug Commands

```bash
# Check Claude Code version
claude --version

# Verify installation
which claude

# Check configuration
claude config list

# Test basic functionality
claude -p "Hello, world!"
```

## See Also

- [Interactive mode](https://docs.anthropic.com/en/docs/claude-code/interactive-mode) - Shortcuts, input modes, and interactive features
- [Slash commands](https://docs.anthropic.com/en/docs/claude-code/slash-commands) - Interactive session commands
- [Quickstart guide](https://docs.anthropic.com/en/docs/claude-code/quickstart) - Getting started with Claude Code
- [Common workflows](https://docs.anthropic.com/en/docs/claude-code/common-workflows) - Advanced workflows and patterns
- [Settings](https://docs.anthropic.com/en/docs/claude-code/settings) - Configuration options
- [SDK documentation](https://docs.anthropic.com/en/docs/claude-code/sdk) - Programmatic usage and integrations
- [Status line configuration](https://docs.anthropic.com/en/docs/claude-code/statusline) - Custom status line setup

---

*This documentation was downloaded from Anthropic docs and saved locally for reference.*