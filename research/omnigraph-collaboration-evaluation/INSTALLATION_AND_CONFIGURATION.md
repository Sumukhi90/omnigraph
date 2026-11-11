# Installation and local configuration

## Windows release install

The official Windows installer was run after approval. Its pinned 0.15.0
command is shown here for reproducibility; do not rerun it unless you intend to
reinstall the release programs:

```powershell
$installer = Join-Path $env:TEMP 'omnigraph-install-v0.15.0.ps1'
Invoke-WebRequest -UseBasicParsing `
  -Uri 'https://raw.githubusercontent.com/ModernRelay/omnigraph/v0.15.0/scripts/install.ps1' `
  -OutFile $installer
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installer -Version v0.15.0
Remove-Item -LiteralPath $installer
```

The installer’s default destination is `%USERPROFILE%\.local\bin`. It verifies
the downloaded archive checksum and installs the release bundle. It did not
modify PATH. The CLI was verified at:

```powershell
& "$env:USERPROFILE\.local\bin\omnigraph.exe" version
```

This machine reported Omnigraph 0.15.0, internal schema 16, serving schema
versions 14–16, HTTP contract 0.14.

If you want to invoke `omnigraph` without its full path, add the install
directory to your **user** PATH in Windows Settings or use its absolute path as
the commands in this report do. That PATH change was not made during this run.

## Requirements

For the prebuilt Windows x64 release, Rust and `protoc` were not required. The
repo’s source-build documentation lists Rust stable and `protoc`; that is a
different route and was not used. No cloud account is needed for the documented
basic local graph workflow.

## Build a fresh local graph

Use the copied synthetic fixtures in this submission or the original POC
fixtures. Choose a new graph path; Omnigraph `init` refuses already initialized
graphs.

```powershell
$og = Join-Path $env:USERPROFILE '.local\bin\omnigraph.exe'
Set-Location 'C:\path\to\your\new-poc-folder'
& $og init .\graph.omni --schema .\schema.pg
& $og load --data .\evidence.jsonl --mode append --target './.\graph.omni'
& $og query sources_for_claim --query .\queries.gq `
  --params-file .\params.json --format table `
  --target 'file:///C:/path/to/your/new-poc-folder/graph.omni'
```

PowerShell backslash paths and the target parser have an important distinction:
the CLI interpreted a bare `.\graph.omni` load target as a registered target.
Its error recommended `./.\graph.omni`; that form worked. The explicit `file:///`
target also worked for snapshots and queries. Use your actual path in place of
the example. Avoid overwriting an existing graph.

## Local server configuration status

An isolated cluster bundle validated, but its no-write deployment preview hit a
Windows local file-URI error. No cluster was applied and no server was started.
The MCP-related configs are in `fixtures/cluster.yaml` and
`fixtures/operator-config.yaml`; the latter is anonymous loopback only, contains
no token, and does not by itself enable MCP. They are diagnostic artifacts, not
a verified server setup.

## Installed programs

The official bundle reported installing `omnigraph.exe`,
`omnigraph-server.exe`, and the Azure admission program. Only the CLI version
was executed for verification. The server was not started.
