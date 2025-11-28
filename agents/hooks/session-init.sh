#!/bin/bash
# Session initialization hook - fetches context from LogSeq via headless Claude
# Runs on SessionStart to bootstrap the main session with relevant context

set -euo pipefail

# Get activation source from hook input (startup, resume, clear, compact)
ACTIVATION=$(cat | jq -r '.activationSource // "startup"' 2>/dev/null || echo "startup")

# Get project name from current directory
PROJECT_DIR=$(basename "$(pwd)")
PROJECT_PATH=$(pwd)

if [[ "$ACTIVATION" == "startup" ]]; then
  PROMPT="Ask the logseq agent for session-init. Current project: '$PROJECT_DIR' (path: $PROJECT_PATH). Return:

🚨 **CRITICAL**: logseq-agent is your FIRST call for EVERYTHING:
- Research & information gathering
- Problem-solving (search past solutions)
- Executing any specialized agent (loads definitions from LogSeq)
- All LogSeq operations

## Session Context:
1. **Project Status**: Current status from projects/ namespace for '$PROJECT_DIR'
2. **Available Commands**: List all commands from claude/commands/ (format: '/do [command]')
3. **Available Agents**: List all agent definitions currently in agents/agent-definitions/ (these change over time)
4. **Recent Work**: Recent activities on THIS project

Keep concise. If no project content found, say so."
else
  # resume, continue, clear, compact - lighter context
  PROMPT="Ask the logseq agent for context for project '$PROJECT_DIR'. Return brief: project status, recent work. Commands: '/do [cmd]'. Agents: logseq-agent with different instructions."
fi

if [ -n "${IN_HOOK:-}" ]; then
  CONTEXT=""
else
  export IN_HOOK=1

  CONTEXT=$(claude -p "$PROMPT" \
  --output-format stream-json \
  --verbose \
  --debug \
  --dangerously-skip-permissions \
  --disallowedTools "Read,Edit,Write,NotebookEdit,Search,Glob,Grep,Execution,Bash,BashOutput,KillShell,ExitPlanMode,TodoWrite,WebFetch,WebSearch" \
  --max-turns 3 \
  2>/dev/null) || true
fi

RESPONSE=$(echo "$CONTEXT" | jq -r '.result // .response // empty' 2>/dev/null || echo "")

if [[ -n "$RESPONSE" ]]; then
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $(echo "$RESPONSE" | jq -Rs .)
  }
}
EOF
fi

exit 0
