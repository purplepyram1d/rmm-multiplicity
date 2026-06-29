# rmm-multiplicity

This repository contains the rules, configurations, scripts, screenshots, and test data for detecting RMM (Remote Monitoring and Management) tool multiplicity on the same host using Sysmon and Wazuh in the homelab environment.

## Purpose
The project implements detection for when multiple distinct RMM vendors are active on a single Windows endpoint. This is based on Sysmon Event ID 1 process creation events, using embedded PE metadata like Company name or OriginalFileName to identify RMM tools in a rename-resistant way. Wazuh rules then correlate these events for multiplicity alerts.

See the associated writeup for full context on the RMM abuse detection use case.

## Contents

### wazuh/
Wazuh rules (deployed to /var/ossec/etc/rules/ on SIEM01).

- wazuhrule-100210.xml: Base rule (level 3) to identify RMM processes by Company field in Sysmon EID1 events. Matches known vendors like AnyDesk, TeamViewer, etc.
- wazuhrule-100250.xml: Tuning rule (level 0) to suppress false positives from benign PowerShell execution policy probe files (__PSScriptPolicyTest).
- wazuhrule-200211.xml: Multiplicity rule (level 12) that correlates 2+ matches of 100210 on the same computer with different Company values within 600 seconds.

### sysmon/
Sysmon configuration rules (for inclusion in modular config on Windows endpoints).

- sysmoneid3rule-Company-AnyDesk.xml: EID3 network connect rule including AnyDesk by Company.
- sysmoneid3rule-ImageName.xml: EID3 rule for RMM image names.
- sysmoneid3rule-OriginalFileName.xml: EID3 rule for ScreenConnect by OriginalFileName (used because Company field was empty for that tool).

### scripts/
Diagnostic scripts for collecting data from lab hosts.

- dc01-diag.ps1: PowerShell diagnostic for DC01 side (Wazuh agent status, Sysmon service, ossec.conf localfile for Sysmon channel, recent EID1 events, connectivity to manager).
- siem-diag.sh: Bash diagnostic for SIEM01 (Wazuh services, listeners, enrolled agents, archives/alerts files, custom rules, recent DC01 events in archive via jq, decoder field checks, firewall, disk, memory, indexer heap).

### screenshots/
Visual evidence from the build and testing process.

- RMM01-Version-Detection.png: Sysmon version or basic detection.
- RMM02-Wazuh-Dashboard.png: Wazuh dashboard view.
- RMM03-PowerShell-Critical-Fixed.png: Tuned false positive for PowerShell.
- RMM04-RMM-Base-Rule*.png: Base rule (100210) firing for RMM tools.
- RMM05-RMM-Multiplicity*.png: Multiplicity rule (100211) firing when multiple vendors detected.

### json/
Test data and alert exports.

- rmm-multiplicity-test-1.json: Sample Wazuh alert JSON from a multiplicity event (includes full win.eventdata for Company, image, computer, etc.).

## How It Fits Together
- Sysmon on DC01 (Windows) captures process creates and network connects for RMM tools.
- Wazuh agent on DC01 forwards events.
- Wazuh on SIEM01 applies the rules: 100210 tags individual RMM launches, 100211 correlates for multiplicity.
- Diagnostics help verify the pipeline (agent subscription, event flow, field extraction).

## Notes
- Rules use win.eventdata.company for matching (from Sysmon EID1).
- Multiplicity uses same_field for computer and different_field for company.
- All materials are read-only diagnostics where possible; user performs installs/configs.
- See homelab writeup for full details on testing (launch AnyDesk then TeamViewer within timeframe to trigger 100211).

This repo is part of the homelab for detection engineering practice targeting MSP/SOC scenarios.
