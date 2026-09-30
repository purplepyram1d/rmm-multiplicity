# RMM Multiplicity Detection (Sysmon + Wazuh + Velociraptor)

A homelab detection project for abuse of legitimate remote monitoring and management software. One sanctioned RMM product can be normal administration. A second vendor on the same host, especially when one launches the other under SYSTEM, is a materially different condition.

## Writeups

- [Part 1: One RMM Is IT. Two Is An Incident.](https://medium.com/@johnnymeintel/one-rmm-is-it-two-is-an-incident-1-2-2411904f6ff0)
- [Part 2: One RMM Is IT. Two Is An Incident.](https://purplepyram1d.github.io/blog/posts/one-rmm-is-it-two-is-an-incident.html)

The Gate 7 companion writeup is still in progress. The response-layer validation boundaries are recorded in [`rmm-response-layer/docs/validation-status.md`](rmm-response-layer/docs/validation-status.md).

## Validated detection chain

1. **Identify:** Sysmon Event ID 1 exposes PE metadata. Wazuh rule `100210` identifies known RMM vendors from `Company`, which survives a filesystem rename.
2. **Correlate:** rule `100211` detects two distinct vendor values on the same host inside 600 seconds.
3. **Attribute cause:** rules `100212` and `100213` infer a cross-vendor parent-child relationship from the parent path. `100212` fired on a controlled fixture. The reverse-direction `100213` is deployed, but no fire was retained.
4. **Escalate:** rule `100214` raises the causal condition when the child runs at SYSTEM integrity. It fired on a controlled fixture, not the genuine Gate 7 sequence.
5. **Confirm lineage:** Velociraptor walks the process tracker call chain and checks Authenticode identity for each executable.

## What the tests proved

- Renaming AnyDesk does not defeat the `Company` anchor.
- Multiple processes from one TeamViewer launch do not satisfy distinct-vendor correlation.
- One multiplicity incident can produce several alerts because the composite rule re-evaluates for each qualifying process event.
- Wazuh's composite alert describes the event that completed the correlation; it does not carry the first vendor forward.
- A path-based parent rule can be fooled by renamed `cmd.exe` and can miss a genuine RMM parent that was renamed.
- Velociraptor certificate verification exposes that mismatch, but it must run before cleanup removes the binary.
- Parallel Level and ScreenConnect launches satisfy multiplicity while causal rules stay quiet because PowerShell is the common parent.
- A higher-level built-in Wazuh rule can win the one-alert-per-event decision and prevent a lower-level base rule, and therefore its downstream correlation, from appearing.

## Repository layout

- `sysmon/` - Sysmon filters that expose RMM process and network evidence.
- `wazuh/` - Wazuh identification, multiplicity, causal, SYSTEM, and tuning rules.
- `scripts/` - endpoint and manager diagnostics used to verify the pipeline.
- `evidence/` - retained alerts and screenshots.
- `lab-techniques/` - bounded reproduction helpers and build gotchas.
- `rmm-response-layer/` - validated response-layer source and claim boundaries for persistence detection, host-risk scoring, lineage confirmation, and manually gated response.

## Response layer

The response layer connects detection to risk-scored review and a guarded manual action:

```text
Wazuh detects -> Splunk on SIEM02 decides -> Velociraptor confirms and contains
```

Gates 1 through 6 were validated in the lab. Gate 7 produced genuine signed AnyDesk and TeamViewer activity on WS02 and confirmed same-host distinct-vendor multiplicity. It did not establish a WS01 origin, direct AnyDesk-to-TeamViewer parentage, or a genuine causal-rule chain. Automatic containment remains disabled. The Gate 7 article and detailed evidence package are pending publication.

## Honest limits

- Vendor metadata still depends on a maintained coverage list.
- A valid but stolen certificate, fileless execution, or an unsigned legitimate vendor can defeat an identity layer.
- Multiplicity is blind when an attacker abuses the already-sanctioned tool and deploys nothing new.
- Risk scoring in a single-host homelab demonstrates the decision model, not fleet-scale efficacy.
- Containment is a denial-of-service capability and must be capped by asset criticality and an explicit approval gate.

## License

MIT
