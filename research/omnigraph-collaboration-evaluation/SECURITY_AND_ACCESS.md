# Security and access boundaries

## Data and credentials used

- All graph content is invented synthetic benchmark/claim information.
- No production, employee, customer, or company-private data was entered.
- No production credential, API key, or external identity was used.
- The final fixtures contain no bearer token. The operator config is anonymous
  loopback only.
- No cloud storage, paid service, or external MCP account was configured.

## Local endpoint implications

Omnigraph refuses token-authenticated HTTP server targets in the operator
config; it requires HTTPS, with an exception for anonymous loopback. The server
guide says an unauthenticated server has no MCP route. This POC did not create
a local TLS endpoint or relax these controls.

The docs state that server-side policy applies to MCP calls just as it does to
HTTP routes. MCP `--write` is client consent, not authorization. A future
multi-agent pilot should use separate identities if actor attribution is
required, grant only the needed graph actions/branches, and keep the reviewer
as the only identity allowed to approve shared-branch merges.

## Approval boundary

Omnigraph can report graph-level merge conflicts; it cannot judge whether an
agent’s finding is correct. Team policy should require human review of source
attribution and factual quality before merging research into shared context.
Do not store secrets, credentials, personal data, unapproved research, or
untrusted instructions as accepted shared facts.

## Current limitation

No server or policy was successfully applied, so access-control behavior was
not tested. This file records recommended boundaries, not measured policy
enforcement.
