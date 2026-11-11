# Implementation and environment report

## Summary

The approved official Windows release installation and a synthetic local graph
journey succeeded. Branch creation did not work on the local Windows file
backend. A local cluster preview also failed before any apply. Thus this
implementation demonstrates single-user local graph retrieval only; it does
not demonstrate team collaboration or genuine multi-agent use.

## Environment

| Item | Observed |
|---|---|
| OS | Windows 10.0.26300.0 |
| OS/process architecture | x64 / X64 |
| Git | Available at `C:\Program Files\Git\cmd\git.exe` |
| VS Code CLI | Available |
| Initial Omnigraph CLI | Not found |
| User install directory | `%USERPROFILE%\.local\bin` did not exist and was not on the process PATH |
| Rust and `protoc` | Not installed; not needed by the prebuilt binary |
| Installed release | Omnigraph 0.15.0 |
| Reported storage support | Internal schema 16; serves v14–v16 |
| Reported HTTP contract | 0.14 |
| WSL/Docker | WSL Ubuntu-22.04 is registered but stopped; startup timed out. Docker CLI was not found. |

## Installation

The public GitHub release API reported stable tag `v0.15.0`, published
2026-11-09. The official `v0.15.0` PowerShell installer was inspected before
execution. It downloads the Windows x64 archive and checksum, validates SHA-256,
extracts to a temporary directory, and installs the release programs into the
user-local bin directory. The authorized command installed the full bundle
(CLI, server, and Azure admission utility when present), not only the CLI.

Installer script SHA-256 observed before execution:

```text
DB574A43C8FBB99F208D09D4D547C003A2E109000FE049E3F0E03596D19BE659
```

`omnigraph version` returned:

```text
omnigraph 0.15.0
internal-schema 16 (serves v14 to v16)
http-contract 0.14
commit 373834b4c1c4b29cf0ddd64bee9565f98c60cc26
```

The installer did not add `%USERPROFILE%\.local\bin` to PATH. Commands in this
run therefore used the absolute path to `omnigraph.exe`.

## Local graph

The original POC at `<ORIGINAL_POC_ROOT>` contains:

- `schema.pg`: `Source`, `Claim`, and `Supports` types.
- `evidence.jsonl`: five synthetic entities/relationships.
- `queries.gq`: `sources_for_claim`.
- `params.json`: the synthetic query parameter.
- `graph.omni`: initialized graph storage.

The installed CLI initialized the graph and appended five entities. The query
returned:

```text
2 rows from branch main via sources_for_claim
Synthetic benchmark A
Synthetic benchmark B
```

An inline `--params` attempt failed because the PowerShell argument arrived as
malformed JSON. Using the CLI's `--params-file` option fixed that issue.

## Branch failure investigation

An earlier branch-create command using the relative Windows target failed with
an error of this form:

```text
Invalid table location: '\\/tree/agent_alpha.<id>?\\?\<ORIGINAL_POC_ROOT>\graph.omni/__manifest'
disposition: {"effects":"unknown","action":"reconcile"}
```

Because the outcome was marked unknown, no write was blindly retried. A
read-only branch list then showed only `main`. The POC snapshot showed manifest
version 2 and the original entity counts.

A separate copy was made at
`<WINDOWS_BRANCH_TRIAL_ROOT>`. It opened and had
the same snapshot. Creating `agent_alpha` there with an explicit
`file:///C:/.../graph.omni` target reproduced the invalid table-location error.
The subsequent branch list on the disposable copy still showed only `main`.
No `agent_beta` branch or branch write was attempted.

The CLI normalized both targets to an extended Windows path. The error indicates
that a branch/tree location derived from that local dataset path was rejected.
This identifies the failing boundary, not the underlying code defect. No
matching public issue was found by searching the exact error phrase.

## Local server/MCP attempt

A separate directory was prepared at
`<WINDOWS_MCP_TEST_ROOT>`. Its cluster config
validated (three resources and three dependency edges). A no-write `cluster
plan` failed while reading local state/lock paths; the CLI reported an invalid
file URI containing the Windows extended path. The plan was not applied and
the cluster root remained empty.

An initial operator config using a token over HTTP was correctly refused by
configuration validation (`endpoint requires HTTPS`). It was changed to
anonymous loopback and then validated. No server was started. Omnigraph's MCP
guide says an unauthenticated server has no `/mcp`; so the valid anonymous
configuration is not a working MCP route. No credentials or external service
were used.

## Preservation

- The original Omnigraph source repository remained clean on `main` at
  `40bb2a223b9b9958a212857076f3602b5d8f1702`.
- The original graph remained readable and showed only `main` after the
  experiments; its snapshot remained at manifest version 2 with the same
  entities.
- No production credentials, cloud infrastructure, real company data, or
  external AI-agent account was used.
- The branch trial and MCP setup were created in new sibling directories.

## Final execution attempt — 2026-11-11

The final execution prompt required a compatible Linux x86_64 environment
before any further graph writes. A read-only availability check found:

- The installed Omnigraph Windows CLI is present and reports version 0.15.0;
  the Windows server binary is present, but its documented boot source is a
  cluster, not the standalone POC graph.
- Docker, Podman, Azure CLI, AWS CLI, gcloud, GitHub Codespaces environment
  markers, and an SSH client configuration/known-hosts file were not present.
- GitHub CLI reported no authenticated GitHub host, so there is no verified
  authorized Codespaces session available through it.
- Ubuntu-22.04 remains registered under WSL. One bounded read-only startup
  probe for architecture, glibc, and Omnigraph availability produced no output
  within 30 seconds and was stopped. No distro configuration or contents were
  changed.

No compatible Linux or already authorized remote environment was verified.
No new graph copy was created, and no branch, merge, server, MCP, or agent
operation was attempted. The next step requires an approved Linux x86_64 host
with glibc 2.39+ (or approval to recover/replace WSL), plus authorization to
download/install the official Linux release there. Any paid or external host
also requires explicit approval.

The original graph's read-only baseline verifier passed after this check. The
source checkout remains clean at the same recorded commit.
