# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 🏗️ Project Overview

**Claude Model Switcher v5.0.0** - A modular, configuration-driven Claude Code installer and multi-model management system with comprehensive testing support.

### Architecture Characteristics
- **Modular Design**: Single-responsibility modules (≤500 lines each)
- **Configuration-Driven**: All settings in external config files
- **Test-First**: TDD/BDD framework with unit, integration, and behavioral tests
- **Shell Integration**: Automatic shell configuration and CLI functions
- **Provider-Agnostic**: Supports multiple AI providers (Moonshot, Zhipu, etc.)

## 📁 Directory Structure

```
claude-model-switcher/
├── main.sh              # Entry point & command router
├── config/              # Configuration files
│   ├── app.conf        # Application settings
│   ├── models.conf     # Model definitions
│   ├── providers.conf  # API provider configs
│   └── mcp.json        # MCP server configurations
├── lib/                 # Core modules
│   ├── core/           # Foundation modules
│   │   ├── logger.sh   # Logging & output formatting
│   │   ├── config_loader.sh # Configuration management
│   │   └── validator.sh # Input validation & checks
│   ├── installers/     # Installation modules
│   │   ├── nodejs_installer.sh   # Node.js/NVM setup
│   │   └── claude_installer.sh   # Claude Code installation
│   └── managers/       # Runtime management
│       └── model_manager.sh # Model switching & management
└── tests/              # Test framework
    ├── test_runner.sh  # TDD/BDD test execution
    ├── unit/          # Module-level tests
    ├── integration/   # Cross-module tests
    └── bdd/           # User scenario tests
```

## 🚀 Common Commands

### Development Workflow
```bash
# Run all tests
./tests/test_runner.sh

# Run specific test types
./tests/test_runner.sh unit          # Unit tests only
./tests/test_runner.sh integration   # Integration tests
./tests/test_runner.sh bdd          # BDD scenarios

# Run single test file
./tests/test_runner.sh tests/unit/test_logger.sh

# Install development environment
./main.sh install

# Check system status
./main.sh status

# List available models
./main.sh list-models

# Switch model provider
./main.sh use-model kimi
```

### Shell Functions (Post-Installation)
```bash
# Available after source ~/.bashrc
list_models                    # List all configured models
use_model <model-name>        # Switch to specific model
```

## 🔧 Key Configuration Files

### Primary Configs
- **config/app.conf**: Application settings, paths, versions
- **config/models.conf**: Model definitions & metadata
- **config/providers.conf**: API provider configurations
- **config/mcp.json**: MCP server configurations

### Environment Variables
- `CLAUDE_SWITCHER_DIR`: Installation directory
- `CLAUDE_MODELS_CONF`: Model configuration path
- `LOG_LEVEL`: Debug/INFO/WARN/ERROR

## 🤖 MCP Server Configuration

The project includes pre-configured MCP (Model Context Protocol) servers to extend Claude Code capabilities.

### Available MCP Servers

**Jina AI Server** (`jina-mcp-server`)
- **Type**: SSE (Server-Sent Events)
- **Purpose**: AI-powered search and content processing
- **Environment**: `JINA_API_KEY` required
- **Usage**: Web search, document processing, content analysis

**Filesystem Server** (`filesystem`)
- **Type**: stdio (Node.js process)
- **Purpose**: Local file system access
- **Access**: `${HOME}/Documents`, `${HOME}/Desktop`
- **Usage**: File operations, directory navigation, content reading

**GitHub Server** (`github`)
- **Type**: stdio (Node.js process)
- **Purpose**: GitHub repository management
- **Environment**: `GITHUB_TOKEN` required
- **Usage**: Repository operations, issue management, code review

**Brave Search Server** (`brave-search`)
- **Type**: stdio (Node.js process)
- **Purpose**: Web search via Brave Search API
- **Environment**: `BRAVE_API_KEY` required
- **Usage**: Real-time web search, information retrieval

