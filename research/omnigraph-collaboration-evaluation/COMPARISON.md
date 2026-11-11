# Omnigraph and adjacent collaboration tools

## Scope and evidence

This is a workflow comparison, not a feature scorecard or benchmark. The only
runtime behavior verified for this assignment is Omnigraph's Windows 0.15.0
local initialization, append load, and typed query. Its branch create and
local cluster plan failed; no competing product was installed or benchmarked.
The comparison below is based on the named products' documented roles and
should guide a follow-up pilot, not stand in for one.

## Comparison

| Option | Primary strength | Limitations and risks | Collaboration and conflict model | Adoption considerations |
|---|---|---|---|---|
| **Omnigraph** | Typed property graph: stable entity keys, explicit relationships, schema, graph queries, graph history, and a documented branch/diff/merge review lifecycle. A server can expose graph tools over HTTP and MCP. | New database/server/schema and policy operations to run. Graph branches do not isolate source-code files or judge factual quality. Current Windows local branch and cluster paths failed in this POC. | Designed for graph-data branch isolation and entity-aware merge/conflict handling. These workflows are documented but **not demonstrated here**. Human review remains necessary even for a clean merge. | Pilot only after branch creation, diff, merge conflict, restore/recovery, access policy, and server/MCP behavior pass on the target deployment. Keep Git for code. |
| **Git branches and pull requests** | Mature versioning and review for source files, tests, documents, and fixtures; existing CI and approval conventions can be reused. | Text-oriented tools do not by themselves provide a typed graph schema, entity-level constraints, relationship traversal, or semantic knowledge retrieval. The team must structure and search data itself or add an index. | Branches isolate file changes; merges reconcile file-level content, with PR review/checks supplying human approval. Same semantic fact represented in different files may not be recognized as a conflict. | Lowest-risk baseline for code collaboration. Store research in reviewed Markdown/JSONL and use PRs if the goal is primarily artifacts rather than a live shared knowledge service. |
| **LangGraph persistence** | Agent-application framework with two documented persistence concepts: checkpointers for thread-scoped state and stores for cross-thread application data/long-term memory. Useful when the team is building orchestration and wants state integrated into its own graph code. | Not a turnkey shared research database or a universal merge/review workflow. The application chooses what to store, how to retrieve it, how to resolve concurrent edits, and what access control to apply. Persistence backend/retention and deployment still need ownership. | Thread checkpoints support continuity/time travel; the Store is a cross-thread key/value memory abstraction. Neither should be assumed to provide Omnigraph-style graph branches or fact conflict review without application logic. | Consider when building the agent workflow itself. Evaluate a durable backend, shared-store scoping, conflict semantics, retention, and auth in the app before using it as accepted organizational truth. |
| **Letta** | Stateful-agent platform focused on agents that retain memory and improve over time; current project README points to Letta Code as the active source for the agent harness, App Server, channels, and runtime. | Agent-centric state is not automatically a shared, typed organizational knowledge graph. Current docs and deployment behavior were not accessible for full evaluation in this session; details such as team sharing, audit, access controls, and conflict resolution need direct verification. | Product positioning emphasizes persistent agent memory/state. Do not infer branch isolation, multi-writer fact conflict detection, or human merge approval from that positioning. | Candidate if the primary requirement is persistent agent identity/state. Before adoption, verify current Letta Code API, data ownership/export, multi-agent sharing, access control, audit, deployment, and conflict/review behavior. |
| **Mem0** | Memory layer/API that extracts, stores, and retrieves useful facts across sessions. Documentation describes Platform and self-hosted OSS, metadata scoping, semantic/keyword/entity/temporal retrieval on Platform, and app-controlled retrieval into model context. | Memory extraction and ranking can be opaque relative to explicit accepted graph state; the app must decide what to inject and how to govern corrections. Platform quickstart requires an API key; OSS still requires operating configured stores/providers (its documented default model/embeddings use provider credentials). | Supports scoped memories such as user/agent/app/run and retrieval. The documented primary flow is add/search/update/delete, not an Omnigraph-like proposal branch/diff/merge gate; verify any specific collaboration/conflict feature before relying on it. | Consider for fast agent-memory integration if retrieval matters more than explicit relational constraints. Compare hosted-data handling, API cost/keys, extraction fidelity, retention/deletion, tenant scoping, and self-hosting burden. |
| **MCP** | Standardizes how compatible hosts discover and call tools/resources through a protocol boundary. Omnigraph documents an MCP endpoint and a stdio bridge. | MCP is a transport/protocol, not a database, branch model, agent scheduler, source-quality review process, or authorization policy. Client support and deployment setup vary. | Shares the backend server's tool semantics, authentication, and authorization. Any isolation and conflict behavior comes from the connected server/product, not MCP itself. | Add only after the backend is operational. Verify tool discovery, actor mapping, policy, read-only behavior, and refusal semantics before enabling writes. |
| **Shared documents/knowledge base** | Familiar editing, low setup for a two-person research task, and often sufficient for a small decision log. | Structure, relationship constraints, machine retrieval, data export, revision controls, and access semantics depend on the specific product. | Usually document/page history and editorial review; do not assume semantic conflicts are detected. | Good baseline when the desired shared context is a few human-reviewed pages. Choose an explicit owner and source links; compare against the cost of operating a graph server. |

