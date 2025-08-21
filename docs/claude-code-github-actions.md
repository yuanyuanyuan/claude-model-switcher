# Claude Code GitHub Actions Documentation

*Downloaded from: https://docs.anthropic.com/en/docs/claude-code/github-actions*
*Download date: 2025-08-21*

---

## Overview

Claude Code GitHub Actions brings AI-powered automation to your GitHub workflow. With a simple `@claude` mention in any PR or issue, Claude can analyze your code, create pull requests, implement features, and fix bugs - all while following your project's standards.

- **Instant PR creation**: Describe what you need, and Claude creates a complete PR with all necessary changes
- **Automated code implementation**: Turn issues into working code with a single command
- **Follows your standards**: Claude respects your `CLAUDE.md` guidelines and existing code patterns
- **Simple setup**: Get started in minutes with our installer and API key
- **Secure by default**: Your code stays on Github's runners

## What can Claude do?

Claude Code provides powerful GitHub Actions that transform how you work with code:

### Claude Code Action

This GitHub Action allows you to run Claude Code within your GitHub Actions workflows. You can use this to build any custom workflow on top of Claude Code.

[View repository →](https://github.com/anthropics/claude-code-action)

### Claude Code Action (Base)

The foundation for building custom GitHub workflows with Claude. This extensible framework gives you full access to Claude's capabilities for creating tailored automation.

[View repository →](https://github.com/anthropics/claude-code-base-action)

## Setup

### Quick setup

The easiest way to set up this action is through Claude Code in the terminal. Just open claude and run `/install-github-app`.

This command will guide you through setting up the GitHub app and required secrets.

### Manual setup

If the `/install-github-app` command fails or you prefer manual setup, please follow these manual setup instructions:

1. **Install the Claude GitHub app** to your repository: https://github.com/apps/claude
2. **Add ANTHROPIC_API_KEY** to your repository secrets ([Learn how to use secrets in GitHub Actions](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions))
3. **Copy the workflow file** from [examples/claude.yml](https://github.com/anthropics/claude-code-action/blob/main/examples/claude.yml) into your repository's `.github/workflows/`

## Example use cases

Claude Code GitHub Actions can help you with a variety of tasks. For complete working examples, see the [examples directory](https://github.com/anthropics/claude-code-action/tree/main/examples).

### Turn issues into PRs

In an issue comment:
```
@claude Implement user authentication with JWT tokens
```

Claude will analyze the issue, write the code, and create a PR for review.

### Get implementation help

In a PR comment:
```
@claude How should I implement this feature?
```

Claude will analyze your code and provide specific implementation guidance.

### Fix bugs quickly

In an issue:
```
@claude Fix the memory leak in the image processing function
```

Claude will locate the bug, implement a fix, and create a PR.

## Best practices

### CLAUDE.md configuration

Create a `CLAUDE.md` file in your repository root to define code style guidelines, review criteria, project-specific rules, and preferred patterns. This file guides Claude's understanding of your project standards.

### Security considerations

Always use GitHub Secrets for API keys:

- Add your API key as a repository secret named `ANTHROPIC_API_KEY`
- Reference it in workflows: `anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}`
- Limit action permissions to only what's necessary
- Review Claude's suggestions before merging

Always use GitHub Secrets (e.g., `${{ secrets.ANTHROPIC_API_KEY }}`) rather than hardcoding API keys directly in your workflow files.

### Optimizing performance

Use issue templates to provide context, keep your `CLAUDE.md` concise and focused, and configure appropriate timeouts for your workflows.

### CI costs

When using Claude Code GitHub Actions, be aware of the associated costs:

**GitHub Actions costs:**
- Claude Code runs on GitHub-hosted runners, which consume your GitHub Actions minutes
- See [GitHub's billing documentation](https://docs.github.com/en/billing/managing-billing-for-your-products/managing-billing-for-github-actions/about-billing-for-github-actions) for detailed pricing and minute limits

**API costs:**
- Each Claude interaction consumes API tokens based on the length of prompts and responses
- Token usage varies by task complexity and codebase size
- See [Claude's pricing page](https://www.anthropic.com/api) for current token rates

**Cost optimization tips:**
- Use specific `@claude` commands to reduce unnecessary API calls
- Configure appropriate `max_turns` limits to prevent excessive iterations
- Set reasonable `timeout_minutes` to avoid runaway workflows
- Consider using GitHub's concurrency controls to limit parallel runs

## Configuration examples

For ready-to-use workflow configurations for different use cases, including:

- Basic workflow setup for issue and PR comments
- Automated code reviews on pull requests
- Custom implementations for specific needs

Visit the [examples directory](https://github.com/anthropics/claude-code-action/tree/main/examples) in the Claude Code Action repository.

## Using with AWS Bedrock & Google Vertex AI

For enterprise environments, you can use Claude Code GitHub Actions with your own cloud infrastructure. This approach gives you control over data residency and billing while maintaining the same functionality.

### Prerequisites

Before setting up Claude Code GitHub Actions with cloud providers, you need:

#### For Google Cloud Vertex AI:
1. A Google Cloud Project with Vertex AI enabled
2. Workload Identity Federation configured for GitHub Actions
3. A service account with the required permissions
4. A GitHub App (recommended) or use the default GITHUB_TOKEN

#### For AWS Bedrock:
1. An AWS account with Amazon Bedrock enabled
2. GitHub OIDC Identity Provider configured in AWS
3. An IAM role with Bedrock permissions
4. A GitHub App (recommended) or use the default GITHUB_TOKEN

### 1. Create GitHub App

Create a GitHub App at https://github.com/settings/apps/new with these permissions:

**Repository permissions:**
- Contents: Read & write
- Issues: Read & write
- Pull requests: Read & write

**Subscribe to events:**
- Issue comments
- Pull request comments
- Issues
- Pull requests

### 2. Configure Cloud Authentication

#### For Google Cloud Vertex AI:

Follow the [Google Cloud Workload Identity Federation documentation](https://cloud.google.com/iam/docs/workload-identity-federation) to set up identity federation between GitHub and Google Cloud.

#### For AWS Bedrock:

Follow the [AWS documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html) to configure OIDC identity provider and create an IAM role with Bedrock access.

### 3. Set up GitHub Secrets

Configure these secrets in your repository settings:

**For AWS Bedrock:**
| Secret Name | Description |
|-------------|-------------|
| `AWS_ROLE_TO_ASSUME` | ARN of the IAM role for Bedrock access |
| `APP_ID` | Your GitHub App ID (from app settings) |
| `APP_PRIVATE_KEY` | The private key you generated for your GitHub App |

**For Google Cloud Vertex AI:**
| Secret Name | Description |
|-------------|-------------|
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | Workload identity provider resource name |
| `GCP_SERVICE_ACCOUNT` | Service account email with Vertex AI access |
| `APP_ID` | Your GitHub App ID (from app settings) |
| `APP_PRIVATE_KEY` | The private key you generated for your GitHub App |

### 4. Create workflow files

Create GitHub Actions workflow files that integrate with your cloud provider. The examples below show complete configurations for both AWS Bedrock and Google Vertex AI:

**AWS Bedrock Example:**
```yaml
name: Claude Code with AWS Bedrock

on:
  issue_comment:
    types: [created, edited]
  pull_request:
    types: [opened, synchronize, reopened]
  pull_request_review_comment:
    types: [created, edited]

jobs:
  claude:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
      issues: write
      id-token: write

    steps:
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        role-to-assume: ${{ secrets.AWS_ROLE_TO_ASSUME }}
        aws-region: us-east-1

    - name: Checkout code
      uses: actions/checkout@v4

    - name: Generate GitHub App token
      uses: actions/create-github-app-token@v1
      id: app-token
      with:
        app-id: ${{ secrets.APP_ID }}
        private-key: ${{ secrets.APP_PRIVATE_KEY }}

    - name: Run Claude Code
      uses: anthropics/claude-code-action@v1
      with:
        github_token: ${{ steps.app-token.outputs.token }}
        provider: bedrock
        max_turns: 5
        timeout_minutes: 30
```

**Google Cloud Vertex AI Example:**
```yaml
name: Claude Code with Google Vertex AI

on:
  issue_comment:
    types: [created, edited]
  pull_request:
    types: [opened, synchronize, reopened]
  pull_request_review_comment:
    types: [created, edited]

jobs:
  claude:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
      issues: write
      id-token: write

    steps:
    - name: Authenticate to Google Cloud
      id: auth
      uses: google-github-actions/auth@v2
      with:
        workload_identity_provider: ${{ secrets.GCP_WORKLOAD_IDENTITY_PROVIDER }}
        service_account: ${{ secrets.GCP_SERVICE_ACCOUNT }}

    - name: Set up Cloud SDK
      uses: google-github-actions/setup-gcloud@v2

    - name: Checkout code
      uses: actions/checkout@v4

    - name: Generate GitHub App token
      uses: actions/create-github-app-token@v1
      id: app-token
      with:
        app-id: ${{ secrets.APP_ID }}
        private-key: ${{ secrets.APP_PRIVATE_KEY }}

    - name: Run Claude Code
      uses: anthropics/claude-code-action@v1
      with:
        github_token: ${{ steps.app-token.outputs.token }}
        provider: vertex
        max_turns: 5
        timeout_minutes: 30
```

## Troubleshooting

### Claude not responding to @claude commands

Verify the GitHub App is installed correctly, check that workflows are enabled, ensure API key is set in repository secrets, and confirm the comment contains `@claude` (not `/claude`).

### CI not running on Claude's commits

Ensure you're using the GitHub App or custom app (not Actions user), check workflow triggers include the necessary events, and verify app permissions include CI triggers.

### Authentication errors

Confirm API key is valid and has sufficient permissions. For Bedrock/Vertex, check credentials configuration and ensure secrets are named correctly in workflows.

## Advanced configuration

### Action parameters

The Claude Code Action supports these key parameters:

| Parameter | Description | Required |
|-----------|-------------|----------|
| `prompt` | The prompt to send to Claude | Yes* |
| `prompt_file` | Path to file containing prompt | Yes* |
| `anthropic_api_key` | Anthropic API key | Yes** |
| `max_turns` | Maximum conversation turns | No |
| `timeout_minutes` | Execution timeout | No |

*Either `prompt` or `prompt_file` required  
**Required for direct Anthropic API, not for Bedrock/Vertex

### Alternative integration methods

While the `/install-github-app` command is the recommended approach, you can also:

- **Custom GitHub App**: For organizations needing branded usernames or custom authentication flows. Create your own GitHub App with required permissions (contents, issues, pull requests) and use the [actions/create-github-app-token](https://github.com/actions/create-github-app-token) action to generate tokens in your workflows.

- **Manual GitHub Actions**: Direct workflow configuration for maximum flexibility

- **MCP Configuration**: Dynamic loading of Model Context Protocol servers

See the [Claude Code Action repository](https://github.com/anthropics/claude-code-action) for detailed documentation.

### Customizing Claude's behavior

You can configure Claude's behavior in two ways:

1. **CLAUDE.md**: Define coding standards, review criteria, and project-specific rules in a `CLAUDE.md` file at the root of your repository. Claude will follow these guidelines when creating PRs and responding to requests. Check out our [Memory documentation](https://docs.anthropic.com/en/docs/claude-code/memory) for more details.

2. **Custom prompts**: Use the `prompt` parameter in the workflow file to provide workflow-specific instructions. This allows you to customize Claude's behavior for different workflows or tasks.

Claude will follow these guidelines when creating PRs and responding to requests.

---

*This documentation was downloaded from Anthropic docs and saved locally for reference.*