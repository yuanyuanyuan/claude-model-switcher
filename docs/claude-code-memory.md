# Claude Code Memory Management Documentation

*Downloaded from: https://docs.anthropic.com/en/docs/claude-code/memory*
*Download date: 2025-08-21*

---

## Overview

Claude Code can remember your preferences across sessions, like style guidelines and common commands in your workflow.

## Determine memory type

Claude Code offers four memory locations in a hierarchical structure, each serving a different purpose:

| Memory Type | Location | Purpose | Use Case Examples | Shared With |
|-------------|----------|---------|-------------------|-------------|
| **Enterprise policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`<br>Linux: `/etc/claude-code/CLAUDE.md`<br>Windows: `C:\ProgramData\ClaudeCode\CLAUDE.md` | Organization-wide instructions managed by IT/DevOps | Company coding standards, security policies, compliance requirements | All users in organization |
| **Project memory** | `./CLAUDE.md` | Team-shared instructions for the project | Project architecture, coding standards, common workflows | Team members via source control |
| **User memory** | `~/.claude/CLAUDE.md` | Personal preferences for all projects | Code styling preferences, personal tooling shortcuts | Just you (all projects) |
| **Project memory (local)** | `./CLAUDE.local.md` | Personal project-specific preferences | *(Deprecated, see below)* Your sandbox URLs, preferred test data | Just you (current project) |

All memory files are automatically loaded into Claude Code's context when launched. Files higher in the hierarchy take precedence and are loaded first, providing a foundation that more specific memories build upon.

## CLAUDE.md imports

CLAUDE.md files can import additional files using `@path/to/import` syntax. The following example imports 3 files:

```markdown
# Project Guidelines

@./architectural-principles.md
@../shared/coding-standards.md
@~/.claude/personal-preferences.md

## Project Overview

This project follows the architectural principles defined in our imported files...
```

Both relative and absolute paths are allowed. In particular, importing files in user's home dir is a convenient way for your team members to provide individual instructions that are not checked into the repository. Previously `CLAUDE.local.md` served a similar purpose, but is now deprecated in favor of imports since they work better across multiple git worktrees.

To avoid potential collisions, imports are not evaluated inside markdown code spans and code blocks.

Imported files can recursively import additional files, with a max-depth of 5 hops. You can see what memory files are loaded by running `/memory` command.

## How Claude looks up memories

Claude Code reads memories recursively: starting in the cwd, Claude Code recurses up to (but not including) the root directory `/` and reads any CLAUDE.md or CLAUDE.local.md files it finds. This is especially convenient when working in large repositories where you run Claude Code in `foo/bar/`, and have memories in both `foo/CLAUDE.md` and `foo/bar/CLAUDE.md`.

Claude will also discover CLAUDE.md nested in subtrees under your current working directory. Instead of loading them at launch, they are only included when Claude reads files in those subtrees.

## Quickly add memories with the `#` shortcut

The fastest way to add a memory is to start your input with the `#` character:

```
# Use 2-space indentation for Python files
```

You'll be prompted to select which memory file to store this in.

## Directly edit memories with `/memory`

Use the `/memory` slash command during a session to open any memory file in your system editor for more extensive additions or organization.

## Set up project memory

Suppose you want to set up a CLAUDE.md file to store important project information, conventions, and frequently used commands.

Bootstrap a CLAUDE.md for your codebase with the following command:

```bash
claude memory init
```

This will create a comprehensive CLAUDE.md file with sections for:

- Project overview and architecture
- Coding standards and style guidelines
- Common commands and workflows
- Testing practices
- Deployment procedures
- Team collaboration guidelines

Example generated CLAUDE.md:

```markdown
# Project Memory

## Project Overview
This is a [project type] project that [main purpose].

## Architecture
- Frontend: [technologies used]
- Backend: [technologies used]
- Database: [database type]
- Deployment: [deployment method]

## Coding Standards

### General
- Use [indentation style] indentation
- Follow [naming convention]
- Maximum line length: [number] characters

### Language-Specific
- [Language 1]: [specific rules]
- [Language 2]: [specific rules]

## Common Commands

### Development
```bash
# Start development server
npm run dev

# Run tests
npm test

# Build project
npm run build
```

### Database
```bash
# Run migrations
npm run migrate