## Practical fit for R&D team

- **Code changes:** Git remains the best primary collaboration surface. A
  graph database does not replace worktrees, code review, CI, or file-level
  history.
- **Research facts:** Omnigraph is interesting when the team needs explicit
  entities, typed relationships, constraints, and graph queries, and is
  willing to run a database plus review and policy workflow.
- **Agent orchestration/state:** LangGraph or Letta may be more direct if the
  main problem is resuming agent runs or building a stateful agent application.
- **Memory retrieval:** Mem0 may be a more direct pilot if the goal is
  extracting/searching long-term memories with less schema authoring, provided
  the team accepts and tests its extraction, scoping, hosting, and correction
  semantics.
- **Transport:** MCP can connect an agent host to an existing tool server. It
  does not make an unavailable server or data store work.
- **Decision rule:** do not adopt on architecture alone. Compare one fixed
  synthetic task on the current Git/docs baseline and a qualified candidate
  product; measure retrieval correctness, conflict visibility, human review
  time, recovery, operational effort, data governance, and cost.

## Sources checked

- [Git Book: branching workflows](https://git-scm.com/book/en/v2/Git-Branching-Branching-Workflows)
- [LangGraph persistence](https://docs.langchain.com/oss/python/langgraph/persistence)
- [LangGraph stores](https://docs.langchain.com/oss/python/langgraph/stores)
- [Letta project README](https://github.com/letta-ai/letta#readme) (current README identifies Letta as a stateful-agent platform and points active development to Letta Code; full Letta documentation was not retrievable during this review)
- [Mem0 introduction](https://docs.mem0.ai/introduction)
- [Mem0 how it works](https://docs.mem0.ai/core-concepts/how-it-works)
- [Mem0 Open Source overview](https://docs.mem0.ai/open-source/overview)
- [Mem0 Platform quickstart](https://docs.mem0.ai/platform/quickstart)
- [Omnigraph v0.15.0 branching guide](https://github.com/ModernRelay/omnigraph/blob/v0.15.0/docs/user/branching/index.md)
- [Omnigraph v0.15.0 merge guide](https://github.com/ModernRelay/omnigraph/blob/v0.15.0/docs/user/branching/merge.md)
- [Omnigraph v0.15.0 MCP guide](https://github.com/ModernRelay/omnigraph/blob/v0.15.0/docs/user/operations/mcp.md)

No product-to-product performance or correctness claim is made from these
documents alone.
