#!/usr/bin/env bash
# Build the install tarball from the current repo state.
# Output: dist/pheno-forge-plugins-<version>.tar.gz
#
# Usage:
#   ./scripts/build-tarball.sh [version]
#   PHENO_SIDECAR_VERSION=v0.1.0 ./scripts/build-tarball.sh

set -euo pipefail

VERSION="${1:-${PHENO_SIDECAR_VERSION:-0.1.0}}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DIST_DIR="$REPO_ROOT/dist"
STAGE_DIR="$DIST_DIR/pheno-forge-plugins-$VERSION"
TARBALL="$DIST_DIR/pheno-forge-plugins-$VERSION.tar.gz"

rm -rf "$STAGE_DIR" "$TARBALL"
mkdir -p "$STAGE_DIR"

# Copy the plugin tree (without bin/* — fetch-sidecars.sh handles those)
rsync -a --exclude='bin/*' --exclude='.git' --exclude='dist' \
  "$REPO_ROOT/" "$STAGE_DIR/"

# Ensure bin/ directories have .gitkeep
for plugin_dir in "$STAGE_DIR"/plugins/*/; do
  mkdir -p "${plugin_dir}bin"
  [[ -f "${plugin_dir}bin/.gitkeep" ]] || touch "${plugin_dir}bin/.gitkeep"
done

# Tarball
tar -czf "$TARBALL" -C "$DIST_DIR" "pheno-forge-plugins-$VERSION"

# SHA256 for distribution
sha256sum "$TARBALL" | tee "$TARBALL.sha256"

echo "build-tarball.sh: $TARBALL ($(wc -c < "$TARBALL") bytes)"
