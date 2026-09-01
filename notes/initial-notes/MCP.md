# MCP

-----------------------------------------------------------------------------------------------------

````
How can context for an agentic AI run be provided via MCP protocol?
````

-----------------------------------------------------------------------------------------------------

In the **Model Context Protocol (MCP)**, providing context to an agentic AI run is achieved by leveraging MCP's standard architecture and data primitives. Rather than stuffing all context into a static prompt, MCP enables a dynamic client-server handshake where the **MCP Host/Client** (the AI application/agent runner) fetches, executes, and streams context from **MCP Servers** (the systems holding data and functionality).

---

## Architecture: How Context Flows

In an agentic run, the system operates across three roles:

1. **MCP Host / Agent:** The orchestrator (e.g., Claude Code, Custom LangGraph agent, VS Code) that runs the AI model loop.
2. **MCP Client:** The protocol adapter inside the host that maintains connections to MCP servers via JSON-RPC 2.0 (over STDIO or HTTP/SSE).
3. **MCP Server:** A process serving specific data sources, system integrations, or operational primitives.

```
┌─────────────────────────────────────────────────────────────┐
│                    MCP Host / Agent                         │
│  ┌───────────────────┐               ┌───────────────────┐  │
│  │   LLM / Agent     │ ◄──Context─── │    MCP Client     │  │
│  └───────────────────┘               └─────────┬─────────┘  │
└────────────────────────────────────────────────┼────────────┘
                                                 │ JSON-RPC
                                                 ▼
                                     ┌───────────────────────┐
                                     │      MCP Server       │
                                     │ (Resources/Tools/     │
                                     │    Prompts)           │
                                     └───────────────────────┘

```

---

## 3 Core MCP Primitives for Supplying Context

MCP standardizes how context is provided to an agent run through three core primitives:

### 1. Resources (Passive Context / Read-Only Data)

Resources expose read-only data (file contents, database records, schema definitions, system logs) identified by URIs (e.g., `postgres://db/schema` or `file:///logs/app.log`).

* **Discovery (`resources/list`):** The MCP client asks the server what context items exist.
* **Retrieval (`resources/read`):** The host reads the specific URI payload and injects its raw contents directly into the LLM context window before or during the run.

### 2. Tools (Active Context / Executable Actions)

Tools give the agent dynamic, runtime access to acquire context on-demand or perform actions (e.g., querying a vector database, checking an API status).

* **Discovery (`tools/list`):** The agent discovers available tools and their JSON Schema input parameters.
* **Execution (`tools/call`):** During an agent run loop, if the agent realizes it lacks context, it calls a tool. The tool response is injected back into the conversation thread as fresh context.

### 3. Prompts (Structured Guidance & Workflows)

Prompts are pre-configured prompt templates hosted by the server. They bundle initial system instructions, dynamic parameters, and initial context pre-sets.

* **Discovery (`prompts/list`) & Retrieval (`prompts/get`):** The client fetches a structured template (e.g., a "Code Review" or "Incident Debugger" workflow) containing parameterized system context and few-shot examples to seed the agent run.

---

## Providing Context to an Agent Run: Practical Flow

When initializing an agentic run using MCP, the process typically follows these steps:

### Step 1: Pre-Fetch Static & Structural Context

When starting an execution run, the MCP host queries connected MCP servers to retrieve static resources and system definitions.

```json
// JSON-RPC Request to retrieve database schema resource
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "resources/read",
  "params": {
    "uri": "db://production/schema"
  }
}

```

The returned text/binary content is attached directly to the LLM's system message or initial prompt setup.

### Step 2: Bind MCP Tools to the Agent Framework

The agent fetches available tools (`tools/list`) and converts them into the format expected by the framework (e.g., LangChain, LlamaIndex, Semantic Kernel).

```python
# Example in Python using official mcp SDK + LangChain
from mcp import ClientSession, StdioServerParameters
from langchain_mcp_adapters.tools import load_mcp_tools

# Connect client to an MCP server via Stdio
async with ClientSession(read_stream, write_stream) as session:
    await session.initialize()
    
    # Context Primitive: Fetch tools dynamically from MCP server
    mcp_tools = await load_mcp_tools(session)
    
    # Bind tools to the agent run loop
    agent = create_react_agent(model, tools=mcp_tools)

```

### Step 3: Runtime Dynamic Context Ingestion (Tool Calls)

During the agent loop, if the AI needs real-time context to make a decision, it triggers a `tools/call` through MCP.

1. Agent outputs a tool invocation: `call_tool("search_docs", {"query": "auth protocol"})`
2. MCP Client executes `tools/call` on the target MCP server.
3. MCP Server returns runtime context (e.g., documentation snippets).
4. MCP Client feeds the output back into the LLM context window as a `tool_result` message.

### Step 4: Context Management & Meta-Information

Because MCP uses JSON-RPC 2.0 with metadata support, contextual run metadata (such as `session_id`, `user_id`, or `auth_token`) can be passed via the `_meta` field in protocol messages to scoped access controls.

```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/call",
  "params": {
    "name": "fetch_user_tickets",
    "arguments": { "status": "open" },
    "_meta": {
      "user_id": "usr_99812",
      "auth_token": "bearer xyz..."
    }
  }
}

```

---

## Summary Matrix

| Context Need | MCP Primitive | How it's Provided |
| --- | --- | --- |
| **System Rules & Workflows** | `Prompts` | Pre-fetched via `prompts/get` to build the agent's base system prompt. |
| **Files, Schemas, Static Data** | `Resources` | Pre-loaded via `resources/read` and attached to initial context. |
| **On-Demand Real-Time Data** | `Tools` | Retrieved dynamically during agent execution via `tools/call`. |

-----------------------------------------------------------------------------------------------------

````

````

-----------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------

````

````

-----------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------

````

````

-----------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------

