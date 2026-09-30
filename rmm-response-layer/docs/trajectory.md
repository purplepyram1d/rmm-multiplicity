# Detection Trajectory

> Status: validated architecture with an explicit Gate 7 claim boundary.

The project tracks the shrinking distance between suspicious activity and legitimate administration:

```text
filename -> metadata -> correlation -> lineage -> risk-scored deviation -> guarded response
```

## Filename to metadata

A binary can be renamed without changing its PE `Company` value or signing certificate. The lab identified renamed and genuine RMM binaries from metadata. Metadata is stronger than a filename, but vendors populate different fields and a stolen valid certificate can remain valid.

## Metadata to correlation

Wazuh rule `100211` asks whether two distinct vendor values occurred on the same host inside 600 seconds. It stays quiet when one vendor produces several helper processes. Gate 7 retained a genuine AnyDesk-to-TeamViewer sequence on WS02 with 111.396 seconds between the first alerts.

Correlation still has an evidence ceiling: one incident can produce several composite alerts, the completing alert does not display the earlier event, rule precedence can hide a required base match, and manager restart clears the in-memory state.

## Correlation to lineage

Rules `100212-100214` add parent-path and integrity conditions. The lab proved that parent path is fallible in both directions: a renamed unrelated executable can impersonate an RMM parent, while a renamed genuine parent can evade the path expression. `100212` and `100214` fired on controlled fixtures; `100213` is deployed without a retained fire. Gate 7 did not prove a genuine direct-parent chain.

Velociraptor adds on-disk Authenticode, hash, and process lineage evidence before cleanup. Signer evidence must be collected while the file still exists.

## Lineage to host risk

Parallel launches and indirect deploy methods such as PowerShell, services, WMI, and scheduled tasks break simple immediate-parent assumptions. Core Splunk Enterprise therefore projects time-bounded contributions onto a canonical host, deduplicates helpers, keeps the maximum contribution per family, applies expiry, and caps action by asset policy.

This is RBA-inspired host-risk aggregation on core Splunk Enterprise 10.4.0. Enterprise Security is absent, so native ES RBA is not claimed.

## Host risk to guarded response

Gate 6 joined masquerade and service-persistence families to an exact score of 70 for WS02. A read-only evidence flow completed first. The server guard then permitted one operator-approved Apply, denied the identical replay before a second client flow, preserved the Velociraptor control channel during isolation, and permitted reversal. The lab recovered and removed the fixtures. Automatic containment remained disabled.

## Honest claim

The build demonstrates bounded detection, host-risk projection, evidence-before-action, protected-host denial, one reversible workstation containment, and genuine same-host distinct-vendor multiplicity. It does not establish fleet-scale scoring quality, a WS01 origin for the genuine sequence, direct AnyDesk-to-TeamViewer parentage, or a genuine `100212-100214` chain.
