#!/bin/bash

# A robust installer and manager for Claude Code with multi-model support.
# Version 4.2.0: Optimized for official Claude Code requirements with temperature control.
# This script is designed with safety, maintainability, and a clean directory structure as top priorities.

set -e

# --- Configuration ---
# The dedicated directory for all switcher-related files, keeping the home directory clean.
SWITCHER_DIR="$HOME/.claude/claude-model-switcher"
# The central configuration file where all models are defined.
MODEL_CONFIG_FILE="$SWITCHER_DIR/models.conf"
# A dedicated directory for non-essential "memory" files created by the switcher.
MEMORY_DIR="$SWITCHER_DIR/memory"

# --- Uninstall Function ---
# Provides a clean and safe way to remove the entire system.
uninstall() {
    echo "Uninstalling Claude Model Switcher..."
    echo "------------------------------------"
    
    # 1. Determine the correct shell configuration file (.bashrc, .zshrc, etc.)
    local current_shell=$(basename "$SHELL")
    local rc_file
    case "$current_shell" in
        bash) rc_file="$HOME/.bashrc" ;;
        zsh) rc_file="$HOME/.zshrc" ;;
        *) rc_file="$HOME/.profile" ;;
    esac

    # 2. Safely clean up the shell configuration file
    if [ -f "$rc_file" ]; then
        echo "Found shell configuration at $rc_file."
        local marker="# CLAUDE_CODE_MODEL_MANAGER_V4"
        if grep -q "$marker" "$rc_file"; then
            echo "Removing configuration block from $rc_file..."
            # Create a backup before modifying for maximum safety.
            cp "$rc_file" "$rc_file.uninstall.bak"
            # Use sed to delete the block between the unique start and end markers.
            sed -i.bak "/# CLAUDE_CODE_MODEL_MANAGER_V4/,/# END_OF_CLAUDE_CONFIG/d" "$rc_file"
            echo "✅ RC file cleaned. Backup of original created at $rc_file.uninstall.bak"
        else
            echo "⏩ Configuration block not found in $rc_file. Skipping."
        fi
    fi

    # 3. Remove the switcher's dedicated directory
    if [ -d "$SWITCHER_DIR" ]; then
        echo "Removing switcher directory: $SWITCHER_DIR..."
        rm -rf "$SWITCHER_DIR"
        echo "✅ Switcher directory removed."
    else
        echo "⏩ Switcher directory not found. Skipping."
    fi

    echo ""
    echo "🎉 Uninstallation complete."
    echo "Please restart your terminal for changes to take full effect."
    exit 0
}

# --- Argument Parser ---
# Checks if the script was run with the --uninstall flag.
if [ "$1" == "--uninstall" ]; then
    uninstall
fi

# --- Main Installation/Update Logic ---

# Function: Install Node.js via nvm (if needed)
# This function is self-contained and handles Node.js installation cleanly.
install_nodejs() {
    local platform=$(uname -s)
    
    case "$platform" in
        Linux|Darwin)
            echo "🚀 Installing Node.js via nvm..."
            
            echo "📥 Downloading and installing nvm..."
            # Use -s for silent mode to keep the output clean.
            curl -s -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
            
            echo "🔄 Loading nvm environment for the current script session..."
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            
            echo "📦 Installing latest Node.js LTS (Long Term Support)..."
            nvm install --lts
            nvm use --lts
            nvm alias default 'lts/*' # Set the LTS version as the default for new shells.
            
            echo "✅ Node.js installation completed!"
            echo -n "   - Node version: " && node -v
            echo -n "   - npm version: " && npm -v
            ;;
        *)
            echo "❌ Unsupported platform: $platform"
            exit 1
            ;;
    esac
}

# --- Main Script Body ---
echo "🚀 Starting Claude Code Environment Setup (V4.2)..."
echo "================================================="
# Ensure the dedicated directories exist before proceeding.
mkdir -p "$SWITCHER_DIR"
mkdir -p "$MEMORY_DIR"
echo "✅ Ensured switcher directory exists: $SWITCHER_DIR"

# 1. Check and install Node.js
if [ -d "$HOME/.nvm" ]; then
    echo "NVM is already installed. Sourcing it..."
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

if command -v node >/dev/null 2>&1; then
    current_version=$(node -v | sed 's/v//')
    major_version=$(echo "$current_version" | cut -d. -f1)
    
    if [ "$major_version" -ge 18 ]; then
        echo "✅ Node.js is already installed and meets requirements: v$current_version"
    else
        echo "⚠️ Node.js v$current_version is installed but version < 18. Upgrading..."
        install_nodejs
    fi
else
    echo "Node.js not found. Installing..."
    install_nodejs
fi

# 2. Install claude-code CLI tool
if command -v claude >/dev/null 2>&1; then
    echo "✅ Claude Code is already installed: $(claude --version)"
else
    echo "📦 Claude Code not found. Installing via npm..."
    npm install -g @anthropic-ai/claude-code
    echo "✅ Claude Code installed successfully."
fi

