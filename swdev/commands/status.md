---
description: Show swdev plugin status and environment variables
allowed-tools: Write
---

# Status Command

Generate a comprehensive environment variable report for the swdev plugin.

## Step 1: Remove existing log file

**CRITICAL: You MUST first remove the log file if it exists:** `${CLAUDE_PROJECT_DIR}/agent-logs/swdev-env-test.log`

Use the Bash tool to remove the file:
```
rm -f ${CLAUDE_PROJECT_DIR}/agent-logs/swdev-env-test.log
```

## Step 2: Create initial log with env output

**CRITICAL: You MUST create a log file at:** `${CLAUDE_PROJECT_DIR}/agent-logs/swdev-env-test.log`

Use the Write tool to create this file and output the following there:
!`env`

## Step 3: Append prompt expansion test

**CRITICAL: You MUST append to the same log file** using the Write tool.

Add the following section to the log file:

```
=== Prompt Expansion Test ===
Testing if CLAUDE_PROJECT_DIR and CLAUDE_PLUGIN_ROOT expand at prompt-time

CLAUDE_PROJECT_DIR (from prompt expansion): ${CLAUDE_PROJECT_DIR}
CLAUDE_PLUGIN_ROOT (from prompt expansion): ${CLAUDE_PLUGIN_ROOT}

Expected behavior:
- If these show actual paths, prompt-time expansion works in plugin commands
- If these show literal ${...} text, prompt-time expansion does NOT work in plugin commands

---
Prompt expansion test completed
```

This log file is MANDATORY. Create it in Step 1, then append in Step 2.
