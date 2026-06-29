# RMM Multiplicity Detection (Sysmon + Wazuh)

A homelab project that detects when more than one remote access tool is running on the same Windows machine. One RMM (Remote Monitoring and Management) tool is normal IT. Two different ones on the same host is a common attacker move, and that kind of RMM abuse is up about 277% according to the Huntress 2026 Cyber Threat Report.

Full write-up: **[One RMM Is IT. Two Is An Incident. (Part 1)](https://medium.com/@johnnymeintel/one-rmm-is-it-two-is-an-incident-1-2-2411904f6ff0)**

## How it works
Sysmon logs process creation on the endpoint and tags known RMM tools by their built-in vendor name (the `Company` field), which sticks even if someone renames the file. Wazuh then runs three rules:

- **100210** records when a known RMM launches.
- **100211** alerts when two *different* RMM vendors show up on the same host within 10 minutes.
- **100250** quiets a noisy false positive caused by PowerShell's own activity.

## What's in here
- `sysmon/` - the Sysmon rules that tag RMM tools.
- `wazuh/` - the three Wazuh rules above.
- `scripts/` - the diagnostics I used to confirm the pipeline was working.
- `evidence/` - screenshots of the rules firing, plus a sample alert.

The full setup and testing walkthrough is in the article.

## What's next
Right now this proves *correlation* (two tools are present), not *causation* (that one tool actually launched the other). Building that causal detection is the next step, including identifying the parent tool by its signing certificate instead of just its file name.

This reproduces and builds on published work from Elastic, Huntress, and others. It's a learning project, not a new technique.

## License
MIT
