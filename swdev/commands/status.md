---
description: Show swdev plugin status and environment variables
allowed-tools: Write
---

# Status Command

Generate a comprehensive environment variable report for the swdev plugin.

**CRITICAL: You MUST create a log file at:** `${CLAUDE_PROJECT_DIR}/agent-logs/swdev-env-test.log`

Use the Write tool to create this file with the following format:

```
=== swdev Plugin Environment Test ===
Timestamp: <ISO8601 timestamp>
Plugin: swdev
Marketplace: test-cc-marketplace (GitHub)
Version: 1.1.0

=== Environment Variables ===

CLAUDE_PROJECT_DIR: <value or "NOT SET">
CLAUDE_PLUGIN_ROOT: <value or "NOT SET">
PWD: <value or "NOT SET">

=== All CLAUDE-prefixed Variables ===
<List all environment variables starting with CLAUDE_>

=== Plugin Information ===
1. Plugin name: swdev
2. Marketplace: test-cc-marketplace (GitHub repository)
3. Installation method: GitHub shorthand (username/test-cc-marketplace)
4. Distribution: Public GitHub repository
5. Command execution: Successful

---
Environment test completed
```

This log file is MANDATORY. Create it immediately using the Write tool.
