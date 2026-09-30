# Response Playbook

> Status: Gate 6 workflow lab-validated. All actions remain manually invoked; automatic containment is disabled.

## Objective

Preserve evidence before a bounded response and prevent severity or score from becoming accidental authorization.

```text
detect -> score -> confirm -> collect -> approve -> isolate -> verify -> reverse -> recover
```

## Tool ownership

| Phase | Owner | Validated action |
|---|---|---|
| Detect | Wazuh on SIEM01 | Produce endpoint identity, correlation, persistence, and masquerade alerts |
| Score | core Splunk Enterprise on SIEM02 | Project risk onto a canonical host, deduplicate, expire, tier, and apply asset caps |
| Confirm | Velociraptor on SIEM01 | Return signer, file hash, file stat, and process lineage evidence |
| Gate | Velociraptor server artifact | Require exact asset identity, evidence, score, approval, console, snapshot, and replay state |
| Isolate and reverse | Velociraptor client wrapper | Apply or remove Windows quarantine while retaining the shared RunId |

## Analyst sequence

1. Confirm the Wazuh source events and canonical host.
2. Run the unscheduled Splunk score and timeline searches.
3. Run `Custom.RMM.Gate4Enrich` and wait for a successful completed flow.
4. Verify the expected hashes and explicit signer states.
5. Confirm the target is the exact containment-eligible WS02 identity.
6. Confirm interactive console access and a usable snapshot.
7. Record operator approval.
8. Submit one guarded Apply.
9. Verify peer isolation and a fresh Velociraptor collection through the retained control channel.
10. Submit guarded Remove.
11. Prove network, telemetry, service, identity, and domain recovery.
12. Remove fixtures and retain the ordered timeline.

## Asset gate

| Asset | Maximum authority in this package |
|---|---|
| WS02 | one manually guarded Apply for a declared run, followed by reversal |
| WS01 | collect; no validated containment authority |
| DC01 | collect; the target guard denies containment |
| SRV01 | collect; no validated containment authority |
| SIEM01 | alert only; detection and response control plane |
| SIEM02 | alert only; risk decision control plane |
| Unknown asset | alert only and fail closed |

## Gate 6 proof

For `RUN-20260902-G6P1`, evidence completed before Apply. Apply flow `F.DAC59Q7VIAPFA` ran once. An identical replay returned DENY with `PriorApplyCount=1` and launched no second client flow. Control-survival collection `F.DAC5AT0ANHBSE` completed with 28 rows while peer SSH was blocked. Remove flow `F.DAC5B8D8U8PKC` reversed the policy. Health and connectivity recovered and both fixtures were removed.

This validates sequential duplicate suppression. It does not prove race-safe suppression for simultaneous requests.

## Incident handoff fields

- canonical risk object and asset class;
- score, tier, expiry, and contributing families;
- Wazuh rule and event identifiers;
- Splunk search output and deduplication keys;
- Velociraptor client, collection, signer, hash, and lineage results;
- requested, approved, completed, denied, and reversed actions;
- recovery checks, cleanup state, and residual risk.
