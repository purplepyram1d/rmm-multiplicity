# lab-techniques

Small reproduction helpers and build notes from the article (Parts 1 and 2). Run the `.ps1` scripts on the Windows endpoint, elevated; adjust the RMM install paths at the top of each. They make each Wazuh rule fire on demand so you can see it (and screenshot it).

- `trigger-rmm-eid1.ps1` - one RMM launch, fires rule 100210 (plus a rename-proof demo).
- `test-multiplicity.ps1` - two different vendors, fires rule 100211 (plus the negative test).
- `test-causal-spawn.ps1` - one RMM launches another, fires rule 100212; add `-AsSystem` for 100214.
- `GOTCHAS.md` - the things that cost time, kept short.
