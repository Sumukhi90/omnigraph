# Second-stage recovery and completion

## Executive result

The original Windows branch failure is now narrowed to a Lance local-path
conversion boundary. The installed Omnigraph 0.15.0 command reaches Lance with
a generated branch location that Lance rejects as an invalid local table
location. The documented workflow and Lance source both include Windows
branch-path handling, so this is not evidence that Windows branching is
officially unsupported. The precise upstream defect and a working Windows
workaround remain unconfirmed. No branch write was repeated.

The original synthetic graph still passes the read-only verifier: branch
`main`, manifest version 2, the expected entity counts, and the same two query
rows. The original source checkout remains clean at the previously recorded
commit. No cluster was applied, no server was started, and no MCP request or
two-agent session was made.

## Findings by priority

### 1. Windows storage and branch failure

**Verified from the v0.15.0 documentation**

- The storage guide documents local filesystem roots and `file:///` graph
  addresses, and lists hard-link creation as a local read-write filesystem
  requirement.
- The branch guide documents the graph branch workflow. Neither guide states
  that local graph branching is unsupported on Windows.

**Verified on this machine**

- The C: volume is NTFS. A temporary hard-link capability probe succeeded
  under both the original graph directory and the disposable branch trial.
- The installed CLI reproduced `Invalid table location` when creating a
  branch on the original graph using a relative target and on the disposable
  copy using a `file:///` target. Both outcomes were marked unknown, so neither
  command was retried.
- Read-only checks showed only `main` and the original graph remained readable.

**Source-level diagnosis**

- Omnigraph 0.15.0's branch adapter calls Lance's native dataset branch
  creation; it does not replace Lance's local branch-location conversion.
- Lance 13.0.0 contains a Windows-specific branch-location unit test using a
  `C:\...` local path. That demonstrates Windows path handling in this
  component, but it is not an end-to-end test of the installed Omnigraph
  release.
- Lance's local-path conversion calls `Url::from_directory_path` and emits the
  exact `Invalid table location` error when conversion fails. The observed
  error's input contains a generated `tree/<branch>.<id>?\\?\C:\.../__manifest`
  shape. This confirms the failing conversion boundary and strongly suggests
  the generated path/URI shape is invalid. It does **not** establish which
  upstream transformation created that shape or prove a fix.
- The public GitHub issue search for the exact error phrase returned zero
  results. No issue was created.

Do not treat this as a user path-formatting mistake: both documented target
forms were attempted, and the CLI normalized them to the same extended Windows
path. Do not run branch creation again against either protected graph.

### 2. WSL and Linux alternative

- Read-only WSL status reports WSL 2.6.1.0, kernel 6.6.87.2, and
  `Ubuntu-22.04` as the default distribution.
- Ordinary startup attempts in the prior work timed out with
  `Wsl/Service/CreateInstance/HCS_E_CONNECTION_TIMEOUT`. The stopped distro's
  filesystem was not accessible through the WSL UNC paths.
- No WSL settings or distro contents were changed. No unregister, reset,
  reinstall, Docker installation, or additional dependency installation was
  attempted.
- The v0.15.0 release publishes a Linux x86_64 binary. Its documented runtime
  requirement is glibc 2.39 or newer. The existing Ubuntu 22.04 user's
  userspace could not be inspected while the distro was stopped, so binary
  compatibility there is unverified; do not assume the release will run.

The shortest next route is a working Linux x86_64 host with glibc 2.39 or
newer, followed by a fresh disposable local graph and cluster test. Recovering
WSL, changing its distro, or installing a new Linux environment requires
explicit approval.

### 3. MCP, server, credentials, and client

- `omnigraph-server --help` identifies `--cluster` as its only boot source.
  The v0.15.0 server guide likewise describes serving graphs from an applied
  cluster; the standalone `graph.omni` POC is not a documented server boot
  source. The failed cluster plan therefore blocks hosting the existing graph
  as-is.
