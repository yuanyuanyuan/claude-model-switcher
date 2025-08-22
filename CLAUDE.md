# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 🏗️ Project Overview

**Claude Model Switcher v5.0.0** - A modular, configuration-driven Claude Code installer and multi-model management system with comprehensive testing support.

### Architecture Characteristics
- **Modular Design**: Single-responsibility modules (≤500 lines each)
- **Configuration-Driven**: All settings in external config files
- **Test-First**: TDD/BDD framework with unit, integration, and behavioral tests
- **Shell Integration**: Automatic shell configuration and CLI functions
- **Provider-Agnostic**: Supports multiple AI providers (Moonshot, Zhipu, DeepSeek, etc.)

## 📁 Directory Structure

```
claude-model-switcher/
├── main.sh              # Entry point & command router
├── install.sh           # Bootstrap installer
├── config/              # Configuration files
│   ├── app.conf        # Application settings and paths
│   ├── models.conf     # Model definitions and metadata
│   ├── providers.conf  # API provider configurations
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
    ├── unit/           # Module-level tests
    ├── integration/    # Cross-module tests
    └── bdd/            # User scenario tests
```

## 🚀 Development Commands

### Core Development Workflow
```bash
# Run all tests (unit + integration + BDD)
./tests/test_runner.sh

# Run specific test types
./tests/test_runner.sh unit          # Unit tests only
./tests/test_runner.sh integration   # Integration tests
./tests/test_runner.sh bdd           # BDD scenarios

# Run single test file
./tests/test_runner.sh tests/unit/test_logger.sh

# Run specific test directory
./tests/test_runner.sh tests/integration/

# Test with debug output
DEBUG=1 ./tests/test_runner.sh
```

### Installation & Management
```bash
# Full installation (Node.js + Claude Code + Shell integration)
./main.sh install

# Check system status
./main.sh status

# List available models
./main.sh list-models

# Switch model provider
./main.sh use-model kimi

# Add new model
./main.sh add-model "model-name" "provider" "api-name" "context" "description"

# Uninstall system
./main.sh uninstall
```

### Shell Functions (Post-Installation)
```bash
# Available after source ~/.bashrc or ~/.zshrc
list_models                    # List all configured models
use_model <model-name>        # Switch to specific model
```

## 🔧 Key Configuration Files

### Primary Configs
- **config/app.conf**: Application settings, paths, versions, feature flags
- **config/models.conf**: Model definitions & metadata (associative arrays)
- **config/providers.conf**: API provider configurations and endpoints
- **config/mcp.json**: MCP server configurations for Claude Code extension

### Environment Variables
- `CLAUDE_SWITCHER_DIR`: Installation directory path
- `CLAUDE_MODELS_CONF`: Model configuration file path
- `LOG_LEVEL`: Debug/INFO/WARN/ERROR logging level
- `DEBUG`: Enable debug mode (1=true)
- `USE_EMOJIS`: Enable/disable emoji output (true/false)

## 🧪 Testing Framework

### Test Types & Structure
- **Unit Tests**: `tests/unit/` - Individual module validation
- **Integration Tests**: `tests/integration/` - Module interactions
- **BDD Tests**: `tests/bdd/` - User scenario validation

### Test Assertion Functions
```bash
# Basic assertions
assert_success "description" "command"
assert_failure "description" "command"
assert_equals "description" "expected" "actual"
assert_file_exists "description" "path"
assert_dir_exists "description" "path"
assert_contains "description" "string" "substring"

# BDD structure
describe "Feature Name"
context "Scenario Context"
it "should behave correctly"

# Setup/teardown
setup()           # Before each test
teardown()        # After each test
setup_all()       # Before all tests
teardown_all()    # After all tests
```

### Test Execution Patterns
```bash
# Run specific test with debug
DEBUG=1 ./tests/test_runner.sh tests/unit/test_logger.sh

# Run tests with specific log level
LOG_LEVEL=DEBUG ./tests/test_runner.sh

# Generate test report only
./tests/test_runner.sh && cat tests/results/test_report.txt
```

## 🤖 MCP Server Integration

The project includes pre-configured MCP (Model Context Protocol) servers:

### Available MCP Servers
- **Jina AI Server**: AI-powered search and content processing
- **Filesystem Server**: Local file system access
- **GitHub Server**: GitHub repository management
- **Brave Search Server**: Web search via Brave Search API

### MCP Configuration
- **Location**: `config/mcp.json`
- **Environment Variables Required**:
  - `JINA_API_KEY` for Jina AI
  - `GITHUB_TOKEN` for GitHub
  - `BRAVE_API_KEY` for Brave Search

