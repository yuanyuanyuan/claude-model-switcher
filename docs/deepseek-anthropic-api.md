# DeepSeek Anthropic API Documentation

*Downloaded from: https://api-docs.deepseek.com/guides/anthropic_api*
*Download date: 2025-08-21*

---

## Overview

To meet the demand for using the Anthropic API ecosystem, our API has added support for the Anthropic API format. With simple configuration, you can integrate the capabilities of DeepSeek into the Anthropic API ecosystem.

## Use DeepSeek in Claude Code

### 1. Install Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

### 2. Config Environment Variables

```bash
export ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic
export ANTHROPIC_AUTH_TOKEN=${YOUR_API_KEY}
export ANTHROPIC_MODEL=deepseek-chat
export ANTHROPIC_SMALL_FAST_MODEL=deepseek-chat
```

### 3. Enter the Project Directory, and Execute Claude Code

```bash
cd my-project
claude
```

## Invoke DeepSeek Model via Anthropic API

### 1. Install Anthropic SDK

```bash
pip install anthropic
```

### 2. Config Environment Variables

```bash
export ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic
export ANTHROPIC_API_KEY=${DEEPSEEK_API_KEY}
```

### 3. Invoke the API

```python
import anthropic

client = anthropic.Anthropic()
message = client.messages.create(
    model="deepseek-chat",
    max_tokens=1000,
    system="You are a helpful assistant.",
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Hi, how are you?"
                }
            ]
        }
    ]
)
print(message.content)
```

## Anthropic API Compatibility Details

| Field | Support Status |
|-------|----------------|
| anthropic-beta | Ignored |
| anthropic-version | Ignored |
| x-api-key | Fully Supported |

### Simple Fields

| Field | Support Status |
|-------|----------------|
| model | Use DeepSeek Model Instead |
| max_tokens | Fully Supported |
| container | Ignored |
| mcp_servers | Ignored |
| metadata | Ignored |
| service_tier | Ignored |
| stop_sequences | Fully Supported |
| stream | Fully Supported |
| system | Fully Supported |
| temperature | Fully Supported (range [0.0 ~ 2.0]) |
| thinking | Ignored |
| top_k | Ignored |
| top_p | Fully Supported |

### Tool Fields

#### tools

| Field | Support Status |
|-------|----------------|
| name | Fully Supported |
| input_schema | Fully Supported |
| description | Fully Supported |
| cache_control | Ignored |

#### tool_choice

| Value | Support Status |
|-------|----------------|
| none | Fully Supported |
| auto | Supported (`disable_parallel_tool_use` is ignored) |
| any | Supported (`disable_parallel_tool_use` is ignored) |
| tool | Supported (`disable_parallel_tool_use` is ignored) |

### Message Fields

| Field | Variant | Sub-Field | Support Status |
|-------|---------|-----------|----------------|
| content | string | | Fully Supported |
| | array, type="text" | text | Fully Supported |
| | | cache_control | Ignored |
| | | citations | Ignored |
| | array, type="image" | | Not Supported |
| | array, type="document" | | Not Supported |
| | array, type="search_result" | | Not Supported |
| | array, type="thinking" | | Fully Supported |
| | array, type="redacted_thinking" | | Not Supported |
| | array, type="tool_use" | id | Fully Supported |
| | | input | Fully Supported |
| | | name | Fully Supported |
| | | cache_control | Ignored |
| | array, type="tool_result" | tool_use_id | Fully Supported |
| | | content | Fully Supported |
| | | cache_control | Ignored |
| | | is_error | Ignored |
| | array, type="server_tool_use" | | Not Supported |
| | array, type="web_search_tool_result" | | Not Supported |
| | array, type="code_execution_tool_result" | | Not Supported |
| | array, type="mcp_tool_use" | | Not Supported |
| | array, type="mcp_tool_result" | | Not Supported |
| | array, type="container_upload" | | Not Supported |

## Quick Start Examples

### For Claude Code Users

```bash
# One-time setup
npm install -g @anthropic-ai/claude-code

# Set environment variables
export ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic
export ANTHROPIC_AUTH_TOKEN="your_deepseek_api_key_here"
export ANTHROPIC_MODEL=deepseek-chat

# Use in any project
cd your-project
claude
```

### For Python Developers

```python
import anthropic
import os

# Configure client
client = anthropic.Anthropic(
    base_url="https://api.deepseek.com/anthropic",
    api_key=os.environ.get("ANTHROPIC_API_KEY")
)

# Make a request
response = client.messages.create(
    model="deepseek-chat",
    max_tokens=1000,
    messages=[
        {
            "role": "user", 
            "content": "Hello, how can I use DeepSeek with Anthropic API?"
        }
    ]
)

print(response.content[0].text)
```

### For cURL Users

```bash
curl https://api.deepseek.com/anthropic/v1/messages \
  -H "Content-Type: application/json" \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "deepseek-chat",
    "max_tokens": 1000,
    "messages": [
      {
        "role": "user",
        "content": "Hello, DeepSeek!"
      }
    ]
  }'
```

## Important Notes

- **Model Specification**: Use `deepseek-chat` as the model name
- **Base URL**: Always use `https://api.deepseek.com/anthropic` 
- **Authentication**: Use your DeepSeek API key
- **Compatibility**: Most Anthropic API features are supported, but some advanced features may be ignored
- **Temperature Range**: Supported range is [0.0 ~ 2.0]

## Unsupported Features

The following Anthropic API features are currently not supported:

- Image processing (array, type="image")
- Document processing (array, type="document")  
- Search results (array, type="search_result")
- Redacted thinking (array, type="redacted_thinking")
- Server tool use (array, type="server_tool_use")
- Web search tool results (array, type="web_search_tool_result")
- Code execution tool results (array, type="code_execution_tool_result")
- MCP tool use and results
- Container upload functionality
- Cache control features
- Citations feature

---

MODEL	deepseek-chat	deepseek-reasoner
MODEL VERSION	DeepSeek-V3.1 (Non-thinking Mode)	DeepSeek-V3.1 (Thinking Mode)
CONTEXT LENGTH	128K
MAX OUTPUT	DEFAULT: 4K
MAXIMUM: 8K	DEFAULT: 32K
MAXIMUM: 64K
FEATURES	Json Output	✓	✓
Function Calling	✓	✗(1)
Chat Prefix Completion（Beta）	✓	✓
FIM Completion（Beta）	✓	✗