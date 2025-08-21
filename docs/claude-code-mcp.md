# Claude Code MCP Documentation

*Downloaded from: https://docs.anthropic.com/en/docs/claude-code/mcp*
*Download date: 2025-08-21*

---

## Overview

Claude Code can connect to hundreds of external tools and data sources through the Model Context Protocol (MCP), an open-source standard for AI-tool integrations. MCP servers give Claude Code access to your tools, databases, and APIs.

## What you can do with MCP

With MCP servers connected, you can ask Claude Code to:

- **Implement features from issue trackers**: "Add the feature described in JIRA issue ENG-4521 and create a PR on GitHub."
- **Analyze monitoring data**: "Check Sentry and Statsig to check the usage of the feature described in ENG-4521."
- **Query databases**: "Find emails of 10 random users who used feature ENG-4521, based on our Postgres database."
- **Integrate designs**: "Update our standard email template based on the new Figma designs that were posted in Slack"
- **Automate workflows**: "Create Gmail drafts inviting these 10 users to a feedback session about the new feature."

## Popular MCP servers

Here are some commonly used MCP servers you can connect to Claude Code:

### Development & Testing Tools

**Sentry** - Monitor errors, debug production issues
```bash
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
```

**Socket** - Security analysis for dependencies
```bash
claude mcp add --transport http socket https://mcp.socket.dev/
```

**Hugging Face** - Provides access to Hugging Face Hub information and Gradio AI Applications
```bash
claude mcp add --transport http hugging-face https://huggingface.co/mcp
```

**Jam** - Debug faster with AI agents that can access Jam recordings like video, console logs, network requests, and errors
```bash
claude mcp add --transport http jam https://mcp.jam.dev/mcp
```

### Project Management & Documentation

**Asana** - Interact with your Asana workspace to keep projects on track
```bash
claude mcp add --transport sse asana https://mcp.asana.com/sse
```

**Atlassian** - Manage your Jira tickets and Confluence docs
```bash
claude mcp add --transport sse atlassian https://mcp.atlassian.com/v1/sse
```

**ClickUp** - Task management, project tracking
```bash
claude mcp add clickup --env CLICKUP_API_KEY=YOUR_KEY --env CLICKUP_TEAM_ID=YOUR_ID -- npx -y @hauptsache.net/clickup-mcp
```

**Intercom** - Access real-time customer conversations, tickets, and user data
```bash
claude mcp add --transport http intercom https://mcp.intercom.com/mcp
```

**Linear** - Integrate with Linear's issue tracking and project management
```bash
claude mcp add --transport sse linear https://mcp.linear.app/sse
```

**Notion** - Read docs, update pages, manage tasks
```bash
claude mcp add --transport http notion https://mcp.notion.com/mcp
```

**Box** - Ask questions about your enterprise content, get insights from unstructured data, automate content workflows
```bash
claude mcp add --transport http box https://mcp.box.com/
```

**Fireflies** - Extract valuable insights from meeting transcripts and summaries
```bash
claude mcp add --transport http fireflies https://api.fireflies.ai/mcp
```

**Monday.com** - Manage monday.com boards by creating items, updating columns, assigning owners, setting timelines, adding CRM activities, and writing summaries
```bash
claude mcp add --transport sse monday https://mcp.monday.com/sse
```

### Databases & Data Management

**Airtable** - Read/write records, manage bases and tables
```bash
claude mcp add airtable --env AIRTABLE_API_KEY=YOUR_KEY -- npx -y airtable-mcp-server
```

**Daloopa** - Supplies high quality fundamental financial data sourced from SEC Filings, investor presentations
```bash
claude mcp add --transport http daloopa https://mcp.daloopa.com/server/mcp
```

**HubSpot** - Access and manage HubSpot CRM data by fetching contacts, companies, and deals, and creating and updating records
```bash
claude mcp add --transport http hubspot https://mcp.hubspot.com/anthropic
```

### Payments & Commerce

**PayPal** - Integrate PayPal commerce capabilities, payment processing, transaction management
```bash
claude mcp add --transport http paypal https://mcp.paypal.com/mcp
```