# Access database
npm run db:shell
```

### Deployment
```bash
# Deploy to staging
npm run deploy:staging

# Deploy to production
npm run deploy:prod
```

## Testing
- Write unit tests for all new features
- Maintain [test coverage]% test coverage
- Use [testing framework] for testing

## Code Review
- All PRs must be reviewed by at least [number] team members
- Use [code review tool] for automated checks
- Follow [PR template] for pull requests

## Documentation
- Update documentation for all new features
- Use [documentation format]
- Keep documentation in sync with code changes
```

## Organization-level memory management

Enterprise organizations can deploy centrally managed CLAUDE.md files that apply to all users.

To set up organization-level memory management:

1. **Create the enterprise memory file** in the appropriate location for your operating system:

   - **macOS**: `/Library/Application Support/ClaudeCode/CLAUDE.md`
   - **Linux/WSL**: `/etc/claude-code/CLAUDE.md`
   - **Windows**: `C:\ProgramData\ClaudeCode\CLAUDE.md`

2. **Deploy via your configuration management system** (MDM, Group Policy, Ansible, etc.) to ensure consistent distribution across all developer machines.

Example enterprise CLAUDE.md:

```markdown
# Enterprise Development Standards

## Security Requirements
- All code must pass security scanning before deployment
- Use approved libraries from our artifact registry
- Follow our secure coding guidelines
- Report security vulnerabilities through our designated channels

## Compliance Standards
- Adhere to [industry standards] for data handling
- Maintain proper audit trails for all operations
- Follow our data retention policies
- Use approved encryption methods for sensitive data

## Development Tools
- Use [IDE] with our approved plugins
- Configure [linting tool] with our enterprise rules
- Use [version control] with our branching strategy
- Follow our build and deployment pipeline

## Communication
- Use [communication platform] for team discussions
- Follow our meeting protocols and documentation standards
- Use our project management tools for task tracking
- Participate in regular code reviews and knowledge sharing

## Training and Resources
- Complete required security training annually
- Attend regular development best practices workshops
- Use our internal knowledge base for reference
- Participate in mentoring and skill development programs
```

## Memory best practices

### Be Specific
- **Good**: "Use 2-space indentation for Python files and 4-space for JavaScript files"
- **Bad**: "Format code properly"

- **Good**: "Run tests with `npm test` before committing changes"
- **Bad**: "Test your code"

### Use Structure to Organize
Format each individual memory as a bullet point and group related memories under descriptive markdown headings:

```markdown
## Python Development
- Use 2-space indentation
- Follow PEP 8 naming conventions
- Include type hints for all function parameters
- Write docstrings for all public functions

## Database Operations
- Use parameterized queries to prevent SQL injection
- Always close database connections in finally blocks
- Use connection pooling for better performance
- Log all database operations for audit purposes

## Git Workflow
- Create feature branches from main
- Use descriptive branch names (feature/your-name/feature-description)
- Keep commits small and focused
- Include ticket numbers in commit messages
```

### Review Periodically
Update memories as your project evolves to ensure Claude is always using the most up to date information and context.

### Use Hierarchical Organization
Leverage the memory hierarchy effectively:

- **Enterprise level**: Company-wide policies and standards
- **Project level**: Project-specific architecture and workflows
- **User level**: Personal preferences and shortcuts
- **Local level**: (Deprecated) Use imports instead

### Import Related Files
Use imports to organize large memory files and share common configurations:

```markdown
# Project Memory

@./architecture.md
@./coding-standards.md
@../shared/company-policies.md
@~/.claude/personal-shortcuts.md

## Project-Specific Guidelines
[Project-specific content here]
```

### Avoid Redundancy
Don't repeat the same information across multiple memory files. Use imports to reference shared content instead.

### Use Clear, Actionable Language
Write memories as clear instructions that Claude can follow:

- **Good**: "Always run `npm test` before committing changes"
- **Bad**: "Testing is important"

### Version Control Important Memories
Check project-level CLAUDE.md files into version control to ensure team consistency:

```bash
git add CLAUDE.md
git commit -m "Add project memory guidelines"
```

### Test Memory Effectiveness
Regularly test if Claude is following your memories correctly:

1. Ask Claude to perform tasks that should use your memories
2. Verify the output follows your guidelines
3. Update memories if Claude isn't following them correctly

