# Test results and collaboration matrix

**Environment:** Windows x64, Omnigraph 0.15.0, synthetic data only.
**Evidence rule:** `PASS` means a behavior was executed and observed.
`BLOCKED` means it was not verified. Documented behavior and simulated
scenarios are never counted as passes.

The expanded scenario sketches in
[SIMULATED_COLLABORATION_SCENARIOS.md](./SIMULATED_COLLABORATION_SCENARIOS.md)
are planning material only; none of their branch, conflict, or post-review
results were executed.

## Ten-test collaboration matrix

| ID | Test objective | Prerequisites | Steps (future run on a fresh disposable graph) | Expected outcome | Actual status and evidence | Evidence required to mark PASS |
|---|---|---|---|---|---|---|
| T1 | Confirm two independent agent sessions start from the same shared context. | Working cluster-backed server; supported target; two independent agent sessions/identities; read-only MCP path; common graph and query. | Record the graph commit/snapshot; run the same baseline query through each agent session without sharing an agent transcript. | Both sessions return the same baseline facts and provenance from the recorded snapshot. | **BLOCKED.** The CLI query returned two expected source titles in one session. No MCP connection or two-agent session occurred. | Timestamped/redacted client identity/session evidence, snapshot/commit ID, same query and result digest from both sessions, `/mcp` transport trace or server request log. |
| T2 | Prove two work branches can be created from one baseline without moving `main`. | Fresh backup/copy; branch creation already qualified on the selected platform; baseline branch and commit captured. | From the same `main` commit, create `agent_alpha` and `agent_beta`; list branches; read snapshots of all three. | Both branches refer to the agreed base; `main` stays unchanged; the branch inventory and snapshot agree. | **BLOCKED.** Branch creation failed on the protected original and a disposable copy. Subsequent read-only list showed only `main`. No more branch writes were attempted. | Exact commands and outputs, branch identities/base commit IDs, before/after `main` snapshot, and a clean disposable-root manifest comparison. |
| T3 | Prove agents can contribute distinct findings independently. | T2 passes; schema provides stable keys, source attribution, author, observed time, confidence/review state; each agent has scoped write access to its own branch. | Agent A writes one synthetic finding on alpha; Agent B writes a different finding on beta; inspect each branch separately. | Each branch contains its own contribution and neither branch contains the other's new record. | **BLOCKED.** Synthetic starter JSONL files exist, but no agent-specific write was run because branches were unavailable. | Branch-specific read/query results, exact graph commit IDs, key/provenance fields, write receipts, and unchanged baseline/main snapshot. |
| T4 | Verify unmerged branch changes are isolated from one another and `main`. | T3 passes; branch and query inspection works. | Query alpha, beta, and main before merge using the same baseline question and branch-scoped target. | Alpha sees its own candidate plus baseline; beta sees its own candidate plus baseline; main sees baseline only. | **BLOCKED.** No branch was created or written. Baseline `main` remained at manifest version 2. | Three captured queries, explicit target branch in each result, result comparison, and snapshot/commit IDs. |
| T5 | Review distinct proposals using branch diffs. | T3 passes; exact diff command and output format checked against the installed CLI help. | Generate alpha-to-main and beta-to-main diffs; inspect added, changed, and removed records and source attribution. | Diffs identify the two independent proposals; reviewer can map each to an agent and evidence without relying on prompt history. | **BLOCKED.** Diff was not run; the required branches do not exist. | Raw diff outputs, branch/base IDs, stable entity keys, and reviewer checklist with provenance checks. |
| T6 | Merge non-overlapping contributions and retrieve both from shared context. | T5 passes; merge preview is clean; reviewer approves; recovery/backup procedure is ready. | Preview alpha merge; review and merge it; rebase/refresh beta according to documented workflow; preview and merge beta; query main. | Both independent additions appear once on main; unrelated baseline facts remain; the merge record identifies approvals and source commits. | **BLOCKED.** No merge could be attempted without branches. | Preview and merge receipts, source/target graph commit IDs, before/after snapshot, final retrieval rows, and no duplicate keys. |
| T7 | Confirm divergent edits to the same entity are detected and not silently overwritten. | Fresh sibling branches from one baseline; same stable entity/property updated differently; conflict reporting documented for the release; no merge yet. | A writes candidate value A to a keyed record; B writes incompatible value B to the same key; inspect both; run merge preview only; inspect target before deciding. | Preview reports an entity/property conflict or other explicit refusal; target remains at its prior accepted value until a reviewer resolves it. | **BLOCKED.** No divergent branch writes or merge preview occurred. The documented conflict model was not tested. | Both branch snapshots, merge-preview conflict details, unchanged target snapshot on refusal, and complete before/after entity values. |
| T8 | Reject an unsupported or duplicate finding and demonstrate safe recovery. | Fresh disposable graph; review policy and provenance fields; a known-good candidate and one deliberately invalid candidate; safe retry/recovery instructions. | Submit a candidate with missing/contradictory provenance or duplicate stable key; reviewer rejects it; verify shared branch unchanged; correct the candidate on a fresh/reviewed proposal and verify it independently. | Rejection does not publish to main; duplicate/invalid content is explicitly handled; corrected proposal can be reviewed without retrying an ambiguous write blindly. | **BLOCKED.** The failed branch-create operation was reconciled with read-only checks, but no finding was rejected and no recovery workflow was tested. | Rejection decision, candidate diff, unchanged target snapshot, typed error/refusal if applicable, corrected candidate receipt, and post-recovery query. |
| T9 | Verify least-privilege access denies unauthorized writes. | Working cluster/server; secure HTTPS transport; test-only bearer credentials mapped to distinct actors; applied Cedar policy; read-only path passed. | Actor A performs an allowed read; an agent without write permission attempts a mutation; reviewer identity performs the allowed review/merge action; check logs and snapshots. | Unauthorized action is denied before effects; allowed actions are attributed to the authenticated actor; server policy—not client `--write` consent—decides permission. | **BLOCKED.** Config files validated, but cluster apply/server startup/policy enforcement were not run. No credential was created. | Redacted auth/policy configuration digest, actor mapping, denial response, audit/server logs, unchanged graph head, reviewer action receipt. |
| T10 | Confirm only reviewer-approved content becomes retrievable from shared main. | T6–T8 pass; reviewer decision and merge receipt recorded; query is pinned to shared main. | Query before approval; record the rejected/conflicted content absent; approve and merge the selected resolution; run the same query after merge. | Before merge, candidates remain branch-scoped; after approval, only the accepted resolution and approved evidence are returned from main. | **BLOCKED.** Baseline query on main works, but no candidate or merge was performed. | Before/after query outputs, branch/commit pins, reviewer approval record, merge receipt, and proof the rejected alternative is not accepted as current truth. |

