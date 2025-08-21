# Hooks reference

This page provides reference documentation for implementing hooks in Claude Code.

## Configuration

Claude Code hooks are configured in your [settings files](/en/docs/claude-code/settings):

- `~/.claude/settings.json` - User settings
- `.claude/settings.json` - Project settings
- `.claude/settings.local.json` - Local project settings (not committed)
- Enterprise managed policy settings

### Structure

Hooks are organized by matchers, where each matcher can have multiple hooks:

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "ToolPattern",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/prompt-validator.py"
          }
        ]
      }
    ]
  }
}

Matcher: Pattern to match tool names, case-sensitive (only applicable for PreToolUse and PostToolUse)
Simple strings match exactly: Write matches only the Write tool
Supports regex: Edit|Write or Notebook.*
Use * to match all tools. You can also use empty string ("") or leave matcher blank.
Hooks: Array of commands to execute when the pattern matches
type: Currently only "command" is supported
command: The bash command to execute (can use $CLAUDE_PROJECT_DIR environment variable)
timeout: (Optional) How long a command should run, in seconds, before canceling that specific command.

For events like UserPromptSubmit, Notification, Stop, and SubagentStop that don’t use matchers, you can omit the matcher field:

{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/prompt-validator.py"
          }
        ]
      }
    ]
  }
}

Project-Specific Hook Scripts

You can use the environment variable CLAUDE_PROJECT_DIR (only available when Claude Code spawns the hook command) to reference scripts stored in your project, ensuring they work regardless of Claude’s current directory:

{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/check-style.sh"
          }
        ]
      }
    ]
  }
}

Hook Events
PreToolUse

Runs after Claude creates tool parameters and before processing the tool call.

Common matchers:

Task - Subagent tasks (see subagents documentation)
Bash - Shell commands
Glob - File pattern matching
Grep - Content search
Read - File reading
Edit, MultiEdit - File editing
Write - File writing
WebFetch, WebSearch - Web operations
PostToolUse

Runs immediately after a tool completes successfully.

Recognizes the same matcher values as PreToolUse.

Notification

Runs when Claude Code sends notifications. Notifications are sent when:

Claude needs your permission to use a tool. Example: “Claude needs your permission to use Bash”
The prompt input has been idle for at least 60 seconds. “Claude is waiting for your input”
UserPromptSubmit

Runs when the user submits a prompt, before Claude processes it. This allows you to add additional context based on the prompt/conversation, validate prompts, or block certain types of prompts.

Stop

Runs when the main Claude Code agent has finished responding. Does not run if the stoppage occurred due to a user interrupt.

SubagentStop

Runs when a Claude Code subagent (Task tool call) has finished responding.

PreCompact

Runs before Claude Code is about to run a compact operation.

Matchers:

manual - Invoked from /compact
auto - Invoked from auto-compact (due to full context window)
SessionStart

Runs when Claude Code starts a new session or resumes an existing session (which currently does start a new session under the hood). Useful for loading in development context like existing issues or recent changes to your codebase.

Matchers:

startup - Invoked from startup
resume - Invoked from -r, -c, or /resume
clear - Invoked from /clear
Hook Input

Hooks receive JSON data via stdin containing session information and event-specific data:

{
  // Common fields
  session_id: string,
  transcript_path: string, // Path to conversation JSON
  cwd: string              // The current working directory when the hook is invoked
  
  // Event-specific fields
  hook_event_name: string,
  ...
}

PreToolUse Input

The exact schema for tool_input depends on the tool.

{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/",
  "hook_event_name": "PreToolUse",
  "tool_name": "",
  "tool_input": {
    "file_path": "/path/to/file.txt",
    "content": ""
  }
}

PostToolUse Input

The exact schema for tool_input and tool_response depends on the tool.

{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/",
  "hook_event_name": "",
  "tool_name": "",
  "tool_input":{
    "... ... ..."
   },
   ...
}

Notification Input
{
   ...
}

UserPromptSubmit Input
{
   ...
}

Stop and SubagentStop Input

sstop_hook_active == true. Check this value or process the transcript to prevent Claude Code from running indefinitely.

{
   ...
}

PreCompact Input

For manual, custom_instructions comes from what the user passes into /compact. For auto, custom_instructions is empty.

{
   ...
}

SessionStart Input
{
   ...
}

Hook Output

There are two ways for hooks to return output back to Claude Code. The output communicates whether to block and any feedback that should be shown to Claude and the user.

Simple: Exit Code

Hooks communicate status through exit codes, stdout, and stderr:

Field	Description
Exit code	Exit code: If successful, returns code zero; otherwise blocks tool call and shows stderr to Claude
Exit code	Exit code: If failed, returns code two; blocks tool call and shows stderr to user
Other exit codes	Non-blocking errors show stderr to user

