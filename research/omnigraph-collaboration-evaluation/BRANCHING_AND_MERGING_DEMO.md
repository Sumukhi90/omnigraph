# Branch and merge experiment

## Outcome

Branching and merging were not demonstrated. The installed 0.15.0 Windows CLI
failed at branch creation on both the original graph and a disposable copy.
The error was reported as `Invalid table location` for a Windows local path
containing the Lance `tree/<branch>.<id>?<dataset>` location. Both attempts
reported effects as unknown. Follow-up read-only branch lists showed only
`main`; the copied graph remained openable with its baseline snapshot.

No branch update, diff, merge, or conflict-resolution command was run. In
particular, the prepared `agent_alpha.jsonl` and `agent_beta.jsonl` inputs were
not loaded.

## Reproducible diagnostic on the tested machine

This command was tried only on the disposable copy:

```powershell
$og = Join-Path $env:USERPROFILE '.local\bin\omnigraph.exe'
& $og branch create agent_alpha --from main `
  --target 'file:///C:/path/to/branch-trial/graph.omni' `
  --json
```

Observed error:

```text
Invalid table location: '\\/tree/agent_alpha.<id>?\\?\C:\path\to\branch-trial\graph.omni/__manifest'
code: outcome_unknown
effects: unknown
action: reconcile
```

Reconciliation was read-only:

```powershell
& $og branch list --target 'file:///C:/path/to/branch-trial/graph.omni'
& $og snapshot --json --target 'file:///C:/path/to/branch-trial/graph.omni'
```

Observed visible branch list: `main`. Snapshot remained graph branch `main`,
manifest version 2, with two `Source` nodes, one `Claim`, and two `Supports`
edges.

## Intended experiment after platform issue is resolved

On a fresh disposable graph on a platform where branch creation is verified:

1. Create `agent_alpha` and `agent_beta` from the same `main` snapshot before
   starting their work.
2. Load `fixtures/agent_alpha.jsonl` only into `agent_alpha`; load
   `fixtures/agent_beta.jsonl` only into `agent_beta`.
3. Query each branch, then query `main`. Confirm the additions are visible only
   on their respective branches before merge.
4. Run `branch diff agent_alpha --into main` and the corresponding beta diff.
5. Merge one branch and then the other; query `main` to confirm both additions.
6. On new sibling branches, change the same keyed entity incompatibly; run a
   dry-run merge and then an actual merge only if safe. Confirm the conflict and
   target’s unchanged state.

Do not treat this intended procedure as completed test evidence. Follow the
installed version’s `branch --help` and back up/copy the graph before writes.

## Final execution disposition

No further branch command was run. The final environment check found no
already authorized Linux/remote runtime; Docker/Podman and cloud CLIs were
absent, no SSH host configuration or authenticated GitHub CLI session was
available, and one bounded read-only WSL startup probe produced no output
within 30 seconds. No fresh graph copy, branch, contribution, merge, or
conflict test was created in this attempt. All collaboration outcomes remain
**BLOCKED**; scenario examples in
[SIMULATED_COLLABORATION_SCENARIOS.md](./SIMULATED_COLLABORATION_SCENARIOS.md)
remain **SIMULATED**, not results.

Minimum next action: provide/approve access to a Linux x86_64 environment with
glibc 2.39+ and approve downloading/installing the official Omnigraph 0.15.0
Linux release there, or explicitly approve a WSL recovery/change. Do not retry
branch creation on the Windows graphs.
