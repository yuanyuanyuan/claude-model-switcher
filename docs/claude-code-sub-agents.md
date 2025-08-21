# Claude Code Subagents Documentation

*Downloaded from: https://docs.anthropic.com/en/docs/claude-code/sub-agents*
*Download date: 2025-08-21*

---

## Overview

Custom subagents in Claude Code are specialized AI assistants that can be invoked to handle specific types of tasks. They enable more efficient problem-solving by providing task-specific configurations with customized system prompts, tools and a separate context window.

## What are subagents?

Subagents are pre-configured AI personalities that Claude Code can delegate tasks to. Each subagent:

- Has a specific purpose and expertise area
- Uses its own context window separate from the main conversation
- Can be configured with specific tools it's allowed to use
- Includes a custom system prompt that guides its behavior

When Claude Code encounters a task that matches a subagent's expertise, it can delegate that task to the specialized subagent, which works independently and returns results.

## Key benefits

- **Specialized expertise**: Each subagent focuses on a specific domain or task type
- **Context isolation**: Subagents use separate context windows, preserving main conversation context
- **Tool control**: Granular control over which tools each subagent can access
- **Improved performance**: Task-specific configurations lead to better results
- **Reusability**: Create once, use across multiple projects and conversations

## Quick start

To create your first subagent:

1. **Open the agents interface**: Use the `/agents` command in Claude Code
2. **Create new agent**: Follow the guided setup to define your subagent
3. **Configure tools**: Select which tools the subagent should have access to
4. **Test and refine**: Use the subagent and iterate on its configuration

## Subagent configuration

### File locations

Subagents are stored as Markdown files with YAML frontmatter in two possible locations:

| Type | Location | Scope | Priority |
|------|----------|-------|----------|
| **Project subagents** | `.claude/agents/` | Available in current project | Highest |
| **User subagents** | `~/.claude/agents/` | Available across all projects | Lower |

When subagent names conflict, project-level subagents take precedence over user-level subagents.

### File format

Each subagent is defined in a Markdown file with this structure:

```markdown
---
name: my-specialist
description: A specialist that handles specific tasks
tools: Read,Write,Bash,Grep
---

# System Prompt

You are a specialist assistant focused on [specific domain]. Your expertise includes:

- [Area 1]
- [Area 2]
- [Area 3]

## Guidelines

- Always follow these specific rules...
- Use these approaches...
- Consider these constraints...

## Examples

When asked to [task], you should:

1. First [step 1]
2. Then [step 2]
3. Finally [step 3]
```

### Configuration fields

| Field | Required | Description |
|------|----------|-------------|
| `name` | Yes | Unique identifier using lowercase letters and hyphens |
| `description` | Yes | Natural language description of the subagent's purpose |
| `tools` | No | Comma-separated list of specific tools. If omitted, inherits all tools from the main thread |

### Available tools

Subagents can be granted access to any of Claude Code's internal tools. See the [tools documentation](https://docs.anthropic.com/en/docs/claude-code/settings#tools-available-to-claude) for a complete list of available tools.

You have two options for configuring tools:

- **Omit the `tools` field** to inherit all tools from the main thread (default), including MCP tools
- **Specify individual tools** as a comma-separated list for more granular control (can be edited manually or via `/agents`)

**MCP Tools**: Subagents can access MCP tools from configured MCP servers. When the `tools` field is omitted, subagents inherit all MCP tools available to the main thread.

## Managing subagents

### Using the /agents command (Recommended)

The `/agents` command provides a comprehensive interface for subagent management:

This opens an interactive menu where you can:

- View all available subagents (built-in, user, and project)
- Create new subagents with guided setup
- Edit existing custom subagents, including their tool access
- Delete custom subagents
- See which subagents are active when duplicates exist
- **Easily manage tool permissions** with a complete list of available tools

### Direct file management

You can also manage subagents by working directly with their files:

**Create a subagent:**
```bash
# Create project-level subagent
mkdir -p .claude/agents
cat > .claude/agents/code-reviewer.md << 'EOF'
---
name: code-reviewer
description: Reviews code for quality, security, and best practices
tools: Read,Write,Bash,Grep,WebSearch
---

# Code Review Specialist

You are an expert code reviewer specializing in:

- Code quality and maintainability
- Security vulnerability identification
- Performance optimization
- Best practices and design patterns
- Testing and documentation

## Review Process

When reviewing code, always:

1. **Security First**: Identify potential security vulnerabilities
2. **Quality Assessment**: Check for code quality issues
3. **Performance**: Look for performance bottlenecks
4. **Best Practices**: Ensure adherence to coding standards
5. **Testing**: Verify adequate test coverage

## Output Format

Provide structured feedback with:
- Critical issues (must fix)
- Recommendations (should fix)
- Suggestions (nice to have)
- Positive feedback (what's done well)
EOF
```

**Edit a subagent:**
```bash
# Edit existing subagent
nano .claude/agents/code-reviewer.md
```

**List subagents:**
```bash
# List project subagents
ls -la .claude/agents/

# List user subagents
ls -la ~/.claude/agents/
```

## Using subagents effectively

### Automatic delegation

Claude Code proactively delegates tasks based on:

- The task description in your request
- The `description` field in subagent configurations
- Current context and available tools

**Example:**
```
User: "Please review this pull request for security issues"
Claude: [Detects security review task] → Delegates to security-reviewer subagent
```

