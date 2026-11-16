# Omnigraph local collaboration evaluation

This is a sanitized copy of the R&D evaluation reports and synthetic fixtures.
User-specific Windows paths and the team name have been generalized for
publication. The evidence and pass/fail/blocker classifications are preserved.
The branch, merge, MCP, and agent scenarios are not presented as successful
tests; see [TEST_RESULTS.md](./TEST_RESULTS.md) and
[SIMULATED_COLLABORATION_SCENARIOS.md](./SIMULATED_COLLABORATION_SCENARIOS.md).

## Executive result

This is a Windows-only preliminary evaluation of Omnigraph 0.15.0 using synthetic
data. The official Windows release installed and a local graph was initialized,
populated, and queried successfully. The original graph still opens with only
`main` and returns the expected two rows.

The central collaboration test is **blocked**: creating a graph branch on the
Windows local-file backend fails inside the installed CLI with an
`Invalid table location` error. The same result occurred on a disposable copy
using both a relative path and a `file:///` URI. Therefore this run does not
demonstrate independent Omnigraph branches, merges, conflict handling, or two
working AI agents. A local cluster preview also failed while resolving Windows
local control-file URIs, so no server was started and no MCP session was made.

The second-stage investigation narrowed the branch failure to Lance's local
path-to-URL conversion of a generated Windows branch location. NTFS hard-link
creation succeeded, and the v0.15.0 documentation does not declare local
Windows branching unsupported; the exact defect and a working fix remain
unconfirmed. WSL startup still times out. The additive
[second-stage recovery report](./SECOND_STAGE_RECOVERY.md) records the source
evidence, MCP/client status, preservation check, and next-step requirements.
Follow-up planning now includes a fully expanded but still blocked
[sixteen-case matrix](./TEST_RESULTS.md), explicitly simulated
[two-agent scenarios](./SIMULATED_COLLABORATION_SCENARIOS.md), a broader
[alternatives comparison](./COMPARISON.md), an [MCP architecture and
validation checklist](./MCP_RESULTS.md), and updated
[team-adoption](./TEAM_ADOPTION_GUIDE.md) and
[presentation/demo materials](./PRESENTATION_SCRIPT.md).

**Recommendation:** do not adopt this Windows-local configuration for team
branch-based collaboration yet. Continue the pilot only after testing on a
supported Linux environment or obtaining a vendor-confirmed Windows fix. The
single-agent local graph and query path is usable and verified.

## Locations

- Original POC graph and source fixtures:
  `<ORIGINAL_POC_ROOT>`
- Disposable branch-test copy:
  `<WINDOWS_BRANCH_TRIAL_ROOT>`
- Isolated MCP/server configuration attempt (no server started):
  `<WINDOWS_MCP_TEST_ROOT>`
- This sanitized report bundle is stored in this directory.
- The inspected Omnigraph source repository was not modified; it remained clean
  on `main` at `40bb2a223b9b9958a212857076f3602b5d8f1702`.

The `fixtures` folder contains copies of the synthetic inputs and the local
cluster/operator configurations. It contains no production data or credentials.

## Verified local query

In PowerShell:

```powershell
$og = Join-Path $env:USERPROFILE '.local\bin\omnigraph.exe'
$pocPath = 'C:\path\to\poc-copy'
$target = 'file:///' + (Join-Path $pocPath 'graph.omni').Replace('\', '/')
Set-Location $pocPath
& $og query sources_for_claim --query .\queries.gq `
  --params-file .\params.json --format table `
  --target $target
```

Observed result:

```text
2 rows from branch main via sources_for_claim
Synthetic benchmark A
Synthetic benchmark B
```

For detailed commands, limitations, and test outcomes, see
[IMPLEMENTATION_REPORT.md](./IMPLEMENTATION_REPORT.md),
[TEST_RESULTS.md](./TEST_RESULTS.md), and
[FINAL_RECOMMENDATION.md](./FINAL_RECOMMENDATION.md).

## Deliverables

- [Historical Stage 1 research](./STAGE_1_RESEARCH_REPORT.md)
- [Current research report](./RESEARCH_REPORT.md)
- [Implementation and environment report](./IMPLEMENTATION_REPORT.md)
- [Second-stage recovery and completion](./SECOND_STAGE_RECOVERY.md)
- [Installation and configuration](./INSTALLATION_AND_CONFIGURATION.md)
- [Architecture and workflow](./ARCHITECTURE_AND_WORKFLOW.md)
- [Branching and merge experiment](./BRANCHING_AND_MERGING_DEMO.md)
- [Test matrix and evidence](./TEST_RESULTS.md)
- [Simulated collaboration scenarios (not executed)](./SIMULATED_COLLABORATION_SCENARIOS.md)
- [MCP results](./MCP_RESULTS.md)
- [Security and access boundaries](./SECURITY_AND_ACCESS.md)
- [Alternatives comparison](./COMPARISON.md)
- [Team adoption guide](./TEAM_ADOPTION_GUIDE.md)
- [Troubleshooting](./TROUBLESHOOTING.md)
- [Demonstration script](./DEMO_SCRIPT.md)
- [Presentation script](./PRESENTATION_SCRIPT.md)
- [Progress and buddy plan](./PROGRESS_AND_BUDDY_PLAN.md)
- [Final recommendation](./FINAL_RECOMMENDATION.md)
- [Read-only baseline verification script](./verify-baseline.ps1)
