# RMM Multiplicity Detection (Sysmon + Wazuh)

A homelab project that detects when more than one remote access tool is running on the same Windows machine. One RMM (Remote Monitoring and Management) tool is normal IT. Two different ones on the same host is a common attacker move, and that kind of RMM abuse is up about 277% according to the Huntress 2026 Cyber Threat Report.

Writeup #1: **[One RMM Is IT. Two Is An Incident. (Part 1)](https://purplepyram1d.github.io/blog/posts/one-rmm-is-it-two-is-an-incident.html)**

## What's in here
- `sysmon/` - the Sysmon rules that tag RMM tools.
- `wazuh/` - the Wazuh rules above.
- `scripts/` - the diagnostics I used to confirm the pipeline was working.
- `evidence/` - screenshots of the rules firing, plus a sample alert.
- `lab-techniques/` - small scripts to reproduce each rule firing, plus build gotchas.

## License
MIT
