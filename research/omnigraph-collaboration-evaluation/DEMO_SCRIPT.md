# Concise demo script for the reviewer

**Time:** 3–4 minutes
**Mode:** read-only demonstration plus clearly labeled simulation
**Safety:** do not run branch creation, load, merge, server startup, or MCP
commands against the protected original graph.

## 1. Set expectations (20 seconds)

Say: “This is a Windows x64 Omnigraph 0.15.0 pilot with synthetic data. We
verified local retrieval. We did not achieve branches, merge, MCP, or two
actual AI agents.”

## 2. Show the installed release (20 seconds)

In PowerShell:

```powershell
& "$env:USERPROFILE\.local\bin\omnigraph.exe" version
```

Expected recorded output includes `omnigraph 0.15.0`. If the command fails,
stop and report the failure; do not improvise an install during the
presentation.

## 3. Re-run the read-only baseline verifier (60–90 seconds)

```powershell
Set-Location '<PATH_TO_THIS_REPORT_FOLDER>'
.\verify-baseline.ps1 -PocPath 'C:\path\to\fresh-poc-copy'
```

This verifier runs version, branch list, snapshot, and the known query. It
performs read-only operations. Replace both placeholders with the actual report
folder and a verified disposable graph path; do not point it at a protected
graph if you do not want to inspect it. The previously observed output showed only
`main`, manifest version 2, two `Source` nodes, one `Claim`, two `Supports`
edges, and the two expected synthetic source titles. If today's verifier
output differs or errors, show the actual output and stop; do not claim the
previous result applies to the new run.

## 4. Explain the blocker (45 seconds)

Open [TEST_RESULTS.md](./TEST_RESULTS.md) and show the preserved branch-create
error and `BLOCKED` collaboration matrix. Say: “We did not retry because the
CLI reported unknown effects. Read-only reconciliation found only `main`.
The separate local cluster plan also failed before apply.”

## 5. Show a simulation, not a live result (45 seconds)

Open [SIMULATED_COLLABORATION_SCENARIOS.md](./SIMULATED_COLLABORATION_SCENARIOS.md).
Point to the explicit **SIMULATION ONLY — NOT EXECUTED** label and summarize:

- Alpha proposes a latency finding; Beta proposes a temperature finding.
- Both begin from one baseline and would keep their unmerged findings scoped
  to separate branches.
- They then propose opposite values for the same `pilot-readiness` record.
- A reviewer would inspect evidence and approve a new conditional resolution.

Say: “These expected rows are a test design, not results from Omnigraph.”

## 6. Close with the next gate (20 seconds)

Say: “Before any two-agent test, we need a compatible platform, a fresh
disposable cluster, secure test identities, and verified read-only MCP
discovery. The recommendation is to defer adoption and keep Git plus reviewed
docs as the baseline.”

## If asked for a successful two-agent or MCP demo

Answer plainly: “We do not have one yet. Branch creation and cluster setup
blocked the test, and no MCP request or Copilot session occurred.” Refer to
[MCP_RESULTS.md](./MCP_RESULTS.md) and
[SECOND_STAGE_RECOVERY.md](./SECOND_STAGE_RECOVERY.md). Do not substitute the
simulated scenario or a protocol checklist for live evidence.
