# lab-techniques

Small reproduction helpers and build notes from the validated [Part 2 writeup](https://purplepyram1d.github.io/blog/posts/one-rmm-is-it-two-is-an-incident.html). Run the `.ps1` scripts on the Windows endpoint, elevated; adjust the RMM install paths at the top of each. They make each Wazuh rule fire on demand so you can inspect the underlying event and alert.

- `trigger-rmm-eid1.ps1` - normal and renamed AnyDesk launches for rule 100210.
- `test-multiplicity.ps1` - positive distinct-vendor mode and a one-vendor negative-control mode for rule 100211.
- `test-causal-spawn.ps1` - one RMM-named parent launches another vendor; add `-AsSystem` for 100214, collect with Velociraptor, then rerun with `-Cleanup`.
- `GOTCHAS.md` - the things that cost time, kept short.

The current helpers use `C:\Lab` rather than `C:\Windows\Temp`. Wazuh can select a higher-level built-in rule for a Temp-staged executable, which hides rule `100210` and breaks downstream correlation. Treat the helpers as lab code and review their parameters before every run.
