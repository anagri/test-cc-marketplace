---
name: sse-debug
description: Debug Server-Sent Events streaming issues in chat application, analyze SSE event format (search_start, search_results, search_complete, delta chunks), parse streaming responses, troubleshoot connection problems
allowed-tools: Read, Grep, Bash
---

# SSE Streaming Debugger

Expert in debugging the demo chat app's Server-Sent Events (SSE) streaming implementation for OpenAI chat responses and Tavily web search integration.

## Quick Guide: Common SSE Issues

**Simple queries:** Use this guidance first before loading detailed reference.

### Issue 1: Search Events Not Appearing
**Symptom:** Web search checkbox enabled but no search events displayed
**Check:** Backend receives Tavily API key, OpenAI function calling enabled
**Debug:** Check console for `search_start`, `search_results`, `search_complete` events

### Issue 2: Incomplete Streaming Messages
**Symptom:** Message cuts off mid-stream or doesn't complete
**Check:** SSE connection closed prematurely, error in event parsing
**Debug:** Monitor Network tab for connection closure, check event handler error logs

### Issue 3: Event Parsing Errors
**Symptom:** Console errors like "Unexpected token" or "JSON parse error"
**Check:** Malformed SSE data format, missing newline terminators
**Debug:** Log raw SSE data before parsing, verify `data: ` prefix

## When to Load Detailed Reference

**Load reference.md** when user requests:
- "Detailed SSE event schemas"
- "Complete event type reference"
- "Advanced debugging techniques"
- "SSE protocol specification"
- Keywords: "protocol", "specification", "schema", "format", "structure"

**DO NOT load reference.md** for simple troubleshooting questions answered above.

## Instructions

### Step 1: Identify Issue Type

Determine if query is:
1. **Simple troubleshooting:** Use Quick Guide above
2. **Protocol/format questions:** Load reference.md for schemas
3. **Code implementation:** Read source files (server/index.js, src/hooks/useChat.ts)

### Step 2: Gather Context

**For backend issues:**
- Read `server/index.js` lines 100-250 (SSE proxy implementation)
- Check OpenAI streaming setup
- Verify Tavily API integration

**For frontend issues:**
- Read `src/hooks/useChat.ts` (SSE event parsing)
- Check event handler implementation
- Verify state updates from events

**For event format questions:**
- Load `reference.md` for complete event schemas
- Check examples of each event type
- Understand event sequencing

### Step 3: Debug Strategy

**Connection issues:**
```bash
# Check backend SSE endpoint
curl -N http://localhost:3001/api/chat -H "Content-Type: application/json" -d '{"messages":[{"role":"user","content":"test"}]}'
```

**Event parsing issues:**
- Add logging in useChat.ts event handler
- Verify `data: ` prefix on each event
- Check JSON.parse() error handling

**Search integration issues:**
- Verify Tavily API key configured
- Check OpenAI function calling enabled
- Monitor search event sequence (start → results → complete)

### Step 4: Provide Solution

Based on issue type:
1. **Configuration:** Point to missing API keys or setup
2. **Code bug:** Identify parsing error or connection handling
3. **Protocol:** Explain expected event format from reference
4. **Integration:** Guide through search event flow

## Tool Usage

- **Read:** Access source files (server/index.js, useChat.ts)
- **Grep:** Search for event types, error handling patterns
- **Bash:** Test SSE endpoint with curl, check process logs

## Skill Activation

**Warm-up format (headless):**
```bash
claude -p "1. List all available skills\n2. Debug SSE streaming - messages cutting off mid-stream" --permission-mode bypassPermissions
```

**Natural language (interactive):**
```
Debug SSE streaming issue - web search events not appearing in chat
```

**Trigger keywords:**
- "SSE", "Server-Sent Events", "streaming"
- "search_start", "search_results", "search_complete", "delta"
- "streaming messages", "incomplete responses"
- "connection problems", "event parsing"
