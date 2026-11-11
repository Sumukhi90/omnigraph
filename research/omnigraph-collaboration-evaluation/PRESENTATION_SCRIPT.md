# Final presentation outline — R&D team Omnigraph R&D

**Audience:** the reviewer and the R&D teammate
**Length:** 6–8 minutes plus questions
**Purpose:** report the honest result of the Windows pilot and recommend a
safe next step—not to claim that multi-agent collaboration succeeded.

## Slide 1 — Question and decision (30 seconds)

**Title:** Can Omnigraph provide shared, reviewable context for two AI agents?

- Goal: independent contributions, shared context, conflict visibility, human
  review, and accepted retrieval.
- Decision today: basic local graph retrieval works; the collaboration
  workflow remains unverified and is blocked on this Windows setup.

**Speaker note:** “This is an evidence report, not a product demo claiming a
successful merge.”

## Slide 2 — What was set up (45 seconds)

- Windows x64; official Omnigraph 0.15.0 release.
- Isolated synthetic graph with five initial entities.
- No production data, production credentials, cloud infrastructure, or
  external AI account.
- Source checkout and original graph are preserved.

**Visual:** simple pipeline: schema + synthetic JSONL → graph → typed query.

## Slide 3 — Verified result (45 seconds)

- CLI version: 0.15.0.
- Baseline query returned:
  - Synthetic benchmark A
  - Synthetic benchmark B
- Read-only verifier still sees only `main`, manifest version 2, and expected
  counts.

**Visual:** excerpt from verifier output; redact local username if slides are
shared outside R&D team.

## Slide 4 — What blocked collaboration (60 seconds)

- Branch creation failed with `Invalid table location` on original and
  disposable graph paths; operations reported unknown effects.
- Read-only reconciliation showed only `main`; no branch write was retried.
- Local cluster plan failed on a Windows file URI; it was not applied.
- WSL Ubuntu 22.04 startup timed out; no system changes were made.

**Speaker note:** Source inspection narrowed the branch failure to Lance's
local path-to-URL conversion boundary. This is not a confirmed root cause or
proof that Windows is generally unsupported.

## Slide 5 — Status by evidence class (60 seconds)

| Verified | Documented, not verified here | Simulated only | Blocked/unverified |
|---|---|---|---|
| Install, local synthetic load, typed query, read-only snapshot/list | Product guides describe graph branches, diff/merge, MCP and policy | Independent additions, overlapping edits, reviewer resolution and expected query results | Branch isolation/merge/conflicts, server policy, MCP handshake, Copilot, two actual agents |

**Visual:** use [TEST_RESULTS.md](./TEST_RESULTS.md) and
[SIMULATED_COLLABORATION_SCENARIOS.md](./SIMULATED_COLLABORATION_SCENARIOS.md);
keep their status labels visible.

## Slide 6 — Alternatives and fit (60 seconds)

- Git remains the proven tool for code branches and PR review.
- Omnigraph could add typed relational research context if its branch/review
  and operations pass a pilot.
- LangGraph and Letta are more agent-state/runtime-oriented; Mem0 is a
  memory-extraction/retrieval option; MCP is only the connection protocol.
- No competitor was benchmarked, and no adoption advantage is established.

**Speaker note:** See [COMPARISON.md](./COMPARISON.md) for strengths, tradeoffs,
and source links.

## Slide 7 — Safe next experiment (60 seconds)

1. Obtain approval for a compatible Linux x86_64 environment or a confirmed
   Windows fix; do not change WSL without approval.
2. Create a new disposable graph and cluster; verify snapshot and query.
3. Establish secure test actors and read-only MCP `tools/list` and query parity.
4. Run two independent sessions from one baseline; then test separate
   contributions, same-record conflict, reviewer resolution, and recovery.
5. Compare time, correctness, access controls, and operating burden with Git +
   reviewed docs.

## Slide 8 — Recommendation and ask (30 seconds)

**Recommendation:** defer team adoption; retain Git/docs as baseline.
**Ask:** approve the next environment choice and platform investigation, not
   further writes to the original graph.

## Q&A backup

- **Did two agents connect?** No.
- **Did a merge conflict occur?** No; conflict example is explicitly marked as
  a simulation.
- **Was the Windows binary proven unsupported?** No. A particular generated
  local path conversion failed; guides document the workflow, and the precise
  cause remains unconfirmed.
- **Can the current standalone graph be served directly?** The inspected
  v0.15.0 server CLI is cluster-only; the cluster plan did not complete.
- **What is the next hard gate?** A successful fresh disposable cluster and
  verified server before any agent connection or branch-writing test.

## Supporting materials

- [Concise demo script for the reviewer](./DEMO_SCRIPT.md)
- [Test matrix](./TEST_RESULTS.md)
- [Second-stage recovery report](./SECOND_STAGE_RECOVERY.md)
- [Final recommendation](./FINAL_RECOMMENDATION.md)
