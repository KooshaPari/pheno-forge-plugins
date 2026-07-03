# PR 3: pheno-cdylib-bridge (out of scope here)

Issue #2 tracks PR 3 of the ADR-096 forgecode improvement sequence. It is
**not implementable in this repo** and is not a defect in the PR 1 plugin
bundle. This file exists only so the cross-link is preserved when this repo
is reviewed.

## Why it is not in this repo

- `AGENTS.md` (PR 1 acceptance scope) lists PR 3 under "Out of scope (deferred)"
  and points at a separate repo and spec:
  - Repo: `KooshaPari/pheno-cdylib-bridge`
  - Spec: `thegent/docs/specs/cdylib-bridge/v1.md`
- The repo contains zero Rust source files; `Cargo.toml` is a no-Rust
  workspace marker only. The crates PR 3 would bridge
  (`thegent-memory`, `pheno-port-adapter`, `pheno-flags`, `pheno-errors`)
  do not exist in any accessible location as of 2026-06-23.
- PR 3 is explicitly blocked on PR 2 (issue #1, still open), whose
  `thegent-memory` cdylib output the bridge consumes.

## Action

Issue #2 should be closed as `not planned` against this repo and re-filed
in `KooshaPari/pheno-cdylib-bridge` once:

1. PR 2 (`thegent-memory` v2) lands.
2. The spec at `thegent/docs/specs/cdylib-bridge/v1.md` is published
   (currently 404).
3. The four additional crates (`pheno-config` binding, `pheno-port-adapter`,
   `pheno-flags`, `pheno-errors`) have reachable source.
