# Claude Code Settings Documentation

*Downloaded from: https://docs.anthropic.com/en/docs/claude-code/settings*
*Download date: 2025-08-21*

---

## Overview

Claude Code offers a variety of settings to configure its behavior to meet your needs. You can configure Claude Code by running the `/config` command when using the interactive REPL.

## Settings files

The `settings.json` file is our official mechanism for configuring Claude Code through hierarchical settings:

- **User settings** are defined in `~/.claude/settings.json` and apply to all projects.
- **Project settings** are saved in your project directory:
  - `.claude/settings.json` for settings that are checked into source control and shared with your team
  - `.claude/settings.local.json` for settings that are not checked in, useful for personal preferences and experimentation. Claude Code will configure git to ignore `.claude/settings.local.json` when it is created.
- **For enterprise deployments of Claude Code**, we also support **enterprise managed policy settings**. These take precedence over user and project settings. System administrators can deploy policies to:
  - macOS: `/Library/Application Support/ClaudeCode/managed-settings.json`
  - Linux and WSL: `/etc/claude-code/managed-settings.json`
  - Windows: `C:\ProgramData\ClaudeCode\managed-settings.json`

### Example settings.json

```json
{
  "model": "claude-3-5-sonnet-20241022",
  "permissions": {
    "allow": ["Bash(git diff:*)", "Read(**/*)"],
    "ask": ["Bash(git push:*)"],
    "deny": ["WebFetch", "Read(./.env)", "Read(./secrets/**)"]
  },
  "env": {
    "NODE_ENV": "development"
  },
  "hooks": {
    "PostToolUse": {
      "Write": "npx prettier --write $CLAUDE_HOOK_TOOL_OUTPUT"
    }
  },
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  },
  "enableAllProjectMcpServers": true,
  "cleanupPeriodDays": 30
}
```

## Available settings

`settings.json` supports a number of options:

| Key | Description | Example |
|------|-------------|---------|
| `apiKeyHelper` | Custom script, to be executed in `/bin/sh`, to generate an auth value. This value will be sent as `X-Api-Key` and `Authorization: Bearer` headers for model requests | `/bin/generate_temp_api_key.sh` |
| `cleanupPeriodDays` | How long to locally retain chat transcripts based on last activity date (default: 30 days) | `20` |
| `env` | Environment variables that will be applied to every session | `{"FOO": "bar"}` |
| `includeCoAuthoredBy` | Whether to include the `co-authored-by Claude` byline in git commits and pull requests (default: `true`) | `false` |
| `permissions` | See table below for structure of permissions. | |
| `hooks` | Configure custom commands to run before or after tool executions. See [hooks documentation](https://docs.anthropic.com/en/docs/claude-code/hooks-guide) | `{"PreToolUse": {"Bash": "echo 'Running command...'"}}` |
| `model` | Override the default model to use for Claude Code | `"claude-3-5-sonnet-20241022"` |
| `statusLine` | Configure a custom status line to display context. See [statusLine documentation](https://docs.anthropic.com/en/docs/claude-code/statusline) | `{"type": "command", "command": "~/.claude/statusline.sh"}` |
| `forceLoginMethod` | Use `claudeai` to restrict login to Claude.ai accounts, `console` to restrict login to Anthropic Console (API usage billing) accounts | `claudeai` |
| `enableAllProjectMcpServers` | Automatically approve all MCP servers defined in project `.mcp.json` files | `true` |
| `enabledMcpjsonServers` | List of specific MCP servers from `.mcp.json` files to approve | `["memory", "github"]` |
| `disabledMcpjsonServers` | List of specific MCP servers from `.mcp.json` files to reject | `["filesystem"]` |
| `awsAuthRefresh` | Custom script that modifies the `.aws` directory (see [advanced credential configuration](https://docs.anthropic.com/en/docs/claude-code/amazon-bedrock#advanced-credential-configuration)) | `aws sso login --profile myprofile` |
| `awsCredentialExport` | Custom script that outputs JSON with AWS credentials (see [advanced credential configuration](https://docs.anthropic.com/en/docs/claude-code/amazon-bedrock#advanced-credential-configuration)) | `/bin/generate_aws_grant.sh` |

### Permission settings

| Keys | Description | Example |
|------|-------------|---------|
| `allow` | Array of permission rules to allow tool use | `[ "Bash(git diff:*)" ]` |
| `ask` | Array of permission rules to ask for confirmation upon tool use. | `[ "Bash(git push:*)" ]` |
| `deny` | Array of permission rules to deny tool use. Use this to also exclude sensitive files from Claude Code access. | `[ "WebFetch", "Bash(curl:*)", "Read(./.env)", "Read(./secrets/**)" ]` |
| `additionalDirectories` | Additional working directories that Claude has access to | `[ "../docs/" ]` |
| `defaultMode` | Default permission mode when opening Claude Code | `"acceptEdits"` |
| `disableBypassPermissionsMode` | Set to `"disable"` to prevent `bypassPermissions` mode from being activated. See [managed policy settings](https://docs.anthropic.com/en/docs/claude-code/iam#enterprise-managed-policy-settings) | `"disable"` |

## Settings precedence

Settings are applied in order of precedence (highest to lowest):

1. **Enterprise managed policies** (`managed-settings.json`)
   - Deployed by IT/DevOps
   - Cannot be overridden

2. **Command line arguments**
   - Temporary overrides for a specific session

3. **Local project settings** (`.claude/settings.local.json`)
   - Personal project-specific settings

4. **Shared project settings** (`.claude/settings.json`)
   - Team-shared project settings in source control

5. **User settings** (`~/.claude/settings.json`)
   - Personal global settings

This hierarchy ensures that enterprise security policies are always enforced while still allowing teams and individuals to customize their experience.

## Key points about the configuration system

- **Memory files (CLAUDE.md)**: Contain instructions and context that Claude loads at startup
- **Settings files (JSON)**: Configure permissions, environment variables, and tool behavior
- **Slash commands**: Custom commands that can be invoked during a session with `/command-name`
- **MCP servers**: Extend Claude Code with additional tools and integrations
- **Precedence**: Higher-level configurations (Enterprise) override lower-level ones (User/Project)
- **Inheritance**: Settings are merged, with more specific settings adding to or overriding broader ones

## System prompt availability

System prompts can be configured at multiple levels:

- **Global system prompts**: In user settings (`~/.claude/settings.json`)
- **Project system prompts**: In project settings (`.claude/settings.json`)
- **Session system prompts**: Via command line arguments (`--system-prompt`)
- **CLAUDE.md**: Project-specific instructions and context

## Excluding sensitive files

To prevent Claude Code from accessing files containing sensitive information (e.g., API keys, secrets, environment files), use the `permissions.deny` setting in your `.claude/settings.json` file:

```json
{
  "permissions": {
    "deny": [
      "Read(./.env)",
      "Read(./secrets/**)",
      "Read(./config/**.secret)",
      "Bash(curl:*)",
      "WebFetch"
    ]
  }
}
```

This replaces the deprecated `ignorePatterns` configuration. Files matching these patterns will be completely invisible to Claude Code, preventing any accidental exposure of sensitive data.

## Subagent configuration

Claude Code supports custom AI subagents that can be configured at both user and project levels. These subagents are stored as Markdown files with YAML frontmatter:

- **User subagents**: `~/.claude/agents/` - Available across all your projects
- **Project subagents**: `.claude/agents/` - Specific to your project and can be shared with your team

Subagent files define specialized AI assistants with custom prompts and tool permissions. Learn more about creating and using subagents in the [subagents documentation](https://docs.anthropic.com/en/docs/claude-code/sub-agents).

## Environment variables

Claude Code supports the following environment variables to control its behavior:

| Variable | Purpose |
|----------|---------|
| `ANTHROPIC_API_KEY` | API key sent as `X-Api-Key` header, typically for the Claude SDK (for interactive usage, run `/login`) |
| `ANTHROPIC_AUTH_TOKEN` | Custom value for the `Authorization` header (the value you set here will be prefixed with `Bearer`) |
| `ANTHROPIC_CUSTOM_HEADERS` | Custom headers you want to add to the request (in `Name: Value` format) |
| `ANTHROPIC_MODEL` | Name of custom model to use (see [Model Configuration](https://docs.anthropic.com/en/docs/claude-code/bedrock-vertex-proxies#model-configuration)) |
| `ANTHROPIC_SMALL_FAST_MODEL` | Name of Haiku-class model for background tasks |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | Override AWS region for the small/fast model when using Bedrock |
| `AWS_BEARER_TOKEN_BEDROCK` | Bedrock API key for authentication (see [Bedrock API keys](https://aws.amazon.com/blogs/machine-learning/accelerate-ai-development-with-amazon-bedrock-api-keys/)) |
| `BASH_DEFAULT_TIMEOUT_MS` | Default timeout for long-running bash commands |
| `BASH_MAX_TIMEOUT_MS` | Maximum timeout the model can set for long-running bash commands |
| `BASH_MAX_OUTPUT_LENGTH` | Maximum number of characters in bash outputs before they are middle-truncated |
| `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR` | Return to the original working directory after each Bash command |
| `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` | Interval in milliseconds at which credentials should be refreshed (when using `apiKeyHelper`) |
| `CLAUDE_CODE_IDE_SKIP_AUTO_INSTALL` | Skip auto-installation of IDE extensions |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Set the maximum number of output tokens for most requests |
| `CLAUDE_CODE_USE_BEDROCK` | Use [Bedrock](https://docs.anthropic.com/en/docs/claude-code/amazon-bedrock) |
| `CLAUDE_CODE_USE_VERTEX` | Use [Vertex](https://docs.anthropic.com/en/docs/claude-code/google-vertex-ai) |
| `CLAUDE_CODE_SKIP_BEDROCK_AUTH` | Skip AWS authentication for Bedrock (e.g., when using an LLM gateway) |
| `CLAUDE_CODE_SKIP_VERTEX_AUTH` | Skip Google authentication for Vertex (e.g., when using an LLM gateway) |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Equivalent of setting `DISABLE_AUTOUPDATER`, `DISABLE_BUG_COMMAND`, `DISABLE_ERROR_REPORTING`, and `DISABLE_TELEMETRY` |
| `CLAUDE_CODE_DISABLE_TERMINAL_TITLE` | Set to `1` to disable automatic terminal title updates based on conversation context |
| `DISABLE_AUTOUPDATER` | Set to `1` to disable automatic updates. This takes precedence over the `autoUpdates` configuration setting. |
| `DISABLE_BUG_COMMAND` | Set to `1` to disable the `/bug` command |
| `DISABLE_COST_WARNINGS` | Set to `1` to disable cost warning messages |
| `DISABLE_ERROR_REPORTING` | Set to `1` to opt out of Sentry error reporting |
| `DISABLE_NON_ESSENTIAL_MODEL_CALLS` | Set to `1` to disable model calls for non-critical paths like flavor text |
| `DISABLE_TELEMETRY` | Set to `1` to opt out of Statsig telemetry (note that Statsig events do not include user data like code, file paths, or bash commands) |
| `HTTP_PROXY` | Specify HTTP proxy server for network connections |
| `HTTPS_PROXY` | Specify HTTPS proxy server for network connections |
| `MAX_THINKING_TOKENS` | Force a thinking for the model budget |
| `MCP_TIMEOUT` | Timeout in milliseconds for MCP server startup |
| `MCP_TOOL_TIMEOUT` | Timeout in milliseconds for MCP tool execution |
| `MAX_MCP_OUTPUT_TOKENS` | Maximum number of tokens allowed in MCP tool responses (default: 25000) |
| `USE_BUILTIN_RIPGREP` | Set to `0` to use system-installed `rg` instead of `rg` included with Claude Code |
| `VERTEX_REGION_CLAUDE_3_5_HAIKU` | Override region for Claude 3.5 Haiku when using Vertex AI |
| `VERTEX_REGION_CLAUDE_3_5_SONNET` | Override region for Claude Sonnet 3.5 when using Vertex AI |
| `VERTEX_REGION_CLAUDE_3_7_SONNET` | Override region for Claude 3.7 Sonnet when using Vertex AI |
| `VERTEX_REGION_CLAUDE_4_0_OPUS` | Override region for Claude 4.0 Opus when using Vertex AI |
| `VERTEX_REGION_CLAUDE_4_0_SONNET` | Override region for Claude 4.0 Sonnet when using Vertex AI |
| `VERTEX_REGION_CLAUDE_4_1_OPUS` | Override region for Claude 4.1 Opus when using Vertex AI |

## Configuration options

To manage your configurations, use the following commands:

- List settings: `claude config list`
- See a setting: `claude config get <key>`
- Change a setting: `claude config set <key> <value>`
- Push to a setting (for lists): `claude config add <key> <value>`
- Remove from a setting (for lists): `claude config remove <key> <value>`

By default `config` changes your project configuration. To manage your global configuration, use the `--global` (or `-g`) flag.

### Global configuration

To set a global configuration, use `claude config set -g <key> <value>`:

| Key | Description | Example |
|------|-------------|---------|
| `autoUpdates` | Whether to enable automatic updates (default: `true`). When enabled, Claude Code automatically downloads and installs updates in the background. Updates are applied when you restart Claude Code. | `false` |
| `preferredNotifChannel` | Where you want to receive notifications (default: `iterm2`) | `iterm2`, `iterm2_with_bell`, `terminal_bell`, or `notifications_disabled` |
| `theme` | Color theme | `dark`, `light`, `light-daltonized`, or `dark-daltonized` |
| `verbose` | Whether to show full bash and command outputs (default: `false`) | `true` |

## Tools available to Claude

Claude Code has access to a set of powerful tools that help it understand and modify your codebase:

| Tool | Description | Permission Required |
|------|-------------|-------------------|
| **Bash** | Executes shell commands in your environment | Yes |
| **Edit** | Makes targeted edits to specific files | Yes |
| **Glob** | Finds files based on pattern matching | No |
| **Grep** | Searches for patterns in file contents | No |
| **LS** | Lists files and directories | No |
| **MultiEdit** | Performs multiple edits on a single file atomically | Yes |
| **NotebookEdit** | Modifies Jupyter notebook cells | Yes |
| **NotebookRead** | Reads and displays Jupyter notebook contents | No |
| **Read** | Reads the contents of files | No |
| **Task** | Runs a sub-agent to handle complex, multi-step tasks | No |
| **TodoWrite** | Creates and manages structured task lists | No |
| **WebFetch** | Fetches content from a specified URL | Yes |
| **WebSearch** | Performs web searches with domain filtering | Yes |
| **Write** | Creates or overwrites files | Yes |

Permission rules can be configured using `/allowed-tools` or in [permission settings](https://docs.anthropic.com/en/docs/claude-code/iam#configuring-permissions).

### Extending tools with hooks

You can run custom commands before or after any tool executes using Claude Code hooks.

For example, you could automatically run a Python formatter after Claude modifies Python files, or prevent modifications to production configuration files by blocking Write operations to certain paths.

See [Claude Code hooks](https://docs.anthropic.com/en/docs/claude-code/hooks-guide) documentation for more details.

## Permission Configuration

### Permission Modes

Claude Code supports several permission modes that control how Claude interacts with your system:

- **default**: Requires explicit approval for potentially destructive operations
- **acceptEdits**: Automatically approves file edits but asks for other operations
- **plan**: Read-only mode, useful for code reviews and analysis
- **bypassPermissions**: Allows all operations (use with caution)

### Permission Rules

Permission rules use pattern matching to control tool access:

```json
{
  "permissions": {
    "allow": [
      "Read(**/*)",
      "Bash(git diff:*)",
      "Bash(git status)"
    ],
    "ask": [
      "Bash(git commit:*)",
      "Bash(git push:*)"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./secrets/**)",
      "Bash(rm:*)",
      "Bash(curl:*)",
      "WebFetch"
    ]
  }
}
```

### Working Directories

Control which directories Claude can access:

```json
{
  "permissions": {
    "additionalDirectories": [
      "../docs/",
      "../shared/"
    ]
  }
}
```

## MCP Configuration

Model Context Protocol (MCP) servers can be configured in settings:

```json
{
  "enableAllProjectMcpServers": true,
  "enabledMcpjsonServers": ["memory", "github"],
  "disabledMcpjsonServers": ["filesystem"]
}
```

## Status Line Configuration

Customize the terminal status line to show context:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

Or use the built-in status line:

```json
{
  "statusLine": {
    "type": "builtin"
  }
}
```

## Model Configuration

Override the default model:

```json
{
  "model": "claude-3-5-sonnet-20241022"
}
```

## Environment Configuration

Set environment variables for all sessions:

```json
{
  "env": {
    "NODE_ENV": "development",
    "PYTHONPATH": "./src:./tests"
  }
}
```

## Hook Configuration

Configure custom hooks for tool events:

```json
{
  "hooks": {
    "PreToolUse": {
      "Write": "echo 'About to write to file'"
    },
    "PostToolUse": {
      "Bash": "echo 'Command completed'"
    }
  }
}
```

## Best Practices

### Security

- Use `deny` rules to protect sensitive files and directories
- Regularly review permission settings
- Use environment variables for sensitive credentials
- Enable audit logging for compliance requirements

### Performance

- Configure appropriate timeouts for long-running operations
- Use MCP servers for frequently accessed external data
- Limit file access patterns to improve performance
- Monitor resource usage with verbose logging

### Team Collaboration

- Share project settings in version control
- Use `.claude/settings.local.json` for personal preferences
- Document configuration choices for team members
- Regularly review and update shared configurations

### Enterprise Deployment

- Use managed policy settings for security compliance
- Deploy configurations across the organization
- Monitor and audit configuration changes
- Integrate with existing IT management systems

## Troubleshooting

### Common Issues

1. **Settings not applying**: Check settings precedence and ensure files are in correct locations
2. **Permission errors**: Review permission rules and ensure patterns are correctly formatted
3. **Environment variables not set**: Verify variable names and check if they're being overridden
4. **MCP servers not working**: Check server configurations and authentication

### Debug Commands

```bash
# List all settings
claude config list

# Check specific setting
claude config get permissions

# Verify file locations
ls -la ~/.claude/settings.json
ls -la .claude/settings.json

# Test permission rules
claude config test-permissions

# Check MCP server status
claude mcp status
```

### Configuration Validation

Claude Code validates settings files on startup and will report errors for:

- Invalid JSON syntax
- Unknown configuration keys
- Invalid permission rule patterns
- Missing required values
- Type mismatches

## See also

- [Identity and Access Management](https://docs.anthropic.com/en/docs/claude-code/iam#configuring-permissions) - Learn about Claude Code's permission system
- [IAM and access control](https://docs.anthropic.com/en/docs/claude-code/iam#enterprise-managed-policy-settings) - Enterprise policy management
- [Troubleshooting](https://docs.anthropic.com/en/docs/claude-code/troubleshooting#auto-updater-issues) - Solutions for common configuration issues
- [Analytics](https://docs.anthropic.com/en/docs/claude-code/analytics) - Usage monitoring and insights
- [Add Claude Code to your IDE](https://docs.anthropic.com/en/docs/claude-code/ide-integrations) - IDE integration setup

---

*This documentation was downloaded from Anthropic docs and saved locally for reference.*