**Plaid** - Analyze, troubleshoot, and optimize Plaid integrations. Banking data, financial account linking
```bash
claude mcp add --transport sse plaid https://api.dashboard.plaid.com/mcp/sse
```

**Square** - Use an agent to build on Square APIs. Payments, inventory, orders, and more
```bash
claude mcp add --transport sse square https://mcp.squareup.com/sse
```

**Stripe** - Payment processing, subscription management, and financial transactions
```bash
claude mcp add --transport http stripe https://mcp.stripe.com
```

### Design & Media

**Figma** - Access designs, export assets. Requires latest Figma Desktop with Dev Mode MCP Server. If you have an existing server at http://127.0.0.1:3845/sse, delete it first before adding the new one.
```bash
claude mcp add --transport http figma-dev-mode-mcp-server http://127.0.0.1:3845/mcp
```

**InVideo** - Build video creation capabilities into your applications
```bash
claude mcp add --transport sse invideo https://mcp.invideo.io/sse
```

**Canva** - Browse, summarize, autofill, and even generate new Canva designs directly from Claude
```bash
claude mcp add --transport http canva https://mcp.canva.com/mcp
```

### Infrastructure & DevOps

**Cloudflare** - Build applications, analyze traffic, monitor performance, and manage security settings through Cloudflare. Multiple services available. See documentation for specific server URLs. Claude Code can use the Cloudflare CLI if installed.

**Netlify** - Create, deploy, and manage websites on Netlify. Control all aspects of your site from creating secrets to enforcing access controls to aggregating form submissions
```bash
claude mcp add --transport http netlify https://netlify-mcp.netlify.app/mcp
```

**Stytch** - Configure and manage Stytch authentication services, redirect URLs, email templates, and workspace settings
```bash
claude mcp add --transport http stytch http://mcp.stytch.dev/mcp
```

**Vercel** - Vercel's official MCP server, allowing you to search and navigate documentation, manage projects and deployments, and analyze deployment logs—all in one place
```bash
claude mcp add --transport http vercel https://mcp.vercel.com/
```

### Automation & Integration

**Workato** - Access any application, workflows or data via Workato, made accessible for AI. MCP servers are programmatically generated

**Zapier** - Connect to nearly 8,000 apps through Zapier's automation platform. Generate a user-specific URL at mcp.zapier.com

## Installing MCP servers

MCP servers can be configured in three different ways depending on your needs:

### Option 1: Add a local stdio server

Stdio servers run as local processes on your machine. They're ideal for tools that need direct system access or custom scripts.

### Option 2: Add a remote SSE server

SSE (Server-Sent Events) servers provide real-time streaming connections. Many cloud services use this for live updates.

### Option 3: Add a remote HTTP server

HTTP servers use standard request/response patterns. Most REST APIs and web services use this transport.

### Managing your servers

Once configured, you can manage your MCP servers with these commands:

- `claude mcp list` - List all configured servers
- `claude mcp remove <server-name>` - Remove a server
- `claude mcp reset` - Reset all MCP configurations
- `claude mcp status` - Check server status

## MCP installation scopes

MCP servers can be configured at three different scope levels, each serving distinct purposes for managing server accessibility and sharing. Understanding these scopes helps you determine the best way to configure servers for your specific needs.

### Local scope

Local-scoped servers represent the default configuration level and are stored in your project-specific user settings. These servers remain private to you and are only accessible when working within the current project directory. This scope is ideal for personal development servers, experimental configurations, or servers containing sensitive credentials that shouldn't be shared.

### Project scope

Project-scoped servers enable team collaboration by storing configurations in a `.mcp.json` file at your project's root directory. This file is designed to be checked into version control, ensuring all team members have access to the same MCP tools and services. When you add a project-scoped server, Claude Code automatically creates or updates this file with the appropriate configuration structure.

The resulting `.mcp.json` file follows a standardized format:

