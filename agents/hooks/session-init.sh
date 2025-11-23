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
1. Project-specific status from projects/ namespace matching this directory
2. Available commands - The ONLY slash command is '/do'. List as '/do research', '/do plan', '/do commit' etc. Commands defined in claude/commands/
3. Available agents - logseq-agent is called with different agent instructions from agents/agent-definitions/. Key agents: research-agent, memory-agent, architecture-agent, feature-planner. NOTE: logseq-agent handles both LogSeq operations AND research/information gathering tasks - use logseq-agent for research, not general-purpose agents
4. Recent work on THIS project
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
