# Research report — Omnigraph 0.15.0 POC

## Executive finding

Omnigraph is a typed property-graph database with a graph-level versioning and
branching model. Its design is relevant to shared structured agent context:
agents can potentially query the same ontology, contribute on separate graph
branches, review diffs, and merge approved changes.

This Windows evaluation verifies only installation and basic local graph
retrieval. It does **not** establish that the main collaboration workflow works
in this environment: branch creation failed on the Windows local-file backend,
and the local cluster deployment preview also failed on Windows path handling.
The MCP server and two actual Copilot agent sessions were not run.

## Verified environment facts

- Latest public stable release observed: `v0.15.0`, published 2026-11-09.
- Installed CLI: Omnigraph 0.15.0; internal schema 16, serves 14–16; HTTP
  contract 0.14.
- Windows 10.0.26300.0, x64.
- The official Windows installer was inspected and executed after approval;
  its download checksum verification is part of the installer.
- The source checkout was inspected at `main`,
  `40bb2a223b9b9958a212857076f3602b5d8f1702`, and remained clean.
- A local graph was initialized, five synthetic records loaded, and one typed
  query returned the two expected source records.

## Product architecture and concepts

The project separates compiler, planner, engine, catalog, storage, policy, CLI,
server, and MCP adapter components. Its graph model is composed of typed
entities and relationships. Lance supplies physical dataset storage; the graph
catalog coordinates accepted table pointers, graph lineage, and publication.
The design invariant is one graph-wide publication boundary for a multi-table
write.

Graph branches represent independent graph histories, not source-code
workspaces. The documented branch review flow is create from a baseline, write
to the branch, inspect branch diffs, preview a merge, then publish. Three-way
merge compares entity changes against a common base and documents conflicts
such as divergent updates and insert/delete conflicts. A coding team would
still need Git for code changes and human or application-level review for
whether a research claim is true.

## Agent and MCP model

The documented MCP endpoint is hosted by an Omnigraph server. The CLI’s
`omnigraph mcp` command is a stdio-to-existing-server bridge, bound to one
graph; it is not itself a server or a direct local-file connector. MCP tool
calls share the server’s authentication and authorization checks. Client write
opt-in does not replace server policy.

The current environment never reached a running local server because cluster
planning failed on the local Windows storage path. It therefore did not expose
tools to GitHub Copilot Agent or prove multi-agent behavior.

## Observed Windows compatibility failures

Two independent platform surfaces failed:

1. **Branch creation:** the CLI returned `Invalid table location` for the
   generated `tree/<branch>.<id>?\\?\C:\.../__manifest` path. Repeating on a
   disposable graph copy and using an explicit `file:///` URI reproduced it.
   The command disposition was `effects: unknown`. Subsequent read-only checks
   showed only `main` and the expected snapshot.
2. **Cluster planning:** a no-write plan could not read local cluster state and
   lock files, reporting an invalid file URI containing the extended Windows
   path `\\?\C:\...`. The plan was not applied.

These are observed errors, not a confirmed root-cause analysis or a claim that
all Windows configurations fail. No matching public issue was found from an
exact-phrase issue search. WSL Ubuntu-22.04 was registered but stopped; starting
it timed out, so it was not a fallback. Docker was not available.

## Practical fit

Potential advantages, conditional on working deployment:

- The ontology can enforce shape and key constraints on shared facts.
- Graph queries can retrieve relationships and source attribution if the schema
  includes it.
- Branches offer a data-oriented proposal/review lifecycle.
- A server can expose graph operations through documented HTTP and MCP tools.

Limits relevant to R&D team:

- Graph-level isolation does not isolate code files or replace Git PRs.
- Merge conflicts are logical data conflicts, not research-quality decisions.
- Multi-command work is not one transaction; each successful write may persist.
- MCP needs a server and suitable credentials/policy; it does not supply
  orchestration by itself.
- The Windows local workflow used here failed at branch creation and local
  cluster state reads.

## Evidence and recommendation

The executed evidence supports a narrow finding: local graph initialization,
JSONL append, and typed query are usable on this machine. It does not support a
multi-agent adoption claim. Keep the existing code collaboration process and
run a second, disposable pilot on a platform where branch and server operations
have been confirmed. See [TEST_RESULTS.md](./TEST_RESULTS.md) and
[FINAL_RECOMMENDATION.md](./FINAL_RECOMMENDATION.md).
