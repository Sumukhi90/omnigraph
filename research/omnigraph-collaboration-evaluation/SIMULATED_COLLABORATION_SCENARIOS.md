# Simulated two-agent collaboration scenarios

> **SIMULATION ONLY — NOT EXECUTED.** The examples below are invented to make
> a future test concrete. They are not observed Omnigraph rows, branch outputs,
> merge previews, or MCP responses. Windows branch creation and local cluster
> setup remain blocked. Do not copy these expected results into a test report
> as actual results.

## Purpose and schema boundary

Use an invented R&D team battery thermal-management study to test whether two
independent agents can add evidence, work on the same research question, and
submit a reviewable resolution.

The existing verified POC schema is deliberately smaller: `Source` has
`slug`/`title`; `Claim` has `slug`/`statement`; `Supports` connects them.
It has no reviewer, status, confidence, citation URI, or update-history
properties. These scenarios therefore describe a **proposed test schema** and
logical outcomes, not JSONL guaranteed to load under the current POC schema.
They must be mapped to a qualified schema and checked with that version's
CLI before execution.

Suggested fields for the future fixture:

| Record | Example properties |
|---|---|
| `Finding` / claim | stable `slug`, `statement`, `status` (`candidate`, `accepted`, `rejected`), `confidence`, `observed_at` |
| `Evidence` / source | stable `slug`, `title`, `source_ref`, `method`, `sample_size`, `author` |
| `Supports` edge | finding key, evidence key, relationship note |
| Review event (if the schema supports it) | candidate key, reviewer, decision, rationale, reviewed time |

The minimum test data should be synthetic and should use explicitly fake
source references such as `synthetic://thermal/run-041`, never real research
claims or company data.

## Shared baseline

Assume the fixed starting snapshot contains:

| Key | Baseline value |
|---|---|
| `pilot-readiness` | “No pilot decision has been made; two synthetic lab runs are available for review.” |
| `thermal-run-041` | Synthetic bench run, 20 cycles, profile A |
| `thermal-run-042` | Synthetic bench run, 20 cycles, profile B |

**Simulated baseline retrieval** for “What is known about the battery thermal
pilot?”:

```text
pilot-readiness — No pilot decision has been made; two synthetic lab runs are available for review.
thermal-run-041 — Synthetic bench run, 20 cycles, profile A
thermal-run-042 — Synthetic bench run, 20 cycles, profile B
```

This exact baseline result was not run against the existing POC; its actual
query returns the two synthetic benchmark titles documented in
[TEST_RESULTS.md](./TEST_RESULTS.md).

## Scenario A — independent, non-overlapping contributions

Both agents begin from the same captured baseline commit.

| Owner | Proposed addition (all numbers are fictional) |
|---|---|
| Agent Alpha, branch `agent_alpha` | `latency-finding`: “In synthetic profile A, controller revision C reduced median response latency by 12% across 20 bench cycles.” Supported by `thermal-run-041`. |
| Agent Beta, branch `agent_beta` | `thermal-finding`: “In synthetic profile B, peak cell temperature was 3°C lower than baseline across 20 cycles; measurement uncertainty was ±1°C.” Supported by `thermal-run-042`. |

### Expected retrieval (simulated)

| Query target | Expected result before merge |
|---|---|
| `main` | Baseline only; neither new finding appears. |
| `agent_alpha` | Baseline plus `latency-finding`; no `thermal-finding`. |
| `agent_beta` | Baseline plus `thermal-finding`; no `latency-finding`. |

After reviewer approval and both merges, **simulated** `main` retrieval would
include both findings, each connected to its own evidence record. The test
must assert exact stable keys and provenance, not merely a natural-language
summary.

## Scenario B — two agents update the same record incompatibly

Both agents edit the same stable key, `pilot-readiness`, from the shared
baseline. They do not create separate keys that would hide the overlap.

| Branch | Proposed new value for `pilot-readiness` |
|---|---|
| Agent Alpha | “Advance to a limited pilot: the synthetic latency result is promising; retain temperature monitoring.” |
| Agent Beta | “Hold: 20 cycles are insufficient evidence for a pilot, and the synthetic temperature result is close to the stated measurement uncertainty.” |

### Expected retrieval and conflict handling (simulated)

1. Before merge, each branch returns its own candidate wording; `main` keeps
   the original undecided value.
2. A merge preview from either branch into `main` is expected to identify a
   conflict on the shared record/key (or return another explicit structured
   refusal). **This expectation is not verified against the installed binary.**
3. Before review, querying `main` must still return the original baseline
   value. A conflict is not permission to silently choose last-writer-wins.
