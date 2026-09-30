# Scoring Rationale

> Status: Gate 3 model validated on core Splunk Enterprise; Gate 6 exercised one declared score transition.

## Risk object and state

The canonical lowercase host is the risk object. Hostname, FQDN, and case variants normalize to one object. Each contribution preserves its signal family, signal ID, deduplication key, event time, expiry, evidence identity, and RunId when present.

The model rejects malformed contributions, ignores expired state, records late arrival, deduplicates repeated helper activity, and uses the maximum active score inside each signal family before summing families.

## Validated tiers

| Score | Tier |
|---:|---|
| `0-19` | observe |
| `20-39` | enrich |
| `40-69` | collect |
| `70+` | contain-eligible |

Contain-eligible is a score label, not action authority. Asset policy and the response guard remain separate.

## Gate 6 declared model

| Family | Signal | Points |
|---|---|---:|
| Masquerade | `wazuh:100221` | 45 |
| Service persistence | `wazuh:100216` | 25 |
| Effective score | family maximum, two families | 70 |

The authenticated SIEM02 result returned `ws02`, both families, score 70, tier `contain-eligible`, manual Gate 6 authority, automatic containment disabled, and `PASS`.

## Asset caps

The lookup keeps WS02 as the only response test target. WS01, DC01, SRV01, SIEM01, SIEM02, and unknown assets remain capped below containment in the general host-risk report. The exact WS02 client and hostname pair must still pass the server-side guard before an action flow can start.

## Safety boundary

A score is a decision input. The Gate 6 Apply additionally required the declared RunId, exact asset identity, completed evidence flow, expected evidence hashes, approval string, interactive console confirmation, snapshot confirmation, and no prior Apply for the same run. The duplicate replay and DC01 target both failed closed.

## Limits

A single-host lab can validate event production, deterministic replay handling, expiry, threshold crossing, and action gating. It cannot establish population baselines or fleet-scale false-positive rates.
