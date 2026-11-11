# Stage 1 — historical repository research

This report preserves the findings from the initial source review. It reflects
the inspected repository snapshot (Omnigraph 0.14.1), not the later installed
0.15.0 executable. The Stage 2 execution results are in
[IMPLEMENTATION_REPORT.md](./IMPLEMENTATION_REPORT.md).

## What Omnigraph is

Omnigraph is a typed property-graph engine. A `.pg` file declares node and edge
types, and `.gq` queries read those graph entities. The system can also provide
full-text and vector search, versioned graph branches, and a CLI, server, SDK,
HTTP, and MCP interfaces.

It is a data/context system, not an AI-agent scheduler, code editor, Git
replacement, or automatic reviewer. Agents can use it to read and contribute
structured graph knowledge when their client and permissions are configured.

## Architecture

The repository describes a compiler, planner, engine, catalog, and Lance
storage layer behind the CLI and server. The compiler parses and type-checks
schemas and queries; the planner creates typed execution plans; the engine
executes graph operations; and the catalog publishes graph history across
multiple Lance datasets.

The architectural invariant is one graph-wide publication boundary: table
effects become visible together through `__manifest`. Lance owns physical
datasets, versions, and indexes. The graph schema and manifest, rather than
physical indexes or caches, define accepted logical state.

## Branching and merging

Omnigraph branches are graph histories, not source-code branches. They begin
from an existing graph snapshot. Writes are isolated until a branch is merged.
The documented merge outcomes include already up-to-date, fast-forward, and
three-way merge. The three-way path compares logical entities with the common
base and can report structured conflicts such as divergent inserts, divergent
updates, delete-vs-update, orphan edges, and constraint violations.

The merge guide says a conflicting merge publishes nothing. It documents
branch diffs, merge-base inspection, and dry-run validation. Branch creation and
deletion are not to be run concurrently from separate writer processes against
the same graph. These are documented capabilities; the current Windows POC
could not execute branch creation, so the merge claims were not validated here.

## Agent connectivity

The source README names the CLI, HTTP/OpenAPI, TypeScript SDK, and MCP as
client surfaces. The MCP guide describes a server-hosted `/mcp` endpoint and an
`omnigraph mcp` stdio bridge for existing server/managed targets. The bridge is
bound to one graph; writes require client write opt-in and server authorization.
The MCP transport exposes graph tools but does not itself implement agent
collaboration policy or make two agents independent.

The repository did not provide a VS Code Copilot-specific verified connection
setup during this initial review. The later execution did not establish a live
Copilot MCP session either.

## Windows and local use

The repository installation guide documents a Windows x86_64 release installer
to `%USERPROFILE%\.local\bin`. The quickstart describes a local-file graph:
initialize from a schema, load JSONL, query, then use branches. Rust and
`protoc` are source-build requirements, not prerequisites for using the
prebuilt release.

The later 0.15.0 install is recorded separately. Although initialization,
loading and querying worked, branch creation and local cluster state access
failed with Windows local-path URI errors in this environment.

## Practical demonstration potential

If branch operations work on the chosen deployment platform, an experiment can
seed shared project facts, fork two task branches, compare their changes,
merge independent updates, then create incompatible edits to one entity and
check the merge conflict response. A human must still determine whether facts
are correct and whether a proposal is approved.

## Initial risks and limits

- Graph branches do not isolate source-code files or prevent Git conflicts.
- Merge logic resolves data-level conflicts, not research truth or code quality.
- Each successful command is its own durable write; there is no general
  multi-command rollback.
- MCP depends on an existing server/managed endpoint, authorization, a
  compatible agent host, and careful handling of unknown write outcomes.
- The server is cluster-oriented; local single-graph work is simpler through
  the CLI.
- Physical indexes are optimizations, not correctness authorities.
- Storage, concurrency, policy, and platform compatibility need empirical
  testing before team adoption.