4. The human reviewer checks both evidence records and chooses a new resolved
   candidate, for example:

   > “Conditional next step: repeat the synthetic run with a pre-agreed larger
   > sample and temperature acceptance bound; do not authorize a pilot until
   > those criteria pass.”

5. Reviewer records the rationale and links both source records. Only the
   reviewed resolution is proposed for shared `main`; the two rejected
   statements remain attributable as rejected candidates if the eventual schema
   supports that lifecycle.

**Simulated after-review retrieval** for “What is the pilot decision?”:

```text
Conditional next step: repeat the synthetic run with a pre-agreed larger sample and temperature acceptance bound; do not authorize a pilot until those criteria pass.
Review status: approved by human reviewer
Evidence: thermal-run-041; thermal-run-042
```

Again, this output is an expected shape, not a measured query result.

## Scenario C — duplicate and unsupported candidate

Both branches independently add a source with the same stable key
`thermal-run-041`. Alpha cites the original synthetic profile-A run. Beta
submits a second record under that key but changes the method description and
omits the sample-size detail.

**Simulated reviewer action:** reject the ambiguous duplicate, preserve the
already accepted source record, ask Beta to correct the provenance or use a
distinct source key, then re-run branch diff and merge preview. If an operation
returns an ambiguous outcome, inspect branch list/snapshot first; do not repeat
the write blindly.

**Expected retrieval:** before approval, `main` still yields its original
`thermal-run-041`; branch-only candidate content is not returned from `main`.
After rejection, the unsupported version is not exposed as accepted shared
truth. These are test expectations, not observed engine behavior.

## Evidence to collect if the blockers are resolved

- The exact base commit and schema version captured before either agent starts.
- Independent agent identities and separate branch/session identifiers.
- Branch-specific query output and commit IDs before merge.
- Raw diff and merge-preview output, including conflict details.
- Reviewer identity, decision, rationale, and exact approved candidate.
- Main snapshot/query before and after every write/merge attempt.
- Failure responses and proof that a rejected or conflicted operation did not
  move main.
- For concurrent calls: synchronized start marker, independent authenticated
  client/session IDs, request and operation IDs, response ordering, and each
  branch/graph commit before and after the race.
- For a dropped response: transport fault point, durable commit lookup, and
  evidence that no blind replay duplicated the operation.

## Additional required scenarios — simulated test designs

The following cases extend the original sketches to cover missing conflict
and concurrency dimensions. They are proposed cases, not additional measured
results. The current `Source`/`Claim`/`Supports` fixture cannot express all of
them; use a disposable schema with the needed entity and edge properties.

### Scenario D — different properties on the same entity

Start two sibling branches from one baseline `Finding`. Alpha changes its
`confidence`; Beta changes its `status`; neither changes the other's field.
Capture complete entity rows and run a merge dry-run. The implementation's
three-way classifier compares a logical entity row, so the test must establish
whether these distinct property edits produce `divergent_update`; it must not
assume property-wise merging. On any conflict, verify that `main` remains at
the recorded baseline and preserve both branch values for human resolution.

### Scenario E — conflicting updates to one relationship

Use a proposed test schema with a stable edge identity and a mutable edge
property, such as a keyed `Supports` relationship with a `note`. Alpha and Beta
change the same relationship's `note` to incompatible synthetic values from
the same base. Verify the merge result names the edge type and key, and that a
dry-run or refused merge leaves the target unchanged. This requires validating
the proposed edge-key schema before execution; it is not represented by the
current fixture, whose `Supports` edge has no properties or key.

### Scenario F — relationship addition versus endpoint deletion

From the same base, Alpha deletes a synthetic source node while Beta adds a
relationship that uses that source. Preview the merge and inspect the graph
head. The acceptance criterion is an explicit `orphan_edge` refusal with no
partial publication. This tests an add/delete interaction at the graph
constraint boundary; it does not by itself model two requests executing at
the same wall-clock instant.

### Scenario G — concurrent client requests and response loss

After branches and the server are qualified, launch two independent MCP host
sessions behind a synchronization barrier. First submit writes to their
separate task branches and verify isolation. In a separate run, submit
incompatible updates to the same branch/entity and record whether the server
serializes or explicitly refuses one. A refusal or unknown outcome must be
reconciled from snapshots and operation receipts before retry. Add a controlled
response-drop run to verify that a committed write is discovered without
blindly replaying it. Protocol clients count as client-concurrency evidence;
only two independently operating AI sessions count as a multi-agent result.

Use the expanded [collaboration test matrix](./TEST_RESULTS.md) for pass
criteria. No result in this simulation can substitute for those artifacts.