# 3. Configure Claude Code to skip onboarding (modifies ~/.claude.json)
echo "⚙️  Configuring Claude Code to skip onboarding..."
node -e '
    const fs = require("fs");
    const path = require("path");
    const os = require("os");
    const configPath = path.join(os.homedir(), ".claude.json");
    let config = {};
    if (fs.existsSync(configPath)) {
        try {
            config = JSON.parse(fs.readFileSync(configPath, "utf-8"));
        } catch (e) { /* Ignore parsing errors, will overwrite */ }
    }
    config.hasCompletedOnboarding = true;
    fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
' > /dev/null 2>&1
echo "✅ Configuration complete."

# 4. Create the model configuration file inside the dedicated switcher directory
echo "📝 Creating model configuration file at $MODEL_CONFIG_FILE..."
cat > "$MODEL_CONFIG_FILE" << 'EOF'
# ~/.claude/claude-model-switcher/models.conf
# This is the central configuration file for your AI models.
# You can add, edit, or remove models here.
# The system requires Bash 4.0+ for associative arrays.

# Declare associative arrays to hold model properties.
declare -A MODEL_PROVIDERS
declare -A MODEL_API_NAMES
declare -A MODEL_CONTEXTS
declare -A MODEL_SMALL_FAST_NAMES

# --- Define Your Models Below ---

# Model Alias: 'kimi' - Updated to kimi-k2-turbo-preview
MODEL_PROVIDERS["kimi"]="moonshot"
MODEL_API_NAMES["kimi"]="kimi-k2-turbo-preview"
MODEL_SMALL_FAST_NAMES["kimi"]="kimi-k2-turbo-preview"
MODEL_CONTEXTS["kimi"]="128K tokens (Main & Fast)"

# Model Alias: 'glm4' - Dual model configuration
MODEL_PROVIDERS["glm4"]="zhipu"
MODEL_API_NAMES["glm4"]="glm-4.5"
MODEL_SMALL_FAST_NAMES["glm4"]="glm-4.5-flash"
MODEL_CONTEXTS["glm4"]="32K tokens (Main) / 128K tokens (Fast)"

# Add more models here...
# Example:
# MODEL_PROVIDERS["another-model"]="moonshot"
# MODEL_API_NAMES["another-model"]="some-model-name-v1"
# MODEL_CONTEXTS["another-model"]="200K tokens"

EOF
echo "✅ Model configuration file created with default models."

# 5. Safely configure the Shell Environment
current_shell=$(basename "$SHELL")
case "$current_shell" in
    bash) rc_file="$HOME/.bashrc" ;;
    zsh) rc_file="$HOME/.zshrc" ;;
    *) rc_file="$HOME/.profile" ;;
esac

echo "🔧 Safely updating shell configuration in $rc_file..."
CONFIG_BLOCK_MARKER="# CLAUDE_CODE_MODEL_MANAGER_V4"

# Atomically replace the configuration block to prevent duplicates or errors.
if [ -f "$rc_file" ]; then
    # Create a backup (.bak) and remove the old block before writing the new one.
    sed -i.bak "/$CONFIG_BLOCK_MARKER/,/# END_OF_CLAUDE_CONFIG/d" "$rc_file"
    echo "   - Backup of your original config created at $rc_file.bak"
    echo "   - Old configuration block removed (if any)."
fi

# Append the new, updated configuration block. This contains the `list_models` and `use_model` functions.
cat >> "$rc_file" << 'EOF'

# CLAUDE_CODE_MODEL_MANAGER_V4
# --- Unified Model Management System for Claude Code ---
# This block is managed automatically by the installation script.

# Define paths for the switcher's files.
export CLAUDE_SWITCHER_DIR="$HOME/.claude/claude-model-switcher"
export CLAUDE_MODELS_CONF="$CLAUDE_SWITCHER_DIR/models.conf"

# Load model definitions from the configuration file.
if [ -f "$CLAUDE_MODELS_CONF" ]; then
    source "$CLAUDE_MODELS_CONF"
fi

