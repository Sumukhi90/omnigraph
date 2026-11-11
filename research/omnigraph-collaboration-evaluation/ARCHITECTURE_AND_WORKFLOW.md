# Omnigraph architecture and workflow

## Data model

Omnigraph stores typed nodes and edges. A `.pg` schema names the node types,
properties, keys, edge types and constraints. A `.gq` source query selects and
returns graph data. JSONL is one documented format for loading multiple node
and edge records.

In this POC, `Source` nodes support a `Claim` through `Supports` edges. The
query follows those edges and returns source titles. The synthetic rows
demonstrate typed graph retrieval, not autonomous agent memory quality.

## Runtime shape

The repository separates parsing/type-checking, planning, engine execution,
catalog publication, policy, storage, and the CLI/server adapters. Lance stores
the physical tables. The graph manifest coordinates the visible versions of
those tables. The intended logical contract is that one graph publication
exposes all participant table updates together.

## Collaboration model in the product

A graph branch is an isolated history of graph state. An agent can read context
on its branch, add or revise graph entities there, and request a merge. Branch
diff and merge-base support review. A merge can fast-forward or perform a
three-way entity merge. Conflicts are about graph entities/constraints, not Git
file hunks. Branches do not isolate a coding agent’s workspace or source files.

## AI client model

The Omnigraph README documents CLI, HTTP/OpenAPI, TypeScript, and MCP clients.
MCP is a protocol adapter to an existing Omnigraph server. `omnigraph mcp`
bridges stdio requests to a configured server/managed target, bound to one
graph. The server applies its authentication and policy to tool calls.

An MCP connection can give an agent tools to query or mutate a graph, but
Omnigraph does not choose which agent runs, orchestrate their task assignment,
judge source credibility, or approve merges. Those duties belong to the
agent-host and human/team workflow.

## Atomicity and recovery implications

Each successful write command can be a durable commit. Several commands are
not one transaction. A lost or ambiguous response is not proof of failure;
inspect graph state before retrying. For this POC, the failed branch command
said its effects were unknown, so a read-only branch list and snapshot were
used before deciding not to retry.

## Demonstrated versus documented

**Executed here:** graph initialization, append load, local query, snapshot,
branch list, configuration validation, and deployment planning attempt.

**Documented but not demonstrated here:** branch creation, graph diff, merge,
structured merge conflicts, policy enforcement, live MCP calls, and concurrent
AI sessions. Branch and server setup failures on Windows prevented those tests.