## Memory Commands Reference

### `/memory` - Manage Memory Files
```bash
# List all memory files
/memory list

# Open a specific memory file
/memory open ~/.claude/CLAUDE.md

# Show loaded memories
/memory show

# Check memory status
/memory status
```

### `/memory init` - Initialize Project Memory
```bash
# Create a new CLAUDE.md with template
/memory init

# Create with specific template
/memory init --template python-webapp
```

### `/memory import` - Manage Imports
```bash
# Add an import to current memory
/memory import ./shared-standards.md

# Remove an import
/memory import --remove ./deprecated-rules.md

# List all imports
/memory import --list
```

### `/memory validate` - Check Memory Files
```bash
# Validate current memory files
/memory validate

# Check for conflicts
/memory validate --check-conflicts

# Validate imports
/memory validate --imports
```

## Memory File Format

### Basic Structure
```markdown
# Memory Title

## Category 1
- Specific instruction 1
- Specific instruction 2
- Specific instruction 3

## Category 2
- Another instruction 1
- Another instruction 2

@path/to/imported-file.md

## Project-Specific Content
[Content specific to this project]
```

### Advanced Features
```markdown
# Advanced Project Memory

## Import Standards
@../company/standards.md
@./team-guidelines.md
@~/.claude/personal-config.md

## Environment Configuration
- Use Node.js version 18.x
- Set NODE_ENV=development for local development
- Use .env files for environment variables
- Never commit .env files to version control

## Development Workflow
1. Create feature branch from main
2. Make changes following coding standards
3. Run tests and linting
4. Commit changes with descriptive messages
5. Push branch and create pull request
6. Address review feedback
7. Merge to main after approval

## Code Quality Standards
- Maintain 90%+ test coverage
- All code must pass ESLint rules
- Use Prettier for code formatting
- Write comprehensive documentation
- Follow semantic versioning

## Common Commands
```bash
# Development
npm run dev          # Start development server
npm run test         # Run all tests
npm run test:watch   # Run tests in watch mode

# Database
npm run db:migrate   # Run database migrations
npm run db:seed      # Seed database with test data
npm run db:reset     # Reset database to clean state

# Deployment
npm run build        # Build for production
npm run deploy:staging  # Deploy to staging
npm run deploy:prod     # Deploy to production
```
```

## Troubleshooting Memory Issues

### Memory Not Loading
1. Check file locations are correct
2. Verify file permissions
3. Use `/memory status` to see loaded files
4. Check for syntax errors in memory files

### Conflicting Memories
1. Use `/memory validate --check-conflicts`
2. Review memory hierarchy precedence
3. Remove or update conflicting entries
4. Use imports to share common content

### Performance Issues
1. Limit memory file size (keep under 100KB)
2. Use imports to split large files
3. Remove outdated or redundant memories
4. Use `/memory validate` to check for issues

## Integration with Other Features

### Subagents
Memory files are automatically available to subagents, ensuring consistent behavior across specialized AI assistants.

### MCP Servers
Memory configurations can reference MCP server settings and usage guidelines.

### Hooks
Memory files can define custom hook behaviors and automation rules.

### Settings
Memory files work alongside JSON settings to provide both structured configuration and natural language guidance.

## Migration from CLAUDE.local.md

The `CLAUDE.local.md` approach is deprecated in favor of imports. To migrate:

1. **Create import structure**:
   ```markdown
   # CLAUDE.md
   
   @~/.claude/personal-config.md
   @./team-guidelines.md
   
   ## Project Content
   [Existing project content]
   ```

2. **Move personal content** to `~/.claude/personal-config.md`

3. **Move shared content** to appropriate shared files

4. **Delete CLAUDE.local.md** after migration

## See Also

- [Terminal configuration](https://docs.anthropic.com/en/docs/claude-code/terminal-config) - Terminal setup and customization
- [Status line configuration](https://docs.anthropic.com/en/docs/claude-code/statusline) - Status line display options
- [Settings](https://docs.anthropic.com/en/docs/claude-code/settings) - JSON configuration options
- [Identity and Access Management](https://docs.anthropic.com/en/docs/claude-code/iam) - Permission and access control

---

*This documentation was downloaded from Anthropic docs and saved locally for reference.*