### Configuration Format

```json
{
  "mcpServers": {
    "server-name": {
      "type": "stdio|sse",
      "command": "npx",  // For stdio type
      "args": ["-y", "@package/name"],
      "env": {
        "API_KEY": "${ENV_VAR}"
      },
      "url": "https://api.url",  // For SSE type
      "headers": {
        "Authorization": "Bearer ${TOKEN}"
      }
    }
  }
}
```

### Adding Custom MCP Servers

1. **Edit config/mcp.json** - Add new server configuration
2. **Set environment variables** - Required API keys and tokens
3. **Test connectivity** - Use Claude Code's `/mcp` command
4. **Verify permissions** - Check with `/permissions` command

### MCP Server Management

```bash
# Check MCP server status (in Claude Code)
/mcp

# View available permissions
/permissions

# Enable debug mode for troubleshooting
claude --mcp-debug
```

### Environment Setup

```bash
# Required environment variables
export JINA_API_KEY="your_jina_api_key"
export GITHUB_TOKEN="your_github_token"
export BRAVE_API_KEY="your_brave_api_key"

# For Chinese users - use npm mirror
npm config set registry https://registry.npmmirror.com
```

## 🧪 Testing Framework

### Test Types
- **Unit Tests**: `tests/unit/` - Individual module validation
- **Integration Tests**: `tests/integration/` - Module interactions
- **BDD Tests**: `tests/bdd/` - User scenario validation

### Test Functions Available
```bash
# Assertions
assert_success "description" "command"
assert_failure "description" "command"
assert_equals "description" "expected" "actual"
assert_file_exists "description" "path"
assert_contains "description" "string" "substring"

# BDD Structure
describe "Feature Name"
context "Scenario Context"
it "should behave correctly"
```

## 🎯 Core Module Responsibilities

### Core Modules (`lib/core/`)
- **logger.sh**: Colorized output, log levels, file logging
- **config_loader.sh**: Config validation, caching, reload detection
- **validator.sh**: System requirements, input validation

### Installers (`lib/installers/`)
- **nodejs_installer.sh**: Node.js/NVM version management
- **claude_installer.sh**: Claude Code CLI installation

### Managers (`lib/managers/`)
- **model_manager.sh**: Model switching, API provider coordination

## 📊 Quality Gates

Before committing changes:
1. **Tests Pass**: `./tests/test_runner.sh` must succeed
2. **Config Validation**: All config files must be valid
3. **Shell Compatibility**: Test on bash/zsh
4. **Error Handling**: All edge cases handled gracefully

## 🔄 Extension Patterns

### Adding New Models
1. Edit `config/models.conf`: Add model metadata
2. Edit `config/providers.conf`: Add provider config
3. Update `lib/managers/model_manager.sh`: Add provider logic
4. Add tests in appropriate test directories

### Adding New Modules
1. Create module in appropriate `lib/` subdirectory
2. Follow existing naming: `<function>_module.sh`
3. Add comprehensive tests
4. Include in `main.sh` module loading

## 🛠️ Development Tips

### Debugging
```bash
# Enable debug logging
export LOG_LEVEL="DEBUG"
./main.sh <command>

# Check logs
tail -f ~/.claude/claude-model-switcher/logs/installer.log
```

### Testing Changes
```bash
# Quick validation
./tests/test_runner.sh unit/test_logger.sh

# Full system test
./tests/test_runner.sh
```

### Module Testing
```bash
# Test individual module
source lib/core/logger.sh && logger_init && log_info "test"
```

## 🔍 Key Patterns Used

- **Configuration Over Code**: All settings externalized
- **Single Responsibility**: Each module has one clear purpose
- **Dependency Injection**: Modules sourced dynamically
- **Defensive Programming**: Extensive validation and error handling
- **Atomic Operations**: Safe configuration changes with rollback
- **Observability**: Structured logging and status reporting