# Command to list available models from the config file.
list_models() {
    # Reload the config in case it was just edited.
    [ -f "$CLAUDE_MODELS_CONF" ] && source "$CLAUDE_MODELS_CONF"
    
    if [ ${#MODEL_PROVIDERS[@]} -eq 0 ]; then
        echo "No models defined in $CLAUDE_MODELS_CONF"
        return
    fi
    echo "Available Models (from $CLAUDE_MODELS_CONF):"
    printf -- '-%.0s' {1..110}; echo ""
    printf "%-10s %-10s %-25s %-25s %s\n" "Alias" "Provider" "Main Model" "Fast Model" "Context"
    printf -- '-%.0s' {1..110}; echo ""
    for alias in "${!MODEL_PROVIDERS[@]}"; do
        printf "%-10s %-10s %-25s %-25s %s\n" \
            "$alias" \
            "${MODEL_PROVIDERS[$alias]}" \
            "${MODEL_API_NAMES[$alias]}" \
            "${MODEL_SMALL_FAST_NAMES[$alias]}" \
            "${MODEL_CONTEXTS[$alias]}"
    done
    printf -- '-%.0s' {1..110}; echo ""
}

# Unified command to switch and configure a model environment.
use_model() {
    local alias="$1"
    
    # Reload config to get the latest definitions.
    [ -f "$CLAUDE_MODELS_CONF" ] && source "$CLAUDE_MODELS_CONF"
    
    if [ -z "$alias" ]; then
        echo "Usage: use_model <alias>" && list_models && return 1
    fi
    if [[ -z "${MODEL_PROVIDERS[$alias]}" ]]; then
        echo "Error: Model alias '$alias' not found in $CLAUDE_MODELS_CONF" && list_models && return 1
    fi
    
    local provider="${MODEL_PROVIDERS[$alias]}"
    local model_name="${MODEL_API_NAMES[$alias]}"
    local small_fast_model="${MODEL_SMALL_FAST_NAMES[$alias]}"
    local context_info="${MODEL_CONTEXTS[$alias]}"
    
    local api_key
    if [ "$provider" == "moonshot" ]; then
        export ANTHROPIC_BASE_URL="https://api.moonshot.cn/anthropic/"
        echo "🚀 Switching to Moonshot for model '$alias'..."
        echo "🔑 Please enter your Moonshot API key (hidden):" && read -s api_key
    elif [ "$provider" == "zhipu" ]; then
        export ANTHROPIC_BASE_URL="https://open.bigmodel.cn/api/anthropic"
        echo "🚀 Switching to Zhipu GLM for model '$alias'..."
        echo "🔑 Please enter your Zhipu GLM API key (hidden):" && read -s api_key
    else
        echo "Error: Unknown provider '$provider' defined for alias '$alias'." && return 1
    fi
    
    if [ -n "$api_key" ]; then
        export ANTHROPIC_AUTH_TOKEN="$api_key"
        export ANTHROPIC_MODEL="$model_name"
        export ANTHROPIC_SMALL_FAST_MODEL="$small_fast_model"
        echo "✅ API key set for this session."
        echo "✅ Main model: $model_name"
        echo "✅ Fast model: $small_fast_model"
    else
        echo "❌ API key was not provided." && return 1
    fi
    
    # Manage the official claude-code settings file with temperature and timeout control.
    mkdir -p "$HOME/.claude"
    cat > "$HOME/.claude/settings.json" << EOM
{
  "model": "$model_name",
  "env": {
    "CLAUDE_CODE_TEMPERATURE": "0.6",
    "BASH_DEFAULT_TIMEOUT_MS": "300000",
    "ANTHROPIC_MODEL": "$model_name",
    "ANTHROPIC_SMALL_FAST_MODEL": "$small_fast_model"
  },
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "echo '🤖 Active: $model_name ($alias) | Fast: $small_fast_model | Context: $context_info | T:0.6 | Timeout:5min'"
      }
    ]
  }
}
EOM
    
    # Manage the switcher's own memory/log file.
    local memory_file="$CLAUDE_SWITCHER_DIR/memory/model-context.md"
    cat > "$memory_file" <<- EOM
# Model Context Reference
- Provider: $provider
- Alias: $alias
- Main Model: $model_name
- Fast Model: $small_fast_model
- Context Window: $context_info
- Temperature: 0.6 (Programming Mode)
- Timeout: 300000ms (5 minutes)
- Last verified: $(date)
EOM
    
    echo "✅ Configured environment for model: $model_name"
}

# END_OF_CLAUDE_CONFIG
EOF
echo "   - New configuration block written to $rc_file."
echo "✅ Shell environment configured safely."

# --- Final Instructions ---
echo ""
echo "================================================="
echo "🎉 Installation complete! Your system is ready."
echo ""
echo "--- Next Steps ---"
echo "1. Refresh your environment (only needs to be done once):"
echo "   source $rc_file"
echo ""
echo "2. List available models:"
echo "   \$ list_models"
echo ""
echo "3. Switch to a model (e.g., 'kimi' or 'glm4'):"
echo "   \$ use_model kimi"
echo ""
echo "4. Enter the corresponding API Key:"
echo "   When prompted, paste the API Key for the chosen provider."
echo ""
echo "5. Start using Claude with optimized programming settings:"
echo "   \$ claude \"your prompt here\""
echo "   (Temperature is set to 0.6 for better programming assistance)"
echo ""
echo "--- Model Information ---"
echo "   Available models with dual-model support:"
echo "   - kimi: Moonshot kimi-k2-turbo-preview"
echo "     Main: kimi-k2-turbo-preview (128K) | Fast: kimi-k2-turbo-preview (128K)"
echo "   - glm4: Zhipu GLM-4.5 series"
echo "     Main: glm-4.5 (32K) | Fast: glm-4.5-flash (128K)"
echo ""
echo "--- Customization & Uninstallation ---"
echo "   - To add or edit models, modify the file:"
echo "     $MODEL_CONFIG_FILE"
echo "   - To completely and safely uninstall this system, run:"
echo "     \$ ./your_script_name.sh --uninstall"
echo ""