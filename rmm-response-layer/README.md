# RMM Response Layer

> Status: lab-validated response-layer source. Automatic containment is disabled. The Gate 7 companion article and detailed evidence package remain unpublished.

This directory contains the response layer built after the RMM identity and distinct-vendor multiplicity detections. Wazuh detects endpoint behavior, core Splunk Enterprise holds an explainable host-risk projection, and Velociraptor confirms evidence and enforces the manually gated response policy.

## Validated result

| Gate | Result |
|---:|---|
| 1 | Wazuh `100212` delivered a bounded local active response with success and failure controls |
| 2 | Persistence and masquerade findings passed positive, negative, cleanup, and health checks |
| 3 | Core Splunk host-risk projection passed replay, helper deduplication, family maximum, expiry, tier, and asset-cap checks |
| 4 | Velociraptor returned explicit signer and lineage states before cleanup |
| 5 | Manual guarded quarantine, control survival, reversal, recovery, kill switch, and protected-host negatives passed |
| 6 | Evidence completed before one controlled Apply; duplicate Apply was denied; the full response timeline was retained |
| 7 | Genuine signed AnyDesk and TeamViewer binaries produced same-host `100211` multiplicity on WS02; DC01 failed closed; publication evidence was prepared |

The genuine Gate 7 sequence validates **same-host distinct-vendor multiplicity**. It does not prove that WS01 caused the launches, that AnyDesk directly parented TeamViewer, or that a genuine chain fired `100212` through `100214`. Rules `100212` and `100214` fired on controlled fixtures. The reverse-direction `100213` is deployed, but no fire was retained.

## Product mode

SIEM02 runs core Splunk Enterprise 10.4.0 without Enterprise Security. The implementation is **RBA-inspired host-risk aggregation on core Splunk Enterprise**. It is not native Enterprise Security Risk-Based Alerting.

## Architecture

```text
WS02 Sysmon
  -> Wazuh on SIEM01: identity, multiplicity, persistence, causal candidates
  -> core Splunk on SIEM02: canonical per-host risk projection and analyst decision
  -> Velociraptor on SIEM01: signer/lineage confirmation, evidence, guarded action
```

Severity does not grant response authority. Evidence readiness, exact asset identity, score, operator approval, console confirmation, snapshot confirmation, kill-switch state, and replay state are separate guards.

## Directory map

- `detonation/`: the bounded Gate 6 controlled-positive and cleanup sources used during validation.
- `gate1/`: the active-response wrapper, script, and manager configuration reference.
- `gate2/`: inert masquerade fixture source for local compilation.
- `gate5/`: stopped-service reversal exercise source.
- `wazuh/`: deployed or live-matched rules for identity, multiplicity, causal candidates, service persistence, and masquerade. See the rule-level validation boundary.
- `splunk/model/`: validated search logic for projection, health, timeline, deduplication, and the Gate 6 score.
- `splunk/app/`: manual, unscheduled core-Splunk saved searches and asset policy.
- `velociraptor/`: validated read-only enrichment and manually guarded response artifacts.
- `docs/`: scoring, response, run-contract, and claim-boundary documentation.
- The detailed Gate 7 evidence bundle and companion article remain in local review and are not part of this update.

## Safety boundary

- The response path is manually invoked and automatic containment remains disabled.
- DC01, SRV01, SIEM01, SIEM02, and non-ready assets are outside containment authority.
- Collection precedes containment.
- Duplicate Apply requests fail closed.
- Reversal and control-channel survival are validation requirements.
- No endpoint protection exclusion was added to force the Gate 7 causal result.
- No raw credentials, tokens, or vendor-account identifiers belong in this repository.

## Review entry points

1. Read `docs/validation-status.md` for the supported and unsupported claims.
2. Review `docs/gate6-run-contract.md` for the exact controlled response sequence.
3. Review the source guards and disabled Splunk schedules before use.

## Publication state

This source release covers the validated response implementation and its limits. The Gate 7 case writeup and retained evidence bundle will be reviewed separately.
