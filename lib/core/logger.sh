#!/bin/bash

# Logger Module - Centralized logging functionality
# Supports different log levels and formatted output

# Initialize logger (should be called once)
logger_init() {
    local log_dir="${LOG_DIR:-$HOME/.claude/claude-model-switcher/logs}"
    local log_file="${LOG_FILE:-$log_dir/installer.log}"
    
    # Ensure log directory exists
    mkdir -p "$log_dir"
    
    # Set global log file
    export LOGGER_FILE="$log_file"
    export LOGGER_LEVEL="${LOG_LEVEL:-INFO}"
    export LOGGER_USE_EMOJIS="${USE_EMOJIS:-true}"
    
    # Initialize log file with session header
    echo "=== New Session Started: $(date) ===" >> "$LOGGER_FILE"
}

# Get current timestamp
_get_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Get emoji for log level
_get_emoji() {
    local level="$1"
    if [ "$LOGGER_USE_EMOJIS" != "true" ]; then
        echo ""
        return
    fi
    
    case "$level" in
        DEBUG) echo "🔍" ;;
        INFO)  echo "ℹ️" ;;
        WARN)  echo "⚠️" ;;
        ERROR) echo "❌" ;;
        SUCCESS) echo "✅" ;;
        PROGRESS) echo "🚀" ;;
        *) echo "📝" ;;
    esac
}

# Check if log level should be printed
_should_log() {
    local level="$1"
    local current_level="${LOGGER_LEVEL:-INFO}"
    
    case "$current_level" in
        DEBUG) return 0 ;;
        INFO)  [[ "$level" =~ ^(INFO|WARN|ERROR|SUCCESS|PROGRESS)$ ]] ;;
        WARN)  [[ "$level" =~ ^(WARN|ERROR|SUCCESS)$ ]] ;;
        ERROR) [[ "$level" =~ ^(ERROR|SUCCESS)$ ]] ;;
        *) return 0 ;;
    esac
}

# Core logging function
_log() {
    local level="$1"
    local message="$2"
    local to_file="${3:-true}"
    local to_console="${4:-true}"
    
    if ! _should_log "$level"; then
        return 0
    fi
    
    local timestamp="$(_get_timestamp)"
    local emoji="$(_get_emoji "$level")"
    local formatted_message="[$timestamp] [$level] $message"
    local console_message="$emoji $message"
    
    # Log to file
    if [ "$to_file" = "true" ] && [ -n "$LOGGER_FILE" ]; then
        echo "$formatted_message" >> "$LOGGER_FILE"
    fi
    
    # Log to console
    if [ "$to_console" = "true" ]; then
        echo "$console_message"
    fi
}

# Public logging functions
log_debug() {
    _log "DEBUG" "$1" "${2:-true}" "${3:-true}"
}

log_info() {
    _log "INFO" "$1" "${2:-true}" "${3:-true}"
}

log_warn() {
    _log "WARN" "$1" "${2:-true}" "${3:-true}"
}

log_error() {
    _log "ERROR" "$1" "${2:-true}" "${3:-true}"
}

log_success() {
    _log "SUCCESS" "$1" "${2:-true}" "${3:-true}"
}

log_progress() {
    _log "PROGRESS" "$1" "${2:-true}" "${3:-true}"
}

# Special logging functions
log_separator() {
    local char="${1:--}"
    local width="${2:-50}"
    local message=""
    
    for ((i=1; i<=width; i++)); do
        message+="$char"
    done
    
    log_info "$message"
}

log_header() {
    local title="$1"
    local width="${2:-50}"
    
    log_separator "=" "$width"
    log_info "$title"
    log_separator "=" "$width"
}

# Log with indentation (for nested operations)
log_indent() {
    local level="$1"
    local message="$2"
    local indent="${3:-2}"
    
    local spaces=""
    for ((i=1; i<=indent; i++)); do
        spaces+=" "
    done
    
    case "$level" in
        debug) log_debug "$spaces$message" ;;
        info)  log_info "$spaces$message" ;;
        warn)  log_warn "$spaces$message" ;;
        error) log_error "$spaces$message" ;;
        success) log_success "$spaces$message" ;;
        progress) log_progress "$spaces$message" ;;
    esac
}

# Log command execution
log_command() {
    local cmd="$1"
    local show_output="${2:-false}"
    
    log_debug "Executing command: $cmd"
    
    if [ "$show_output" = "true" ]; then
        eval "$cmd" 2>&1 | while read -r line; do
            log_indent debug "$line" 4
        done
        return "${PIPESTATUS[0]}"
    else
        eval "$cmd" >/dev/null 2>&1
        return $?
    fi
}

# Cleanup old log files
log_cleanup() {
    local retention_days="${BACKUP_RETENTION_DAYS:-30}"
    local log_dir="${LOG_DIR:-$HOME/.claude/claude-model-switcher/logs}"
    
    if [ -d "$log_dir" ]; then
        log_debug "Cleaning up log files older than $retention_days days"
        find "$log_dir" -name "*.log" -type f -mtime +"$retention_days" -delete 2>/dev/null || true
    fi
}

