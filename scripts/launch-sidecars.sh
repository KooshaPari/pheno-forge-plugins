#!/usr/bin/env bash
# macOS launchd fallback. Launches all 6 sidecars as background processes when
# systemd is not available. Mirrors the systemd pheno-forge-sidecars.target.
#
# Usage:
#   sudo ./scripts/launch-sidecars.sh {start|stop|status}
#
# Per the locked decision (ADR-096): per-machine, not per-session. This script
# can be run at login via launchd, or manually with `sudo ./scripts/launch-sidecars.sh start`.

set -euo pipefail

ACTION="${1:-status}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PLUGINS=("pheno-supermemory" "pheno-letta" "pheno-cognee" "pheno-mem0" "pheno-config" "pheno-tracing")

case "$ACTION" in
  start)
    for p in "${PLUGINS[@]}"; do
      echo "launch-sidecars: starting $p"
      PHENO_PLUGIN_DIR="$REPO_ROOT/plugins/$p" "$SCRIPT_DIR/spawn.sh" "$p"
    done
    ;;
  stop)
    for p in "${PLUGINS[@]}"; do
      echo "launch-sidecars: stopping $p"
      PHENO_PLUGIN_DIR="$REPO_ROOT/plugins/$p" "$SCRIPT_DIR/teardown.sh" "$p"
    done
    ;;
  status)
    for p in "${PLUGINS[@]}"; do
      PHENO_PLUGIN_DIR="$REPO_ROOT/plugins/$p" "$SCRIPT_DIR/healthcheck.sh" "$p"
    done
    ;;
  *)
    echo "Usage: $0 {start|stop|status}" >&2
    exit 64
    ;;
esac