### MCP Management Commands
```bash
# Check MCP server status (in Claude Code)
/mcp

# View available permissions
/permissions

# Enable debug mode
claude --mcp-debug
```

## 🎯 Core Module Architecture

### Module Loading Pattern
```bash
# Module initialization pattern (used in main.sh:24-35)
source "lib/core/logger.sh"
source "lib/core/config_loader.sh"
source "lib/core/validator.sh"
source "lib/installers/nodejs_installer.sh"
source "lib/installers/claude_installer.sh"
source "lib/managers/model_manager.sh"

# Module initialization functions
logger_init           # Initialize logging system
config_load_all       # Load all configurations
validate_environment  # Validate system requirements
```

### Module Responsibilities
- **logger.sh**: Colorized output, log levels, file logging, emoji support
- **config_loader.sh**: Config validation, caching, reload detection, associative array management
- **validator.sh**: System requirements, input validation, environment checks
- **nodejs_installer.sh**: Node.js/NVM version management, installation
- **claude_installer.sh**: Claude Code CLI installation, configuration, verification
- **model_manager.sh**: Model switching, provider coordination, shell function implementation

## 🔄 Extension Patterns

### Adding New Models
1. Edit `config/models.conf`: Add model metadata using associative arrays
2. Edit `config/providers.conf`: Add provider configuration if new
3. Update `lib/managers/model_manager.sh`: Add provider-specific logic if needed
4. Add tests in appropriate test directories

### Adding New Modules
1. Create module in appropriate `lib/` subdirectory
2. Follow existing naming: `<function>_module.sh`
3. Implement standard interface: `init()`, `main()`, `cleanup()` functions
4. Add comprehensive tests in corresponding test directory
5. Include in `main.sh` module loading section

### Configuration Management
- All configurations use INI-style format with associative arrays
- Config files are sourced dynamically at runtime
- Changes require system re-initialization or config reload

## 🛠️ Development Tips

### Debugging & Troubleshooting
```bash
# Enable detailed debugging
export DEBUG=1
export LOG_LEVEL="DEBUG"

# Check module loading issues
./main.sh status

# Test individual module functionality
source lib/core/logger.sh && logger_init && log_info "test message"

# Verify configuration loading
source lib/core/config_loader.sh && config_load "config/models.conf"

# Check shell integration
source ~/.bashrc && list_models
```

### Performance Optimization
```bash
# Monitor script execution time
time ./main.sh list-models

# Check memory usage
/usr/bin/time -v ./main.sh status 2>&1 | grep "Maximum resident"

# Profile specific operations
bash -x ./main.sh install 2>&1 | head -50
```

### Quality Assurance
```bash
# Run all tests before committing
./tests/test_runner.sh

# Check shell compatibility (bash/zsh)
bash ./main.sh install
zsh ./main.sh install

# Validate configuration files
bash -n config/*.conf  # Syntax check

# Test error handling
./main.sh use-model invalid-model  # Should fail gracefully
```

## 📊 Quality Gates

Before committing changes:
1. **All Tests Pass**: `./tests/test_runner.sh` must succeed
2. **Config Validation**: All config files must be syntactically valid
3. **Shell Compatibility**: Test on both bash and zsh
4. **Error Handling**: All edge cases must be handled gracefully
5. **Documentation**: Update relevant documentation for changes

### Validation Commands
```bash
# Syntax validation
bash -n main.sh install.sh lib/*/*.sh tests/*.sh

# Config validation
bash -n config/*.conf

# Test coverage validation
./tests/test_runner.sh | grep "PASS RATE" | grep "100%"
```

## 🔍 Key Architectural Patterns

- **Configuration Over Code**: All settings externalized in config files
- **Single Responsibility**: Each module has one clear purpose (≤500 lines)
- **Dependency Injection**: Modules sourced dynamically, avoid circular dependencies
- **Defensive Programming**: Extensive validation and error handling throughout
- **Atomic Operations**: Safe configuration changes with rollback capability
- **Observability**: Structured logging with multiple levels and output formats
- **Shell Integration**: Automatic RC file modification with backup/restore

## ⚡ Performance Characteristics

- **Startup Time**: <500ms for most operations
- **Memory Usage**: Minimal footprint (~5-10MB)
- **Configuration Loading**: Cached for performance
- **Test Execution**: Parallel-friendly test structure
- **Logging**: Asynchronous file writing with rotation

This architecture enables rapid development while maintaining reliability and ease of maintenance.