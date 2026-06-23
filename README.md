# pheno-forge-plugins

Sidecar bundle for `antinomyhq/forgecode` — 6 plugins that bring up a local-first memory + config + tracing stack at machine boot, not session boot. No code is injected into forgecode; everything ships as standard forgecode plugins + systemd units.

**This is PR 1 of 3** in the forgecode improvement sequence (ADR-096). PR 2 (`thegent-memory` polyglot facade) and PR 3 (`pheno-cdylib-bridge`) come after.

## Stack

| Plugin | Spawns | Port | Role |
|---|---|---|---|
| `pheno-supermemory` | supermemory binary | `:3030` | Primary memory + smfs filesystem |
| `pheno-letta` | letta server | `:8283` | Subconscious memory blocks (per-identity) |
| `pheno-cognee` | cognee-mcp | stdio | Project knowledge graph |
| `pheno-mem0` | mem0 server | `:8000` | Fallback memory |
| `pheno-config` | Configra daemon | `:9100` | Config substrate (ADR-022/031) |
| `pheno-tracing` | otel-collector-contrib | `:4317/:4318` | OTLP trace ingest |

All six are brought up together by the `pheno-forge-sidecars.target` systemd unit (Linux) or the `scripts/launch-sidecars.sh` launchd wrapper (macOS).

## Install

```bash
# 1. Fetch the tarball (or build it locally with scripts/build-tarball.sh)
curl -fsSL -o /tmp/pheno-forge-plugins-v0.1.0.tar.gz \
  https://github.com/KooshaPari/pheno-forge-plugins/releases/download/v0.1.0/pheno-forge-plugins-v0.1.0.tar.gz

# 2. Install via forgecode's plugin system
forge plugin install --from-tarball /tmp/pheno-forge-plugins-v0.1.0.tar.gz

# 3. Bring up the sidecar stack (Linux)
sudo systemctl enable --now pheno-forge-sidecars.target

# 3-alt. Or on macOS (launchd fallback)
sudo ./scripts/launch-sidecars.sh

# 4. Verify
forge plugin list
forge plugin info pheno-supermemory
systemctl status pheno-forge-sidecars.target   # Linux
```

## What each plugin ships

```
plugins/<name>/
├── plugin.toml            # forgecode v0 plugin descriptor
├── SKILL.md               # capability manifest (loaded by forge on enable)
├── plugin.env             # plugin-specific env vars (binary path, port, store dir)
├── systemd/<name>.service # per-plugin systemd unit
├── bin/                   # pre-built sidecar binary (architecture-tagged, LFS-tracked per ADR-027)
└── README.md              # install / configure / verify steps
```

The generic `scripts/{spawn,teardown,healthcheck}.sh` are invoked by each plugin's `plugin.toml`; they source the plugin's `plugin.env` for the per-plugin values.

## Why this exists

Per ADR-096, `antinomyhq/forgecode` is the fleet's agent CLI. We improve it in place. This bundle is the memory + config + tracing substrate that forgecode sessions connect to. See `findings/2026-06-23-forgecode-improvement-plan.md` for the 3-PR sequence and `thegent/docs/specs/memory/v2.md` for the Rust API (PR 2).

## License

Dual-licensed under MIT or Apache-2.0, at your option. See `LICENSE-MIT` and `LICENSE-APACHE`.