```json
{
  "mcpServers": {
    "sentry": {
      "command": "npx",
      "args": ["-y", "@sentry/mcp-server"],
      "env": {
        "SENTRY_AUTH_TOKEN": "${SENTRY_AUTH_TOKEN}"
      }
    },
    "slack": {
      "transport": "sse",
      "url": "https://mcp.slack.com/sse"
    }
  }
}
```

For security reasons, Claude Code prompts for approval before using project-scoped servers from `.mcp.json` files. If you need to reset these approval choices, use the `claude mcp reset-project-choices` command.

### User scope

User-scoped servers provide cross-project accessibility, making them available across all projects on your machine while remaining private to your user account. This scope works well for personal utility servers, development tools, or services you frequently use across different projects.

### Choosing the right scope

Select your scope based on:

- **Local scope**: Personal servers, experimental configurations, or sensitive credentials specific to one project
- **Project scope**: Team-shared servers, project-specific tools, or services required for collaboration
- **User scope**: Personal utilities needed across multiple projects, development tools, or frequently-used services

### Scope hierarchy and precedence

MCP server configurations follow a clear precedence hierarchy. When servers with the same name exist at multiple scopes, the system resolves conflicts by prioritizing local-scoped servers first, followed by project-scoped servers, and finally user-scoped servers. This design ensures that personal configurations can override shared ones when needed.

### Environment variable expansion in `.mcp.json`

Claude Code supports environment variable expansion in `.mcp.json` files, allowing teams to share configurations while maintaining flexibility for machine-specific paths and sensitive values like API keys.

**Supported syntax:**
- `${VAR}` - Expands to the value of environment variable `VAR`
- `${VAR:-default}` - Expands to `VAR` if set, otherwise uses `default`

**Expansion locations:** Environment variables can be expanded in:
- `command` - The server executable path
- `args` - Command-line arguments
- `env` - Environment variables passed to the server
- `url` - For SSE/HTTP server types
- `headers` - For SSE/HTTP server authentication

**Example with variable expansion:**
```json
{
  "mcpServers": {
    "postgres": {
      "command": "${POSTGRES_CLIENT_PATH:-psql}",
      "args": ["-h", "${DB_HOST:-localhost}", "-U", "${DB_USER}"],
      "env": {
        "PGPASSWORD": "${DB_PASSWORD}"
      }
    }
  }
}
```

If a required environment variable is not set and has no default value, Claude Code will fail to parse the config.

## Practical examples

### Example: Monitor errors with Sentry

1. **Add the Sentry MCP server:**
```bash
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
```

2. **Configure authentication:**
```bash
export SENTRY_AUTH_TOKEN="your-token-here"
```

3. **Use in conversation:**
```
Check Sentry for any new errors related to the payment processing feature
```

### Example: Query databases with PostgreSQL

1. **Add a PostgreSQL MCP server:**
```bash
claude mcp add postgres --command psql --args "-h localhost -U user" --env PGPASSWORD="${DB_PASSWORD}"
```

2. **Query the database:**
```
Find all users who signed up in the last 30 days and their email addresses
```

## Authenticate with remote MCP servers

Many cloud-based MCP servers require authentication. Claude Code supports OAuth 2.0 for secure connections.

### OAuth 2.0 Authentication Flow

1. **Initiate authentication:**
```bash
claude mcp auth <server-name>
```

2. **Complete authentication in browser**
3. **Server is now authenticated and ready to use**

### API Key Authentication

For servers that use API keys:

1. **Set environment variable:**
```bash
export API_KEY="your-api-key-here"
```

2. **Add server with authentication:**
```bash
claude mcp add <server-name> --env API_KEY="${API_KEY}"
```

## Add MCP servers from JSON configuration

If you have a JSON configuration for an MCP server, you can add it directly:

1. **Create configuration file:**
```json
{
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["server.js"],
      "env": {
        "API_KEY": "your-key"
      }
    }
  }
}
```

2. **Import the configuration:**
```bash
claude mcp import --file config.json --scope project
```

## Import MCP servers from Claude Desktop

If you've already configured MCP servers in Claude Desktop, you can import them:

1. **List available servers:**
```bash
claude mcp import --list-claude-desktop
```

