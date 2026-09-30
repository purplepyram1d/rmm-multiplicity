# RMM Response Layer

This is the follow-on homelab work after the original RMM detection. Wazuh finds activity, core Splunk groups risk by host, and Velociraptor gathers evidence and runs a guarded manual response.

## What is here

- `gate1/`, `gate2/`, `gate5/`, and `detonation/` contain controlled test sources.
- `wazuh/`, `splunk/`, and `velociraptor/` contain the detection, scoring, and response sources.
- `docs/` explains the scoring, response sequence, and [validation limits](docs/validation-status.md).

Gates 1 through 6 were validated in the lab. Gate 7 confirmed genuine AnyDesk and TeamViewer on WS02 triggered same-host multiplicity. It did not prove a WS01 origin or direct parent-child relationship. Its companion writeup and detailed evidence package remain unpublished. Automatic containment is disabled.

Review the guards and test each component before using it in a lab.
