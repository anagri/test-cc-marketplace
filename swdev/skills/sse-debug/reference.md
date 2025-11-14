# SSE Event Schema Reference

Complete reference for demo app's Server-Sent Events streaming protocol.

## Event Types

### 1. OpenAI Delta Events (Chat Streaming)

**Format:**
```
data: {"delta":"text chunk here"}

```

**Characteristics:**
- Most frequent event type during chat
- Incremental text content from OpenAI
- No event type field (distinguished by `delta` key)
- Newlines escaped as `\n` in JSON string

**Example sequence:**
```
data: {"delta":"Hello"}

data: {"delta":" how"}

data: {"delta":" can"}

data: {"delta":" I"}

data: {"delta":" help?"}

```

**Frontend handling:**
```typescript
const data = JSON.parse(line.slice(6)) // Remove "data: " prefix
if (data.delta) {
  setMessages(prev => /* append delta to last message */)
}
```

---

### 2. search_start Event

**Format:**
```
data: {"type":"search_start","query":"user search query"}

```

**When fired:**
- OpenAI function calling determines web search needed
- Before Tavily API call executed
- Only if web search checkbox enabled

**Example:**
```
data: {"type":"search_start","query":"latest news about AI"}

```

**Frontend handling:**
- Display "Searching the web..." indicator
- Show search query to user
- Prepare for search results

---

### 3. search_results Event

**Format:**
```
data: {"type":"search_results","results":[{"title":"...","url":"...","content":"..."},...]}

```

**Payload:**
```typescript
{
  type: "search_results",
  results: Array<{
    title: string,      // Result title
    url: string,        // Source URL
    content: string     // Snippet/description
  }>
}
```

**Example:**
```
data: {"type":"search_results","results":[{"title":"OpenAI Announces GPT-5","url":"https://example.com/gpt5","content":"OpenAI today announced..."},{"title":"AI Safety Research","url":"https://example.com/safety","content":"New findings in AI alignment..."}]}

```

**Frontend handling:**
- Display search results as cards/chips
- Show source URLs as links
- Include in context for LLM response

---

### 4. search_complete Event

**Format:**
```
data: {"type":"search_complete"}

```

**When fired:**
- After search_results event
- Before OpenAI continues generating response with search context

**Example:**
```
data: {"type":"search_complete"}

```

**Frontend handling:**
- Hide "Searching..." indicator
- Mark search phase complete
- Prepare for continued chat response

---

## Event Sequences

### Sequence 1: Chat Without Search

```
data: {"delta":"Based"}
data: {"delta":" on"}
data: {"delta":" my"}
data: {"delta":" knowledge,"}
data: {"delta":" ..."}
[connection closes]
```

### Sequence 2: Chat With Search

```
data: {"type":"search_start","query":"current weather in SF"}
data: {"type":"search_results","results":[...]}
data: {"type":"search_complete"}
data: {"delta":"According"}
data: {"delta":" to"}
data: {"delta":" the"}
data: {"delta":" search"}
data: {"delta":" results,"}
data: {"delta":" ..."}
[connection closes]
```

---

## Backend Implementation (server/index.js)

**SSE proxy pattern:**
```javascript
// OpenAI streaming response
const stream = await openai.chat.completions.create({
  messages: [...],
  stream: true
})

// Proxy SSE events to frontend
for await (const chunk of stream) {
  const delta = chunk.choices[0]?.delta?.content
  if (delta) {
    res.write(`data: ${JSON.stringify({delta})}\n\n`)
  }

  // Handle function calls (search)
  const functionCall = chunk.choices[0]?.delta?.function_call
  if (functionCall?.name === 'tavily_search') {
    res.write(`data: ${JSON.stringify({type: 'search_start', query})}\n\n`)
    const searchResults = await tavilySearch(query)
    res.write(`data: ${JSON.stringify({type: 'search_results', results: searchResults})}\n\n`)
    res.write(`data: ${JSON.stringify({type: 'search_complete'})}\n\n`)
  }
}

res.end()
```

---

## Frontend Implementation (src/hooks/useChat.ts)

**EventSource parsing:**
```typescript
const eventSource = new EventSource('/api/chat')

eventSource.onmessage = (event) => {
  const line = event.data
  if (!line.startsWith('data: ')) return

  const data = JSON.parse(line.slice(6))

  if (data.delta) {
    // OpenAI delta event
    setMessages(prev => appendDelta(prev, data.delta))
  } else if (data.type === 'search_start') {
    setSearching(true)
    setSearchQuery(data.query)
  } else if (data.type === 'search_results') {
    setSearchResults(data.results)
  } else if (data.type === 'search_complete') {
    setSearching(false)
  }
}

eventSource.onerror = () => {
  eventSource.close()
}
```

---

## Debugging Checklist

### Backend Debugging

1. **Verify API keys:**
   ```bash
   # Check OpenAI key
   grep OPENAI_API_KEY server/.env

   # Check Tavily key (per-user in database)
   sqlite3 server/db.sqlite "SELECT tavily_key FROM api_keys WHERE user_id=1"
   ```

2. **Test SSE endpoint:**
   ```bash
   curl -N http://localhost:3001/api/chat \
     -H "Content-Type: application/json" \
     -H "Cookie: session_id=..." \
     -d '{"messages":[{"role":"user","content":"test"}]}'
   ```

3. **Monitor backend logs:**
   ```bash
   npm run dev:server | grep -E "(SSE|stream|search)"
   ```

### Frontend Debugging

1. **Check event parsing:**
   ```javascript
   // Add to useChat.ts
   eventSource.onmessage = (event) => {
     console.log('Raw SSE:', event.data)
     // ... rest of handler
   }
   ```

2. **Monitor Network tab:**
   - Look for `/api/chat` EventStream connection
   - Check "Messages" sub-tab for real-time events
   - Verify connection stays open during streaming

3. **Inspect state updates:**
   ```javascript
   // Add React DevTools observation
   useEffect(() => {
     console.log('Messages updated:', messages)
   }, [messages])
   ```

---

## Common Errors

### Error 1: "Unexpected token" in JSON.parse()

**Cause:** Malformed SSE data (missing `data: ` prefix or invalid JSON)

**Solution:**
```typescript
try {
  const data = JSON.parse(line.slice(6))
  // ... handle data
} catch (err) {
  console.error('Failed to parse SSE event:', line, err)
  return // Skip malformed event
}
```

### Error 2: Search events not firing

**Cause:** OpenAI function calling not triggering Tavily search

**Debug:**
1. Verify search checkbox enabled (frontend)
2. Check Tavily API key exists for user (backend)
3. Confirm OpenAI function definition passed in request
4. Test with explicit search query ("Search for...")

### Error 3: Connection closes prematurely

**Cause:** Backend error, timeout, or client-side abort

**Debug:**
1. Check backend error logs
2. Verify no timeout on proxy
3. Monitor browser console for EventSource errors
4. Check network latency (slow responses may timeout)

---

## Performance Notes

- **EventSource auto-reconnects:** Browser retries on disconnect (3s default)
- **Backpressure:** OpenAI stream faster than render can cause buffer buildup
- **Memory:** Long conversations create large message arrays
- **Debouncing:** Consider debouncing state updates for delta events
