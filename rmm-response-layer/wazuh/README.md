# Wazuh Response-Layer Rules

These files are current source records for the validated lab rules. They contain active rule IDs; they are not placeholders and must not be deployed without collision review and a manager configuration test.

| File | Rule IDs | Validation boundary |
|---|---|---|
| `100210-rmm-identify.xml` | `100210` | PE Company metadata identifies supported RMM vendors; validated with renamed and genuine binaries |
| `100211-rmm-multiplicity.xml` | `100211` | distinct vendor values on the same host inside 600 seconds; genuine AnyDesk and TeamViewer sequence retained |
| `100212-rmm-causal-spawn.xml` | `100212-100214` | `100212` and `100214` fired on controlled fixtures; `100213` is deployed without a retained fire; genuine Gate 7 causal firing was not proved |
| `100215-100216-service-persistence.xml` | `100215-100216` | service command line references a monitored non-standard path; LocalSystem strengthens the signal |
| `100220-100221-masquerade.xml` | `100220-100221` | off-path `svchost.exe`; non-Microsoft PE Company strengthens the signal |

The service-persistence source matches its retained SIEM01 hash. The masquerade source is the later 2026-09-12 correction, validated against off-path and genuine System32 controls. Recheck the current manager file before deployment:

- `100215-100216-service-persistence.xml`: `6DDA6D1A0E67024A21EC65E90995A355B7E66B1FF2CB36A9C634C8D1BA72B36D`
- `100220-100221-masquerade.xml`: `5BD6290354503FC8E5C1CEA823AA5F169F98F9C4B8156996A60FE446C40AE950`

## Interpretation limits

- Rule `100211` proves distinct vendor metadata on one host in the configured window. The completing alert does not reproduce the full earlier event.
- Rules `100212-100214` infer parent identity from `ParentImage`. Renaming can produce both false positives and false negatives; Velociraptor signer and lineage collection supplies the stronger evidence.
- Rule `100215` observes the complete service command line referencing a monitored path. It does not prove file writability, signer identity, tunnel behavior, or malicious intent.
- Rule `100220` observes an off-path filename. Rule `100221` adds a non-Microsoft PE Company value. A missing Company value does not become a non-Microsoft claim.
- Wazuh composite state is memory-bound and manager restart clears it.
- No Wazuh rule in this directory grants containment authority.

## Deployment checks

1. Confirm the IDs do not collide with local rules.
2. Copy one vertical slice at a time and run `wazuh-analysisd -t`.
3. Restart only after the configuration check succeeds.
4. Validate with live EventChannel evidence and a matched negative control.
5. Retain the source event, archive record, alert, rule hash, and cleanup proof.
