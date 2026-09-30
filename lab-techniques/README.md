# Lab techniques

These PowerShell helpers recreate the detection tests from the [purplepyram1d walkthrough](https://purplepyram1d.github.io/blog/posts/one-rmm-is-it-two-is-an-incident.html). Run them on a Windows test endpoint after reviewing their paths and parameters.

- `trigger-rmm-eid1.ps1` tests identification, including a renamed binary.
- `test-multiplicity.ps1` tests two vendors and a one-vendor negative control.
- `test-causal-spawn.ps1` tests the parent-path rule with a controlled fixture.
- `GOTCHAS.md` records the build lessons and test limits.

These are lab reproduction helpers, not evidence of a genuine RMM-to-RMM parent chain.
