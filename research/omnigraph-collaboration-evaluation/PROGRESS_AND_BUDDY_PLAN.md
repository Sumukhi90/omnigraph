# Progress and buddy plan

## R&D team progress update

- **Date:** 2026-11-11
- **Progress:** Installed official Omnigraph 0.15.0 on Windows x64; verified a
  local synthetic graph, five-record append, and typed query. Rechecked that
  the original source repository is clean and the original POC remains
  readable. Reproduced a Windows local branch-create path error on a
  disposable graph copy. Validated a synthetic cluster bundle, but its local
  deployment preview failed on a Windows control-file URI.
- **Next Steps:** Qualify branch and merge behavior on a supported Linux
  environment; then configure a local server with test-only identities and
  policy, verify MCP tool discovery/read behavior, and run the two-agent
  experiment.
- **Blockers:** Windows local branch create returns `Invalid table location`
  with unknown effects; local cluster plan returns invalid file URI.
  WSL Ubuntu-22.04 startup timed out and Docker was unavailable. No genuine
  multi-agent/MCP session was achieved.

## Notion-ready status

**Milestone update:** Local synthetic graph setup and retrieval are verified on
Omnigraph 0.15.0 / Windows x64. Branch creation failed on the Windows local
backend even on a disposable copy; no branch merge or conflict tests could be
run. The local cluster plan also failed on Windows path handling, so MCP was
not started. No production data or credentials were used. Recommendation:
continue only with a platform-compatibility pilot before team adoption.

**Question for maintainer:** Is Omnigraph 0.15.0 expected to support graph
branch creation and direct local cluster control files on Windows x64? The
observed branch error is `Invalid table location` for the
`tree/<branch>.<id>?\\?\C:\.../__manifest` path; the cluster plan reports an
invalid `file://\\?\C:\.../__cluster/state.json` URI.

No Notion page was opened or updated for this assignment.

## Follow-up planning update — 2026-11-11

The existing execution results remain unchanged: branch creation, cluster
deployment, MCP, and two-agent collaboration are still blocked/unverified.
At that stage, the submission included the original ten-test matrix, a separate
fictional two-agent scenario document with expected retrieval shapes,
expanded alternatives and MCP guidance, a team operating procedure, and a
presentation outline plus read-only demo script for the reviewer. These are plans and
simulations, not new runtime evidence. Internal Markdown paths and heading
anchors were checked; the protected graph's read-only baseline verifier passed
again. No branch creation, server startup, WSL change, or source-repository
edit was performed for this update.

## Buddy exercise plan

- **Task lead:** keep the synthetic baseline fixed, run the commands, preserve
  outputs, and record graph commit identifiers.
- **Buddy:** independently verify branch diffs and final query results, inspect
  provenance, and challenge conflicting conclusions.
- **Agent A:** research one non-overlapping synthetic/API topic on its own
  branch.
- **Agent B:** research a different topic on a sibling branch from the same
  starting commit.
- **Reviewer:** inspect diffs, resolve any data conflict, and approve the merge.
- **Shared checkpoints:** common starting commit; both branch diffs reviewed;
  conflict dry-run inspected; final shared branch queried after approval.

The roles above are a plan only. The current run did not execute a two-agent
session because branch creation and server/MCP setup were blocked.

## Coverage audit update — 2026-11-16

The follow-up audit found that the original matrix did not separately specify
different-property edits to one entity, conflicting updates to a keyed edge,
relationship-add versus endpoint-delete, concurrent client writes, or
response-loss recovery. The test matrix and simulated scenario document now
include these cases as **not executed** acceptance tests. The cluster fixture
now points to its included `queries.gq` file so the declared source exists.
No live branch, server, MCP, concurrent-client, or multi-agent test was run in
this update.

### Validation executed during this review

- `omnigraph cluster validate --config research/omnigraph-collaboration-evaluation/fixtures` — **PASS**; config valid, 3 resources and 3 dependency edges. The CLI emitted the expected external-Blob default-deny warning.
- PowerShell static fixture check — **PASS**; parsed all 3 JSONL fixtures and `params.json`, resolved 4 relationship endpoints, and confirmed the cluster schema/query paths exist.
- Local Markdown link-target check — **PASS** for all 19 research Markdown files; `git diff --check` reported no whitespace errors.
- Attempted a fresh local graph initialization in a unique `%TEMP%` directory — **BLOCKED** before graph creation with `target_config_invalid: Access is denied. (os error 5)`. A read-only check found no `graph.omni` output; no branch write was issued.
- `cargo test -p omnigraph-engine --test integration branching::` — **NOT RUN**; PowerShell could not find `cargo`. Rust integration and failpoint suites therefore remain unverified in this environment.
