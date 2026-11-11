# MCP integration architecture and validation plan

## Actual result — no successful connection

**Genuine agent-to-Omnigraph MCP integration was not achieved.** No server was
started, no MCP request was sent, and no GitHub Copilot Agent session was
connected. The cluster config validated, but the Windows local cluster plan
failed while reading control files. This report is an architecture and
validation plan, not connection evidence.

## Documented architecture

```text
AI host / agent
  └─ spawns `omnigraph mcp` as a child process (stdio MCP)
       └─ resolves one configured server/managed target and one graph
            └─ sends MCP requests over HTTP(S) to server `/mcp`
                 └─ server resolves bearer credential to actor
                      └─ MCP tool catalog + server policy authorize each call
                           └─ graph engine reads/writes accepted graph state
```

- The **MCP client/host** starts the bridge and exchanges protocol messages on
  standard input/output. The bridge keeps protocol output on stdout and
  diagnostics on stderr.
- **`omnigraph mcp` is a client bridge**, not a database host, server launcher,
  or direct connector to the standalone `graph.omni` file. It connects to an
  existing server/managed target and binds one graph (`--graph` or the
  configured default).
- The **Omnigraph server is cluster-only** and serves applied cluster graphs.
  The local POC is a standalone graph and was not served. The attempted local
  cluster plan failed before apply.
- The server exposes `/mcp` when a bearer credential source is configured.
  The unauthenticated local server mode is not a way to test this MCP route.
- The server maps a bearer token to an actor. A client-supplied actor value
  does not replace that identity; policy is enforced on each operation.
- Without bridge `--write`, only server-annotated read-only tools are listed
  and non-read-only calls are refused before relay. `--write` is client
  opt-in/consent, **not** permission. The server's policy remains authoritative.

## Authentication and configuration

### Server-side identity

The v0.15.0 server guide documents static test-token sources including:

- `OMNIGRAPH_SERVER_BEARER_TOKEN` for a single token mapped to actor `default`.
- `OMNIGRAPH_SERVER_BEARER_TOKENS_JSON` for actor-to-token JSON.
- `OMNIGRAPH_SERVER_BEARER_TOKENS_FILE` for a protected JSON file.

Other sources exist, but this POC does not need cloud or production identity.
For a future isolated test, use a random test-only credential, one test actor
per distinct role if attribution is required, and an OS-protected secret/file
source. Never put token plaintext in a tracked file, report, shell history,
command-line argument, screenshot, or fixture. Revoke/remove it after the test.
The authorization policy must explicitly restrict graph and write actions;
do not expose mutation tools before the read-only checks pass.

The previous `operator-config.yaml` is anonymous loopback configuration only.
It contains no token and cannot authenticate the MCP session. The earlier
token-over-HTTP validation was refused because token-bearing endpoints require
HTTPS. Do not work around that refusal by sending bearer tokens over plain
HTTP. A future configuration must use a supported secure transport and the
documented operator credential source; its exact schema must be validated
against the installed release rather than guessed here.

### Graph and target selection

The installed `omnigraph mcp --help` exposes `--target`, `--operator-config`,
`--graph`, `--profile`, and optional `--write`. The bridge binds one graph. The
current local fixture selects an anonymous loopback server and a default graph,
but that server was never brought up and the file is **not** evidence of
working MCP configuration.

The existing [operator-config.yaml](./fixtures/operator-config.yaml) is a
configuration-shape example, not a credentialed MCP setup:

```yaml
targets:
  local_poc:
    kind: server
    endpoint: http://127.0.0.1:18080
    default_graph: research
    auth:
      provider: anonymous
```

Here, `kind` selects a server target, `endpoint` names the server URL,
`default_graph` binds the bridge to graph `research`, and `auth.provider`
selects anonymous access. It passed validation, but anonymous access does not
provide the bearer source required to mount the documented `/mcp` route. The
token-over-HTTP variant was rejected. This snippet is therefore not a usable
MCP endpoint and should not be copied as one.

The server's `--cluster` startup option accepts a cluster configuration
directory or supported storage-root URI. `omnigraph-server --help` identifies
it as the only boot source. Do not pass the standalone POC graph as though it
were a server cluster.

## What was attempted

1. Prepared an isolated cluster declaration and anonymous loopback operator
   target using synthetic schema/query inputs.
2. `omnigraph cluster validate` succeeded and reported three resources and
   three dependency edges.
3. `omnigraph cluster plan` failed on an invalid Windows `file://\\?\...`
   control-file URI. No apply was attempted.