### Status interpretation

- **Executed and passed:** P1–P5 and P8/P10 below. These are setup or
  read-only/configuration checks, not collaboration tests.
- **Executed and failed:** P6/P7 branch-create attempts and P9 cluster plan.
  Their errors are preserved below; these rows are not instructions to retry.
- **Blocked:** P11 and all T1–T10 objectives. A successful basic query does not
  establish branch, server, MCP, or multi-agent behavior.

## Executed setup and diagnostic checks

| Check | Command/action | Observed result | Status |
|---|---|---|---|
| P1 | `omnigraph version` | `omnigraph 0.15.0`, schema 16, serves 14–16, HTTP 0.14 | PASS |
| P2 | `omnigraph init .\graph.omni --schema .\schema.pg` in the original POC | Initialized the graph | PASS |
| P3 | `omnigraph load --data .\evidence.jsonl --mode append --target './.\graph.omni'` | Loaded 5 entities across 2 node types and 1 edge type | PASS |
| P4 | Query with `--params-file .\params.json` | Returned `Synthetic benchmark A` and `Synthetic benchmark B` | PASS |
| P5 | Original graph branch list and snapshot after errors | Only `main`; manifest version 2; 2 sources, 1 claim, 2 edges | PASS |
| P6 | Branch create on original graph with relative Windows target | Invalid table location; effects unknown; subsequent list only `main` | FAIL |
| P7 | Branch create on copied graph with `file:///` target | Same invalid table location; subsequent list only `main` | FAIL |
| P8 | `omnigraph cluster validate --config <mcp-test-folder>` | Config valid, 3 resources and 3 dependency edges; external Blob default-deny warning | PASS |
| P9 | `omnigraph cluster plan` on Windows local root | Failed to read cluster state/lock due invalid `file://\\?\...` URI; no apply run | FAIL |
| P10 | `omnigraph config validate` for anonymous loopback target | `operator configuration is valid` | PASS |
| P11 | WSL alternative check | Ubuntu-22.04 registered but stopped; startup timed out. Docker not found. | BLOCKED |
| P12 | Final compatible-environment discovery | No Docker/Podman/cloud CLI/SSH host configuration or authenticated GitHub CLI session; one read-only WSL startup probe yielded no output within 30 seconds and was stopped | BLOCKED |

## Key observed outputs

Successful query:

```text
2 rows from branch main via sources_for_claim
Synthetic benchmark A
Synthetic benchmark B
```

Branch-create failure on disposable copy:

```text
Invalid table location: '\\/tree/agent_alpha.<id>?\\?\<WINDOWS_BRANCH_TRIAL_ROOT>\graph.omni/__manifest'
disposition: {"effects":"unknown","action":"reconcile"}
```

Cluster-plan failure:

```text
could not read state file: invalid file uri
'file://\\?\<WINDOWS_MCP_TEST_ROOT>\cluster-root/__cluster/state.json'
```

## Integrity and scope checks

- Original source checkout: clean `git status --short`, branch `main`, HEAD
  `40bb2a223b9b9958a212857076f3602b5d8f1702`.
- Original graph: query and snapshot succeeded after the failed branch attempt;
  no visible branch other than `main`.
- Test inputs contain invented benchmark/claim data only.
- No tokens or credentials were placed in fixtures.
- No server or cloud service was started.

## Final execution attempt

No already available compatible Linux x86_64 environment was found. The
read-only WSL probe did not start within the 30-second bound; it was stopped
without changing WSL settings or installing anything. Consequently no fresh
graph copy, branch, merge, conflict, server, MCP, or two-agent test was
attempted. T1–T10 remain **BLOCKED**; the scenarios document is
**SIMULATED** only.
