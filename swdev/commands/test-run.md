---
description: Run unit tests with optional file pattern filtering
allowed-tools: Bash
argument-hint: "[file-pattern]"
---

# Test Runner Command

Run the demo app's unit test suite with optional file filtering.

## Usage Examples

```bash
# Run all tests
/swdev:test-run

# Run specific test file
/swdev:test-run ChatInterface.test.tsx

# Run tests matching pattern
/swdev:test-run ChatInterface
```

## Instructions

1. **Parse arguments from $ARGUMENTS:**
   - Extract file pattern from $ARGUMENTS (if provided)
   - Pattern can be full filename or partial match

2. **Build test command:**
   - Base: `npm test` (runs `vitest run`)
   - If file pattern provided: Append pattern as argument to npm test
   - Example: `npm test ChatInterface` runs tests matching "ChatInterface"

3. **Execute tests:**
   - Run command via Bash tool
   - Display test results (pass/fail counts, test names)
   - Report overall pass/fail status

4. **Log execution:**
   - Write to `${CLAUDE_PROJECT_DIR}/agent-logs/swdev-test-run.log`
   - Include: timestamp, arguments provided, command executed, result summary

## Demo App Context

The React+Vite demo app has:
- 16 unit tests (Vitest + jsdom + MSW)
- Test files: `src/**/*.test.tsx`
- Test command: `npm test` (runs `vitest run`)
- Pattern matching: `npm test <pattern>` runs only matching tests

## Tool Restrictions

This command uses `allowed-tools: Bash` restriction to ensure:
- Only bash commands execute (no file edits during testing)
- Isolated test execution environment
- Security boundary for test operations
