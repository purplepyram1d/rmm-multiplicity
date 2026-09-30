# Validation Status and Claim Boundary

## Supported claims

- Wazuh detects distinct RMM vendor metadata on one Windows endpoint and correlates different vendors inside 600 seconds.
- A genuine WS02 run produced AnyDesk identity followed by TeamViewer multiplicity in 111.396 seconds.
- Current valid Authenticode signatures match the SHA-256 values in the event-time Sysmon records for the retained binaries.
- Core Splunk Enterprise can implement an RBA-inspired host-risk projection with deterministic evidence identity, deduplication, family maximum, expiry, tiers, and asset caps.
- Velociraptor can confirm signer and lineage data, collect evidence, and enforce a manually gated reversible response.
- The DC01 target test returned DENY and did not launch an endpoint action.

## Unsupported claims

- Wazuh correlated a WS01 origin to the WS02 process sequence.
- AnyDesk directly launched TeamViewer in the genuine run.
- A genuine cross-vendor process chain fired `100212` through `100214`.
- This is native Splunk Enterprise Security RBA.
- Automatic or fleet-scale containment is validated.

## Review order

1. Review the source files for guards, disabled schedules, and explicit failure states.
2. Review `gate6-run-contract.md` against the guarded response code.
3. Keep the Gate 7 article and detailed evidence bundle in local review until their separate publication check is complete.
