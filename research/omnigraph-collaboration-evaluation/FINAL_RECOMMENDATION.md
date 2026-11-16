# Final recommendation

## Final evidence-based decision

**Run a larger pilot only after resolving or avoiding the Windows local
storage-path failure. Do not adopt this setup for team collaboration yet.**

## Why

The installation and basic local graph use worked. A five-entity synthetic
load succeeded, and a typed query returned the expected two sources. This
shows Omnigraph can represent and retrieve a small structured context graph in
this environment.

However, the key value proposition under evaluation—independent graph
branches, reviewable diffs, merge, and conflict detection—could not be tested:
branch creation failed twice with an invalid table-location error. A local
cluster plan also failed with an invalid file URI. Without a working local
server, there was no MCP endpoint and no connection to GitHub Copilot Agent.
No evidence supports an adoption claim for multiple independent agents.

Git remains the verified baseline for code changes. Shared documentation can
continue to hold research notes while the team tests graph retrieval separately.
Omnigraph may still be useful as a typed shared knowledge store, but this run
does not establish an operational advantage over those alternatives.

## Conditions for another pilot

1. Use a platform and storage configuration where Omnigraph 0.15.0 branch
   creation and local cluster operations are confirmed to work.
2. Keep the experiment in a disposable graph with synthetic records.
3. Execute all sixteen cases in [TEST_RESULTS.md](./TEST_RESULTS.md), beginning
   with two branches from one baseline and read-only verification before each
   write/merge.
4. Configure server-side least-privilege policy and a test-only identity.
5. Connect two actual GitHub Copilot Agent sessions via MCP only after
   successful `tools/list` and read-only query checks. If only manual protocol
   calls or scripted workers are used, label them as simulation.
6. Compare the operational burden against the existing Git + docs process
   before adoption.

## Confidence

High confidence in the installation and local query result, and in the
observed Windows branch/cluster errors. Low confidence in broader Omnigraph
multi-agent suitability because the defining collaboration paths were blocked
and not tested.

## Second-stage update

Source inspection narrowed the branch failure to Lance's local path-to-URL
conversion of the generated Windows branch location. This is a verified
failure boundary, not a confirmed upstream root cause or proof that Windows is
unsupported: Omnigraph's v0.15.0 local-storage and branch guides document the
relevant workflows, and Lance 13 includes a Windows branch-location unit test.
The C: hard-link probe passed. The installed v0.15.0 Linux x86_64 release
requires glibc 2.39 or newer; the existing Ubuntu 22.04 WSL distro cannot be
started, and its actual glibc version was not inspected. Do not change WSL or
install another environment without approval.

The server is cluster-only, and the MCP bridge connects to an existing server;
neither can serve the standalone POC graph directly. A local cluster plan did
not complete. VS Code has no detected GitHub Copilot extension or MCP
configuration, and no client handshake was performed. See
[SECOND_STAGE_RECOVERY.md](./SECOND_STAGE_RECOVERY.md) for evidence and a
concise demonstration plan for the reviewer.

## Evidence classification

| Class | Findings |
|---|---|
| **Verified in this environment** | Official Omnigraph 0.15.0 Windows install/version; local synthetic graph initialization and five-record load; typed query returns two expected rows; read-only snapshot/list after branch errors shows only `main` and manifest version 2; latest read-only baseline verifier passed; source checkout remained clean at the recorded commit. |
| **Documented, not verified here** | Omnigraph's graph branch/diff/merge workflow, merge-conflict handling, server-side policy, cluster-backed HTTP/MCP service, and `omnigraph mcp` stdio bridge. Documentation is not execution evidence. |
| **Simulated/test-design only** | Two agents' distinct findings, branch-specific retrieval, contradictory edits, reviewer conflict resolution, and expected before/after query rows in [SIMULATED_COLLABORATION_SCENARIOS.md](./SIMULATED_COLLABORATION_SCENARIOS.md). These are invented examples, not graph records or results. |
| **Blocked or unverified** | Windows graph branch creation and local cluster plan; all sixteen collaboration objectives; actual graph merge/conflict/recovery; access-policy enforcement; MCP handshake/tool listing/query; Copilot connection; two independent live agents; comparison benchmarks for Git, LangGraph, Letta, or Mem0. |

## Decision

Defer team adoption. Continue to use Git for code and reviewed documents for
shared research until the collaboration workflow passes on a platform and
deployment where branch creation and cluster operations are qualified. The
minimum evidence gate is a fresh disposable graph, secure test identities,
read-only MCP handshake/query parity, two independent sessions, branch
isolation, a non-overlapping merge, a same-record conflict resolved by a human,
and recovery evidence. Keep the original POC and source repository out of that
test.

The expanded test plan, simulated scenarios, product comparison, MCP
validation checklist, team procedures, and presentation materials are linked
from [README.md](./README.md). Nothing in those planning documents upgrades a
blocked test to a pass.

## Final execution attempt

A bounded availability check did not find an already authorized Linux/remote
runtime: no SSH host configuration or authenticated GitHub CLI session was
available, and Docker/Podman/cloud CLIs were absent. One read-only WSL startup
probe did not respond within 30 seconds and was stopped. No branch retry,
fresh graph creation, installation, server startup, MCP call, or system change
was made. The final baseline verifier still passed, and the original source
checkout remained clean.

The remaining action is external to this local session: provide or approve
access to a Linux x86_64 environment with glibc 2.39+ and authorize installing
the official 0.15.0 Linux release there (or explicitly approve WSL recovery).
If a paid/third-party host is proposed, obtain explicit approval before using
it. Assignment completion is **not achieved** until the live branch, merge,
conflict, MCP, and two-client/agent acceptance checks have evidence.
