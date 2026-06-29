# Build gotchas (Parts 1 and 2)

The things that cost real time. Detail and screenshots are in the article.

## Sysmon / endpoint
- **Pick the field the vendor actually fills.** AnyDesk ships `OriginalFileName` BLANK, so an OriginalFileName rule never matches it; its `Company` is populated and survives a rename. Check the real binary: `(Get-Item x).VersionInfo`.
- **sysmon-modular Event ID 1 is include-based.** A process from a trusted path (notepad in System32) logs NO Event ID 1 by design. Test with something actually on the include list.
- **Force telemetry on demand:** Event ID 3 (network) - make any outbound connection from the process; Event ID 6 (driver load) - mount a VHD with `diskpart` to make the kernel load `vhdmp.sys`.

## Wazuh / manager
- **Chain off the GROUP, not a rule id:** `<if_group>sysmon_event1</if_group>`, not `<if_sid>61603</if_sid>` (the base rule ships under more than one id; the group is version-proof).
- **`wazuh-logtest` lies about group rules.** A pasted event decodes with the generic `json` decoder, not `windows_eventchannel`, so the group never forms and the rule looks dead. Validate group-chained rules LIVE.
- **There is no `wazuh-logtest -t`.** Validation = the manager restarts clean; a bad rule file makes `systemctl restart wazuh-manager` fail.
- **Mute a false positive with a level-0 child rule** (`if_sid <noisy>` + a tight `field` + `level="0"`). It makes no alert, so you cannot confirm it by grepping alerts; confirm by the noisy rule's timestamp going flat and `rule: null` in the archive.
- **`different_field` only works when both events fill the same field.** AnyDesk fills Company, ScreenConnect fills OriginalFileName - mixed anchors will not compare.

## Reproducing the causal test
- **A running RMM hands off** instead of spawning a fresh process. Spawn a fresh COPY from a no-space path; it emits its Event ID 1 at creation regardless of handoff or crash.
- **Integrity levels:** a user launch is Medium/High; a service launch is SYSTEM. A second RMM at SYSTEM means a service deployed it, not a person. `PsExec -s` runs the spawn as SYSTEM in the lab.
- **A real `.exe` in Temp trips rule 92213** ("executable dropped in malware-common folder"). Installers and these test copies will fire it - benign here, but keep that rule; attackers stage from Temp. Do not broadly mute it.