### Explicit invocation

Request a specific subagent by mentioning it in your command:

```
"Ask the code-reviewer to check this function"
"Use the data-scientist to analyze these results"
"Have the security-auditor review this configuration"
```

## Example subagents

### Code reviewer

```markdown
---
name: code-reviewer
description: Reviews code for quality, security, and best practices
tools: Read,Write,Bash,Grep,WebSearch
---

# Code Review Specialist

You are an expert code reviewer specializing in:

- Code quality and maintainability
- Security vulnerability identification
- Performance optimization
- Best practices and design patterns
- Testing and documentation

## Review Process

When reviewing code, always:

1. **Security First**: Identify potential security vulnerabilities
2. **Quality Assessment**: Check for code quality issues
3. **Performance**: Look for performance bottlenecks
4. **Best Practices**: Ensure adherence to coding standards
5. **Testing**: Verify adequate test coverage

## Output Format

Provide structured feedback with:
- Critical issues (must fix)
- Recommendations (should fix)
- Suggestions (nice to have)
- Positive feedback (what's done well)
```

### Debugger

```markdown
---
name: debugger
description: Diagnoses and helps fix bugs and issues in code
tools: Read,Write,Bash,Grep,Edit,MultiEdit
---

# Debugging Specialist

You are an expert debugger specializing in:

- Root cause analysis
- Bug reproduction and isolation
- Performance issue diagnosis
- Systematic troubleshooting
- Fix validation

## Debugging Approach

When debugging issues, follow this systematic approach:

1. **Understand the Problem**: Clearly identify symptoms and expected behavior
2. **Reproduce the Issue**: Create minimal reproduction cases
3. **Analyze the Code**: Examine relevant code paths and dependencies
4. **Identify Root Cause**: Find the underlying issue, not just symptoms
5. **Implement Fix**: Apply targeted, minimal changes
6. **Verify Solution**: Test that the fix resolves the issue

## Tools and Techniques

- Use logging and debugging tools effectively
- Break down complex problems into smaller components
- Consider edge cases and error conditions
- Verify fixes don't introduce new issues
```

### Data scientist

```markdown
---
name: data-scientist
description: Analyzes data, creates visualizations, and builds models
tools: Read,Write,Bash,Edit,MultiEdit,WebSearch
---

# Data Science Specialist

You are an expert data scientist specializing in:

- Data analysis and exploration
- Statistical analysis and hypothesis testing
- Machine learning model development
- Data visualization and reporting
- Experimental design and A/B testing

## Analysis Process

When working with data, always:

1. **Understand the Data**: Examine structure, quality, and characteristics
2. **Define Objectives**: Clarify what questions need to be answered
3. **Explore and Clean**: Handle missing values, outliers, and data quality issues
4. **Analyze**: Apply appropriate statistical methods and models
5. **Visualize**: Create clear, informative visualizations
6. **Interpret**: Provide actionable insights and recommendations

## Technical Skills

- Proficient in Python, R, SQL, and data analysis libraries
- Experience with various machine learning algorithms
- Strong statistical foundation
- Data visualization expertise
- Experimental design knowledge
```

## Best practices

- **Start with Claude-generated agents**: We highly recommend generating your initial subagent with Claude and then iterating on it to make it personally yours. This approach gives you the best results - a solid foundation that you can customize to your specific needs.

- **Design focused subagents**: Create subagents with single, clear responsibilities rather than trying to make one subagent do everything. This improves performance and makes subagents more predictable.

- **Write detailed prompts**: Include specific instructions, examples, and constraints in your system prompts. The more guidance you provide, the better the subagent will perform.

- **Limit tool access**: Only grant tools that are necessary for the subagent's purpose. This improves security and helps the subagent focus on relevant actions.

- **Version control**: Check project subagents into version control so your team can benefit from and improve them collaboratively.

## Advanced usage

### Chaining subagents

For complex workflows, you can chain multiple subagents:

```
User: "Build a complete data analysis pipeline"
Claude: 
1. [Data modeling] → Delegates to data-scientist
2. [Code review] → Delegates to code-reviewer  
3. [Testing] → Delegates to test-automation
4. [Integration] → Handles integration itself
```

### Dynamic subagent selection

Claude Code intelligently selects subagents based on context. Make your `description` fields specific and action-oriented for best results.

**Good descriptions:**
- "Reviews Python code for security vulnerabilities and compliance issues"
- "Analyzes JSON data structures and provides optimization recommendations"
- "Debugs JavaScript runtime errors and performance issues"

**Poor descriptions:**
- "Helps with code"
- "Data analysis"
- "General purpose assistant"

## Performance considerations

- **Context efficiency**: Agents help preserve main context, enabling longer overall sessions
- **Latency**: Subagents start off with a clean slate each time they are invoked and may add latency as they gather context that they require to do their job effectively.

## Related documentation

- [Slash commands](https://docs.anthropic.com/en/docs/claude-code/slash-commands) - Learn about other built-in commands
- [Settings](https://docs.anthropic.com/en/docs/claude-code/settings) - Configure Claude Code behavior
- [Hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) - Automate workflows with event handlers
- [Claude Code SDK](https://docs.anthropic.com/en/docs/claude-code/sdk) - Build custom AI agents

---

*This documentation was downloaded from Anthropic docs and saved locally for reference.*