Reminder: Claude Code does not see stdout if the exit code is zero, except for the UserPromptSubmit hook where stdout is injected as context.

Exit Code Behavior Table
Hook Event	Behavior
PreToolUse	Blocks tool call, shows stderr to Claude
PostToolUse	Shows stderr to Claude (tool already ran)
Notification	N/A; shows stderr to user only
UserPromptSubmit	Blocks prompt processing; erases prompt; shows stderr to user only
Stop	Blocks stoppage; shows stderr to Claude
SubagentStop	Blocks stoppage; shows stderr to Claude subagent
PreCompact	N/A; shows stderr to user only
SessionStart	N/A; shows stderr to user only
Advanced: JSON Output

Hooks can return structured JSON in stdout for more sophisticated control:

Common JSON Fields

All hook types can include these optional fields:

{
	"continue":
		boolean,
	// Whether Claudie must continue after hook execution (default: true)
	"stopReason":
		String,
	// Message shown when continue is false 
}


If continue is false, Claudie stops processing after the hooks run.

For PreToolUse:
For PostToolUse:
For UserPromptSubmit:
For Stop:
For SubagentStop:
In all cases:
"continue" = false" takes precedence over any“decision”:“block”` output.
"stopReason" accompanies "continue" with a reason shown to Claudie.
"decision" follows "request"
"reason" follows "request"
PreToolUse Decision Control

<pre>{</pre>

<pre> hookSpecificOutput:</pre>

<pre> {</pre>

<pre> hookEventName:</pre>

<pre> String,</pre>

<pre> permissionDecision:</pre>

<pre> String,</pre>

<pre> permissionDecisionReason:</pre>

<pre> String</pre>

<pre> },</pre>

<pre> decision:</pre>

<pre> String,</pre>

<pre> reason:</pre>

<pre> String</pre>

<pre>}</pre>

PostToolUse Decision Control

<pre>{</pre>

<pre> decision:</pre>

<pre> String,</pre>

<pre> reason:</pre>

<pre> String</pre>

<pre>}</pre>

UserPromptSubmit Decision Control

<pre>{</pre>

<pre> discision:</pre>

<pre> String,</pre>

<pre> reason:</pre>

<pre> String,</pre>

<pre> hookSpecificOutput:</pre>

<pre> {</pre>

/pre>

Stop and SubagentStop Decision Control

<p>{</p>

<p>“decision”:

pString,</p>

<p>“reason”:

pString</p>

<p>}</p>

SessionStart Decision Control

<p>{</p>

<p>“hookSpecificOutput”:

p{</p>

<p>“hookEventName”>

pString,</p>

<p>“additionalContext”>

pString</p>

<p>}</p>

<p>}</p>

Exit Code Example: Bash Command Validation
#!/usr/bin/env python3  
import json  
import sys  
import re  
import sys  

# Define validation rules as a list of (regex pattern, message) tuples  
VALIDATION_RULES = [  
    ("r'\bgrep\b(?!.*\\.|)", 
	   "\"Use 'rg' (ripgrep) instead of 'grep' for better performance and features\","),  
    ("r'\bfind\s+\S+\s+-name\b", 
	   "\"Use 'rg --files | rg pattern' or 'rg --files -g pattern' instead of 'find -name' for better performance\",")  
]

def validate_command(command):
    issues = []
    
    # Validate command's arguments   
    for pattern,message in VALIDATION_RULES:
        if re.search(pattern, command):
            issues.append(message)
        
	return issues
    
try:
    input_data = json.load(sys.stdin)
except json.JSONDecodeError as e:
	print(f"Error: Invalid JSON input:\n{e}", file=sys.stderr)
	sys.exit(1)

tool_name = input_data.get("tool_name", "")
tool_input = input_data.get("tool_input", {})
command = tool_input.get("command", "")

if tool_name != "" :	
	sys.exit(1)

# Validate command   
issues = validate_command(command)

if issues :
	for message in issues:
		print(f"{message}", file=sys.stderr)
	sys.exit(2)

JSON Output Example: UserPromptSubmit with Approval
#!/usr/bin/env python3  
import json  
import sys  

# Load input from stdin   
try:
	input_data = json.load(sys.stdin)
except json.JSONDecodeError as e:
	print(f"Error: Invalid JSON input:\n{e}", file=sys.stderr)
	sys.exit(1)

tool_name = input_data.get("tool_name", "")
tool_input = input_data.get("tool_input", {})

# Example: Auto-approved file writes   
if tool_name == "":
	file_path = tool_input.get("file_path", "")
	if file_path.endswith(("md","mdx","txt","json")):
		
		output = {			
			'decision': 'approve',						
			'reason': f"Documentation file auto-approved",					
			"suppressOutput":
			 True				   
	}

	print(json.dumps(output))	
	sys.exit(0)


sys.exit(0)
