# RMM Multiplicity Detection

This homelab project detects when two different remote management tools appear on the same Windows computer. It started with Sysmon and Wazuh alerts and grew into a tested response workflow using Splunk and Velociraptor.

[Read the walkthrough on purplepyram1d](https://purplepyram1d.github.io/blog/posts/one-rmm-is-it-two-is-an-incident.html).

## In this repository

- `sysmon/` and `wazuh/` contain the detection rules.
- `lab-techniques/` and `scripts/` contain test and diagnostic helpers.
- `evidence/` contains evidence from the original detection work.
- `rmm-response-layer/` contains the response-layer source and a [summary of what the lab proved](rmm-response-layer/docs/validation-status.md).

The response work is validated through Gate 6. A Gate 7 test confirmed that genuine AnyDesk and TeamViewer activity on WS02 triggered the same-host alert. The Gate 7 writeup and detailed evidence package are still in progress. Automatic containment is disabled.

## License

MIT