2. **Import specific server:**
```bash
claude mcp import --from-claude-desktop <server-name> --scope user
```

3. **Import all servers:**
```bash
claude mcp import --from-claude-desktop --all --scope project
```

## Use Claude Code as an MCP server

You can use Claude Code itself as an MCP server that other applications can connect to:

1. **Start Claude Code as MCP server:**
```bash
claude --mcp-server
```

2. **Configure in Claude Desktop:**
```json
{
  "mcpServers": {
    "claude-code": {
      "command": "claude",
      "args": ["--mcp-server"]
    }
  }
}
```

## Use MCP resources

MCP servers can expose resources that you can reference using @ mentions, similar to how you reference files.

### Reference MCP resources

1. **List available resources:**
```bash
claude mcp resources
```

2. **Reference a resource:**
```
Analyze the @sentry:project/my-project resource
```

3. **Get resource details:**
```
Show me details about @notion:page/1234567890
```

### Reference MCP resources

Some MCP servers expose resources that can be referenced using @ mentions:

- **Database records**: `@postgres:users/123`
- **Project management**: `@jira:ticket/PROJ-123`
- **Documentation**: `@notion:page/my-page`
- **Monitoring**: `@sentry:project/my-project`

## Use MCP prompts as slash commands

MCP servers can expose prompts that become available as slash commands in Claude Code.

### Execute MCP prompts

1. **List available prompts:**
```bash
claude mcp prompts
```

2. **Execute a prompt:**
```bash
claude /prompt-name "your input here"
```

3. **Execute with parameters:**
```bash
claude /deploy "my-feature" --environment staging
```

### Available MCP prompts

Different MCP servers expose different prompts:

- **Project management**: `/create-ticket`, `/update-status`
- **Deployment**: `/deploy`, `/rollback`
- **Documentation**: `/create-doc`, `/update-page`
- **Monitoring**: `/check-health`, `/get-metrics`

## MCP Best Practices

### Security

- **Use environment variables** for sensitive credentials
- **Limit server permissions** to only what's necessary
- **Review server configurations** before committing to version control
- **Use appropriate scopes** to control access

### Performance

- **Monitor server performance** and resource usage
- **Use caching** where appropriate for frequently accessed data
- **Configure timeouts** for long-running operations
- **Consider connection limits** for remote servers

### Configuration Management

- **Use version control** for project-scoped configurations
- **Document server dependencies** and requirements
- **Test configurations** in development environments
- **Use environment variable expansion** for flexible configurations

### Troubleshooting

- **Check server status** with `claude mcp status`
- **Review logs** for connection or authentication issues
- **Test server connectivity** independently
- **Verify environment variables** are properly set

## Advanced MCP Features

### Dynamic Server Loading

Some MCP servers support dynamic loading of additional capabilities:

```bash
claude mcp add <server-name> --dynamic-load
```

### Server Groups

Organize related servers into groups for easier management:

```bash
claude mcp group create "development" --servers postgres,redis,local-dev
claude mcp group create "production" --servers sentry,datadog,monitoring
```

### Custom Transports

For specialized requirements, you can define custom transport configurations:

```bash
claude mcp add custom-server --transport custom --config transport-config.json
```

## MCP Server Development

If you need to develop your own MCP servers:

1. **Use the MCP SDK**: https://modelcontextprotocol.io/quickstart/server
2. **Follow MCP specifications**: Ensure compliance with the protocol
3. **Test thoroughly**: Validate with Claude Code and other MCP clients
4. **Document your server**: Provide clear installation and usage instructions

## Related Documentation

- [Model Context Protocol](https://modelcontextprotocol.io/introduction) - Official MCP documentation
- [MCP SDK](https://modelcontextprotocol.io/quickstart/server) - Server development guide
- [GitHub Actions](https://docs.anthropic.com/en/docs/claude-code/github-actions) - CI/CD integration
- [Troubleshooting](https://docs.anthropic.com/en/docs/claude-code/troubleshooting) - Common issues and solutions

---

*This documentation was downloaded from Anthropic docs and saved locally for reference.*