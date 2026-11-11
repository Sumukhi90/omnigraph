# Team adoption guide

## Current decision

Do **not** roll out Omnigraph as the team collaboration or review gate yet.
The installed Windows 0.15.0 CLI can initialize, load, and query a local
synthetic graph, but branch creation failed and the cluster plan did not
complete. There is no verified server, policy, MCP connection, or two-agent
workflow.

This guide is the proposed operating procedure for a future, explicitly
approved pilot after a supported deployment has passed the prerequisites. It
does not claim the procedure has been exercised.

## Roles and separation of duties

| Role | Responsibilities | Permissions to aim for |
|---|---|---|
| Task owner / experiment lead | Defines research question, accepted evidence, data scope, fixed baseline commit, success criteria, and run record. | Read baseline; create/assign task branches; cannot self-approve a shared merge if separation is required. |
| Agent Alpha | Works one assigned topic on its own short-lived branch; adds evidence and provenance; reports uncertainties. | Read shared baseline; write only to its own branch; no merge to protected `main`. |
| Agent Beta | Independently works a distinct topic or the agreed overlap test from the same starting commit. | Same branch-scoped permissions as Alpha; no write to the other agent's branch or protected `main`. |
| Human reviewer | Verifies sources, dates, methods, stable keys, contradictions, duplicates, and whether a proposal is safe to accept. Records an explicit decision. | Read both branches and diffs; may create a resolution proposal; only designated role allowed to merge approved work to shared `main`. |
| Platform/security owner | Operates the cluster/server, credentials, Cedar policy, backups, logs, retention, upgrades, and recovery. | Administrative operations separated from ordinary research writes; test identity distinct from production. |

If the platform cannot enforce branch-scoped permissions, treat branch names
as workflow organization only, not a security boundary. Do not rely on an
agent prompt to enforce access control.

## Branch ownership and task lifecycle

1. **Open a task.** Record the graph/schema version, exact starting graph
   commit, question, allowed source set, expected output, and review owner.
2. **Freeze the baseline.** Create the two short-lived branches from the same
   captured graph commit before either agent writes. Save branch IDs and the
   baseline snapshot.
3. **Assign ownership.** One named agent/session owns each branch for one
   task. No shared branch writes by the two agents. If work is handed off,
   record the handoff and current branch commit first.
4. **Require provenance.** Each candidate must identify a stable record key,
   source URI/title or synthetic fixture ID, observed date, method/sample
   context where relevant, author/agent, uncertainty/confidence, and review
   state. Do not store credentials or sensitive data.
5. **Keep candidates separate.** A proposal remains branch-scoped until human
   approval. Queries for accepted knowledge should explicitly target the
   accepted branch/snapshot, not “latest” without scope.
6. **Review before merge.** Reviewer inspects branch diff, source records,
   duplicate keys, changes to constraints, and merge preview. A clean merge is
   not evidence that the finding is true.
7. **Merge deliberately.** Only reviewer identity merges accepted proposals.
   Record source and target commit IDs, decision, rationale, and merge receipt.
8. **Verify after merge.** Query shared `main` for accepted facts; verify
   rejected alternatives are not treated as current accepted truth; inspect
   snapshot and counts.
9. **Close the task.** Archive redacted evidence and decision notes; retire
   short-lived branches according to the tested retention/deletion procedure.

## Review and conflict handling

- **Non-overlapping additions:** verify each unique key and source; preview
  each merge separately; query after each merge to distinguish which change
  became visible.
- **Same-key/same-field edits:** pause. Do not pick the latest timestamp or
  accept last-writer-wins. Capture both branch values and run only a
  documented, supported merge preview.
- **Explicit conflict:** leave the shared target unchanged while the reviewer
  checks the evidence. Create a resolution proposal that cites both inputs and
  explains the selected conclusion; preserve the rejected candidate as
  attributable history if the data model supports it.
- **Duplicate evidence:** compare source identity, title, method, and date.
  Reuse one source key only when the records genuinely refer to the same
  evidence; otherwise create distinct keys and explain why.
- **Unsupported or stale finding:** reject or quarantine it, preserve the
  reason, and verify that it did not enter accepted shared retrieval.
- **Unclear merge/refusal:** stop. Capture output and inspect branch list,
  snapshots, and graph commit history before any retry. A timeout or
  `effects: unknown` response is not proof that nothing committed.

The sample conflict and reviewer resolution in
[SIMULATED_COLLABORATION_SCENARIOS.md](./SIMULATED_COLLABORATION_SCENARIOS.md)
are fictional expectations only.

## Access control and MCP

- Use separate test actors when actor-level attribution matters; the server
  resolves identity from bearer credentials, not a client-provided actor name.
- Require HTTPS for bearer-authenticated targets. Do not put token plaintext
  in YAML, command arguments, screenshots, source control, or reports.
- Configure server-side least-privilege policy for graph read, candidate
  writes, and shared-branch merge as distinct permissions where supported.
- Keep merge authority with the human reviewer. Agent-side MCP `--write`
  consent does not grant authorization; server policy decides each call.
- Initially expose only read-only MCP tools. Validate handshake, tool list,
  graph binding, query parity, and actor mapping before testing writes.
- Keep access and recovery evidence redacted and local to approved storage.

See [MCP_RESULTS.md](./MCP_RESULTS.md) for the architecture and proposed
validation checklist. No MCP or policy behavior was verified in this POC.

## Recovery and operational safeguards

Before any pilot write, the platform owner should identify the exact backup,
graph snapshot, and durable operation receipt. For every failure or lost
response:

1. Stop further mutations on that target.
2. Capture the typed error/operation ID and identify whether effects are known,
   absent, or unknown.
3. Use read-only branch list, snapshot, and query to inspect accepted state.
4. Reconcile from the operation's durable evidence; do not blindly repeat
   writes or reuse an ambiguous branch creation.
5. Restore only from a separately verified backup/snapshot using the supported
   documented procedure; verify all branches, accepted schema, and queries
   afterward.
6. Revoke test credentials and record the recovery outcome.

The current POC's branch error was reconciled only by read-only checks. It is
not evidence of a complete recovery workflow.

## Adoption gate

Do not move beyond a limited pilot until all required rows in
[TEST_RESULTS.md](./TEST_RESULTS.md) pass on the target deployment, including
independent sessions, branch isolation, non-conflicting merge, same-record
conflict, reviewer resolution, policy refusal, and recovery. Keep Git and
reviewed documents as the source of truth until the graph's governance and
operations are proven to reduce work without weakening review.
