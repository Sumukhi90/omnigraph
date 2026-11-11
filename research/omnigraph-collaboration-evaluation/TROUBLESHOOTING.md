# Troubleshooting observed in this POC

## `omnigraph` is not found after install

The official installer placed binaries in `%USERPROFILE%\.local\bin` but did
not add it to PATH. Invoke the absolute path:

```powershell
& "$env:USERPROFILE\.local\bin\omnigraph.exe" version
```

Or add that directory to your Windows user PATH using Windows Settings.

## Relative target is reported as an unknown target

The CLI treated `.\graph.omni` as a registered target for `load`. Its error
recommended the path form `./.\graph.omni`, which worked for the append load.
For read-only query and snapshot operations, a `file:///C:/...` URI worked.

## `Invalid table location` during branch creation

This was observed on Windows 10.0.26300.0 x64 with Omnigraph 0.15.0. It
occurred for both the original POC relative path and a disposable copy using
`file:///`. The error referenced a `tree/<branch>.<id>?<Windows dataset path>`
location and reported `effects: unknown`.

Safe response:

1. Do not repeat the write immediately.
2. Run read-only `branch list` and `snapshot --json` against the same graph.
3. If only `main` is visible, preserve the graph and test only on a copy.
4. Do not claim branch creation or merge support was verified.
5. Report the exact CLI version, OS, target form, and full error to the
   maintainer/vendor. No matching public issue was found by exact error phrase.

Both target forms failed here; there is no verified Windows path workaround.

## Cluster plan says `invalid file uri`

The local cluster plan failed while reading `__cluster/state.json` and lock
paths constructed from `\\?\C:\...`. The plan was read-only and no apply was
run. Changing from file URI to the CLI-recognized relative form did not help.
Do not use the un-applied test config as evidence that a local server works.

## WSL fallback

Windows showed an installed Ubuntu-22.04 WSL distribution, but it was stopped.
The startup attempt timed out with `HCS_E_CONNECTION_TIMEOUT`. Docker was not
found. This run did not install another Linux distribution, change WSL, or
download another Omnigraph binary.

## MCP target configuration error

Token-authenticated HTTP targets are rejected by operator config validation:
the endpoint requires HTTPS. Anonymous authentication is accepted for loopback
HTTP, but Omnigraph’s documented MCP endpoint is not mounted without a bearer
credential source. No insecure workaround was attempted.

## Query `key must be a string`

An inline JSON argument lost its expected quoting through PowerShell native
argument passing. Use `--params-file .\params.json`; that approach succeeded.
