# Wazuh rules

These rules identify RMM tools, correlate two vendors on one host, and flag selected service and masquerade behavior. The files are source records for the lab. Check for rule-ID collisions and run the Wazuh configuration test before deploying them.

- `100210` and `100211` identify tools and detect same-host multiplicity.
- `100212` through `100214` are parent-path candidates. `100212` and `100214` fired on controlled fixtures; `100213` has no retained fire. No genuine Gate 7 causal chain was proved.
- `100215` and `100216` cover service registration.
- `100220` and `100221` cover off-path `svchost.exe` behavior. This source includes the September 2026 correction that keeps genuine System32 activity out of the RMM masquerade signal.

The [validation summary](../docs/validation-status.md) states the supported claims and limits. None of these rules grants containment authority.
