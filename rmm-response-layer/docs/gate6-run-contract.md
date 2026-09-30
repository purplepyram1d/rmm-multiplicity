# Gate 6 Controlled Positive Run Record

> Status: executed and closed on 2026-09-02. Automatic containment remained disabled.

## Run identity

- RunId: `RUN-20260902-G6P1`
- Target: `WS02.corp.local`
- Response mode: manual and approval gated
- Automatic containment: disabled before, during, and after the run

## Controlled positive

| Family | Finding | Points | Fixture |
|---|---:|---:|---|
| Masquerade | `wazuh:100221` | 45 | inert non-Microsoft test program named `svchost.exe` under `C:\Users\Public\g6masq` |
| Service persistence | `wazuh:100216` | 25 | Cloudflare-signed binary registered once as an unstarted demand service under LocalSystem from `C:\Users\Public\g6service` |
| Effective score | family maximum | 70 | two independent retained findings |

The authenticated SIEM02 search returned score 70, tier `contain-eligible`, two contributing families, two source events, manual Gate 6 authority, automatic containment disabled, and `PASS`.

## Executed sequence

1. Baseline and service health passed.
2. Both fixtures produced the expected Wazuh findings with the shared RunId.
3. The Splunk score matched the declared 70-point model.
4. Gate 4 evidence completed and returned the expected hashes before action.
5. Johnny confirmed the interactive console, snapshot, and approval.
6. Guarded Apply launched flow `F.DAC59Q7VIAPFA`.
7. An identical Apply replay returned DENY with `PriorApplyCount=1`, no `FlowId`, and no second client action.
8. Peer SSH was blocked while control-survival collection `F.DAC5AT0ANHBSE` completed with 28 rows.
9. Guarded Remove launched flow `F.DAC5B8D8U8PKC`.
10. Network, services, telemetry, identity, and domain checks recovered.
11. The quarantine policy, fixture service, and fixture directories were absent after cleanup.

## Matched negatives and limits

- System32 `svchost.exe` did not contribute masquerade points.
- A System32 service command did not contribute service-persistence points.
- Duplicate source events did not increase the family-max score.
- The same containment request against DC01 returned DENY before endpoint action.
- The replay proof covers a sequential duplicate request. Simultaneous racing requests were not tested.
- This run proves one bounded workstation response, not fleet-scale automatic containment.

## Recovery path

The exact WS02 identity may invoke Remove without an expired Apply approval blocking reversal. The confirmed snapshot remained the fallback. Source evidence was retained; it was not deleted to make risk state appear clean.