- `omnigraph mcp --help` describes a stdio bridge to an already-running server
  or managed target. It is not a server and does not connect directly to a
  standalone graph. Without `--write`, the bridge lists only server-annotated
  read-only tools; server policy still authorizes each call.
- The v0.15.0 MCP guide says `/mcp` is exposed only when the server has a bearer
  credential source. An unauthenticated server does not provide the required
  MCP route. A token-bearing operator target must use HTTPS; the earlier HTTP
  token configuration was rejected by validation.
- The server documentation supports static bearer tokens through environment
  sources including `OMNIGRAPH_SERVER_BEARER_TOKENS_JSON` and
  `OMNIGRAPH_SERVER_BEARER_TOKENS_FILE`. A future test should use a
  purpose-limited test actor and token supplied through a protected
  environment/secret mechanism, never commit it or put it in the submission.
  The bridge should remain read-only until `tools/list` and a query succeed;
  server-side policy remains mandatory. No token was created or stored here.
- The installed VS Code extension inventory includes Claude Code and Continue,
  but not `github.copilot` or `github.copilot-chat`. No user or workspace MCP
  configuration file was present at the checked paths. This does not prove
  the installed AI extensions cannot act as MCP clients; it means no client
  was configured or verified. GitHub Copilot Agent compatibility, protocol
  handshake, `tools/list`, and query execution remain untested.

The server/MCP test is independent of branch creation in principle, but it
still needs a working cluster-backed server. No local or external AI account
was connected.

### 4. Collaboration outcomes

The original matrix remains honest: the single-process local query is verified;
the ten collaboration tests remain blocked. No separate branches, independent
branch writes, branch-specific retrieval, diff, merge, duplicate handling,
conflict detection, human-approved merge, recovery test, policy denial, or
genuine two-agent session was demonstrated.

The cluster config and anonymous loopback operator config validated, but the
cluster plan failed before apply. Validation of those files is not evidence of
a running service or MCP endpoint.

## Preservation note

The post-investigation read-only baseline completed successfully:

- `main` is the only visible branch.
- The graph remains at manifest version 2 with 2 `Source` nodes, 1 `Claim`,
  and 2 `Supports` edges.
- The baseline query returns `Synthetic benchmark A` and
  `Synthetic benchmark B`.
- The source checkout is still on `main` at
  `40bb2a223b9b9958a212857076f3602b5d8f1702`, with no `git status --short`
  output.

For completeness: a temporary hard-link probe was briefly created and removed
under the original graph directory during the filesystem-capability check.
It did not alter graph tables or manifests; the read-only checks above passed
afterward. The disposable branch trial remains separate. No historical report
was replaced.

## Concise demonstration plan for the reviewer

1. Show `omnigraph version` and explain that the records are synthetic.
2. Run the existing baseline query and show the two expected source titles.
3. Show the branch-create error and the read-only evidence that only `main`
   remains; explain that the source code points to a Windows path-conversion
   failure, not a confirmed root cause or general Windows support refusal.
4. Show the MCP boundary: server requires an applied cluster, the cluster plan
   failed, and no Copilot/MCP session occurred.
5. End with the next evidence-gated step: obtain approval for a compatible
   Linux environment, create a new disposable cluster/graph, then run
   `tools/list` and read-only MCP checks before any two-agent writes.

Do not live-run a branch write against the protected original graph.

## Sources checked

