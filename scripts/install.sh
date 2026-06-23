#!/usr/bin/env bash
# Convenience installer. Fetches binaries, stages plugins to ~/.forge/plugins/,
# and prints next steps. Idempotent.
#
# Usage:
#   ./scripts/install.sh
#
# Env:
#   PHENO_INSTALL_PREFIX  — default ~/.forge/plugins (forgecode's plugin dir)
#   PHENO_FETCH_BINARIES  — default "1" (set to "0" to skip binary download)

set -euo pipefail

PREFIX="${PHENO_INSTALL_PREFIX:-$HOME/.forge/plugins}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "install.sh: prefix=$PREFIX"

# 1. Fetch binaries (Tier 2 per ADR-027)
if [[ "${PHENO_FETCH_BINARIES:-1}" == "1" ]]; then
  echo "install.sh: fetching sidecar binaries..."
  "$SCRIPT_DIR/fetch-sidecars.sh"
else
  echo "install.sh: skipping binary fetch (PHENO_FETCH_BINARIES=0)"
fi

# 2. Stage plugins to ~/.forge/plugins/
mkdir -p "$PREFIX"
for plugin_dir in "$REPO_ROOT"/plugins/*/; do
  plugin_name="$(basename "$plugin_dir")"
  dest="$PREFIX/$plugin_name"
  echo "install.sh: staging $plugin_name -> $dest"
  rm -rf "$dest"
  cp -R "$plugin_dir" "$dest"
  # Make scripts executable
  find "$dest" -name '*.sh' -exec chmod +x {} \;
  find "$dest/bin" -type f -exec chmod +x {} \; 2>/dev/null || true
done

# 3. Symlink generic scripts into each plugin (so each plugin has its own copy)
for plugin_dir in "$PREFIX"/*/; do
  for script in spawn.sh teardown.sh healthcheck.sh; do
    [[ -f "$plugin_dir/$script" ]] || cp "$SCRIPT_DIR/$script" "$plugin_dir/$script"
  done
done

# 4. Symlink the systemd target to /etc/systemd/system/ if writable
if [[ -d /etc/systemd/system ]] && [[ -w /etc/systemd/system ]]; then
  echo "install.sh: installing systemd target"
  cp "$REPO_ROOT/systemd/pheno-forge-sidecars.target" /etc/systemd/system/
  for plugin_dir in "$PREFIX"/*/; do
    plugin_name="$(basename "$plugin_dir")"
    service_name="${plugin_name}.service"
    if [[ -f "$plugin_dir/systemd/$service_name" ]]; then
      cp "$plugin_dir/systemd/$service_name" /etc/systemd/system/
    fi
  done
  systemctl daemon-reload
  echo "install.sh: systemd units installed. Enable with: sudo systemctl enable --now pheno-forge-sidecars.target"
else
  echo "install.sh: systemd not writable; use scripts/launch-sidecars.sh for macOS or install units manually"
fi

echo ""
echo "install.sh: done"
echo "  Next steps:"
echo "    forge plugin list                # verify all 6 plugins registered"
echo "    forge plugin info <name>         # check a specific plugin"
echo "    sudo systemctl enable --now pheno-forge-sidecars.target    # Linux"
echo "    sudo ./scripts/launch-sidecars.sh                          # macOS"
echo "    forge                                                    # start a session"