4. An operator config with a bearer token over HTTP was refused by validation;
   it was changed to anonymous loopback for safe config validation only.
5. No server, MCP bridge, `/mcp`, protocol handshake, `tools/list`, MCP query,
   mutation, Copilot connection, or second agent session was run.

See [SECOND_STAGE_RECOVERY.md](./SECOND_STAGE_RECOVERY.md) for the Windows path
diagnosis, WSL status, and preservation evidence.

## Proposed validation checklist

Run only in a new disposable environment after the platform and cluster
blockers are resolved.

1. **Qualify platform and graph first:** verify CLI/server versions; initialize
   a new synthetic graph; capture schema, graph ID, snapshot, and counts.
2. **Apply a minimal cluster:** use a fresh isolated cluster root; validate and
   plan; inspect the plan; apply only after explicit review; verify the graph
   opens and query works. Do not reuse the protected original POC graph.
3. **Configure secure test authentication:** create test-only actor(s) and
   random token(s) in protected local secret storage; configure an explicit
   least-privilege policy; use HTTPS for any bearer-authenticated target.
4. **Start the server safely:** bind only to loopback for a local test; boot
   from the applied cluster; check readiness; never expose a development
   server to a network without the correct transport and policy.
5. **Validate identity boundaries:** confirm missing/invalid token is refused;
   confirm each valid token maps to the expected actor; confirm a client actor
   assertion cannot override the resolved identity.
6. **Connect one read-only client:** configure the MCP-capable host to spawn
   `omnigraph mcp`; select the intended server target and graph; omit
   `--write`.
7. **Handshake and discover:** capture protocol initialization and
   `tools/list`; verify the returned graph scope and tool descriptions; redact
   tokens and sensitive metadata.
8. **Run one read-only query:** compare its rows and types with the same direct
   engine/server query pinned to the same snapshot.
9. **Prove write denial:** attempt a write as a read-only actor; require a
   clear refusal, no manifest/head movement, and an auditable actor. This must
   be policy-enforced by the server.
10. **Only then test authorized writes:** enable bridge `--write` for a
    separate test actor whose server policy permits the precise operation.
    Verify one mutation, one expected publication, and no replay after a lost
    response.
11. **Test actual host/agent compatibility:** connect one agent, then two
    independent sessions; record host/version, identity, graph, query, result,
    and timing evidence. Do not call a protocol-only test an AI-agent test.
12. **Clean up:** stop the server, revoke test credentials, preserve redacted
    receipts/logs, and verify the disposable graph's final snapshot.

### Pass criteria

Report separate results for configuration validation, server readiness,
protocol handshake, tool discovery, query parity, authentication, policy
denial, authorized write, and actual AI-host integration. A pass at one layer
does not imply the next. Do not report the MCP checklist as passed until each
named step has evidence.

## Evidence classification

- **Executed:** CLI help inspection, local cluster config validation, and
  anonymous operator config validation.
- **Failed before deployment:** local `cluster plan`.
- **Not executed:** server startup, `/mcp`, MCP handshake or tool discovery,
  read-only MCP query, policy denial, write, Copilot connection, and concurrent
  agent sessions.
- **Not claimed:** no live, simulated, or scripted protocol call is presented
  as a successful connection.

## Final execution disposition

No MCP operation was attempted in the final execution pass because the
prerequisite server environment remained unavailable. The environment
inventory found no configured SSH remote or authenticated GitHub CLI session,
and no Docker/Podman/cloud CLI. The bounded read-only WSL startup probe did not
produce output within 30 seconds and was stopped. No graph, cluster, server,
token, or operator configuration was changed for this attempt.

**Status:** server startup, MCP initialization, `tools/list`, MCP query,
policy-denial check, and real AI-host connection remain **BLOCKED / NOT
TESTED**. The minimum next action is an approved compatible Linux environment
and approval to install the release binary there; a secure isolated cluster,
test-only credential mechanism, and compatible MCP host must then be
configured and tested. Configuration validation alone remains insufficient.

## Sources

- [Omnigraph v0.15.0 MCP guide](https://github.com/ModernRelay/omnigraph/blob/v0.15.0/docs/user/operations/mcp.md)
- [Omnigraph v0.15.0 server guide](https://github.com/ModernRelay/omnigraph/blob/v0.15.0/docs/user/operations/server.md)
- [Omnigraph v0.15.0 policy guide](https://github.com/ModernRelay/omnigraph/blob/v0.15.0/docs/user/operations/policy.md)