- [Omnigraph v0.15.0 local storage guide](https://github.com/ModernRelay/omnigraph/blob/v0.15.0/docs/user/concepts/storage.md)
- [Omnigraph v0.15.0 branch guide](https://github.com/ModernRelay/omnigraph/blob/v0.15.0/docs/user/branching/index.md)
- [Omnigraph v0.15.0 server guide](https://github.com/ModernRelay/omnigraph/blob/v0.15.0/docs/user/operations/server.md)
- [Omnigraph v0.15.0 MCP guide](https://github.com/ModernRelay/omnigraph/blob/v0.15.0/docs/user/operations/mcp.md)
- [Omnigraph v0.15.0 policy guide](https://github.com/ModernRelay/omnigraph/blob/v0.15.0/docs/user/operations/policy.md)
- [Omnigraph v0.15.0 install guide](https://github.com/ModernRelay/omnigraph/blob/v0.15.0/docs/user/install.md)
- [Omnigraph branch adapter](https://github.com/ModernRelay/omnigraph/blob/v0.15.0/crates/omnigraph-core/src/lance_clone.rs#L190-L215)
- [Lance 13 branch-location implementation and Windows test](https://github.com/lance-format/lance/blob/v13.0.0/rust/lance/src/dataset/branch_location.rs#L342-L376)
- [Lance 13 local path-to-URL conversion](https://github.com/lance-format/lance/blob/v13.0.0/rust/lance-io/src/object_store.rs#L573-L579)
- [Omnigraph v0.15.0 release assets](https://github.com/ModernRelay/omnigraph/releases/tag/v0.15.0)

## Follow-on planning deliverables

The following submission files add plans and simulations without changing the
execution record above:

- [Expanded sixteen-case matrix](./TEST_RESULTS.md) — all collaboration cases
  remain blocked; the setup checks retain their original observed outcomes.
- [Simulated two-agent scenarios](./SIMULATED_COLLABORATION_SCENARIOS.md) —
  fictional records and expected retrieval only, not executed.
- [Alternatives comparison](./COMPARISON.md) — product roles, strengths,
  limitations, collaboration fit, and adoption conditions.
- [MCP architecture and checklist](./MCP_RESULTS.md) — documented design and
  a future validation plan; no connection claimed.
- [Team adoption guide](./TEAM_ADOPTION_GUIDE.md) — proposed roles, review,
  branch ownership, access control, and recovery.
- [Presentation outline](./PRESENTATION_SCRIPT.md) and
  [concise demo script for the reviewer](./DEMO_SCRIPT.md).

## Final execution attempt — 2026-11-11

The final execution prompt required finding an already available compatible
environment before attempting any write workflow. This check was bounded and
read-only:

- Present: Windows Omnigraph 0.15.0 CLI and server executables; WSL executable;
  SSH client program.
- Not present: Docker, Podman, Azure CLI, AWS CLI, gcloud, Codespaces runtime
  markers, SSH config, and SSH known-hosts file.
- GitHub CLI is installed but reports no authenticated GitHub host; no
  Codespaces access was verified.
- The registered Ubuntu-22.04 WSL distribution received one normal,
  read-only startup probe for `uname`, glibc, and Omnigraph availability. It
  produced no output within 30 seconds and was stopped. No WSL settings,
  distro files, packages, or Windows settings were changed.

No compatible Linux environment was available within this session. Therefore
no fresh graph copy was created and no branch, write, merge, conflict,
cluster-apply, server, MCP, or two-agent operation was attempted. The existing
branch error was not retried.

The current acceptance state is:

| Requirement | Status |
|---|---|
| Compatible Linux/runtime verified | **BLOCKED** |
| Fresh disposable graph verified | **NOT TESTED** (no compatible runtime) |
| Branches, contributions, merge, conflict/resolution, final retrieval | **BLOCKED** |
| Server start, MCP handshake, `tools/list`, MCP query | **BLOCKED / NOT TESTED** |
| Two independent contributors | **NOT TESTED** |
| Submission plan and evidence updated | **PASS** (documentation only; links checked) |
| Original POC preservation | **PASS** (read-only verifier passed after the probe) |
| Source checkout cleanliness | **PASS** (`main`, `40bb2a223b9b9958a212857076f3602b5d8f1702`, clean status) |

Minimum action required from the user: provide or explicitly approve use of a
Linux x86_64 host with glibc 2.39 or newer, and approve downloading/installing
the official Omnigraph 0.15.0 Linux release there. Alternatively, explicitly
approve WSL recovery or a new Linux environment. If the route is paid or
uses an external provider, approve that provider first. No additional actions
can safely complete the requested live acceptance tests until that
environment and installation authorization are available.
