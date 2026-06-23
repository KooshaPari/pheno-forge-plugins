#!/usr/bin/env bash
# Download sidecar binaries from upstream releases into the plugin bin/ dirs.
# Per ADR-027 (Git LFS 3-tier), binaries are Tier 2 (on-demand, fetched at install).
#
# Usage:
#   ./scripts/fetch-sidecars.sh
#
# Env:
#   PHENO_SIDECAR_VERSION — default "v0.1.0" (matches this plugin bundle version)
#   PHENO_FORGE_PLATFORM   — auto-detected; override for cross-platform builds

set -euo pipefail

VERSION="${PHENO_SIDECAR_VERSION:-v0.1.0}"
PLATFORM="${PHENO_FORGE_PLATFORM:-$(uname -s | tr '[:upper:]' '[:lower:]')}-$(uname -m)}"

# URL templates per sidecar (placeholder for upstream release URLs)
declare -A SIDECAR_URLS=(
  [pheno-supermemory]="https://github.com/supermemoryai/supermemory/releases/download/${VERSION}/supermemory-${PLATFORM}"
  [pheno-letta]="https://github.com/letta-ai/letta/releases/download/${VERSION}/letta-${PLATFORM}"
  [pheno-cognee]="https://github.com/topoteretes/cognee/releases/download/${VERSION}/cognee-mcp-${PLATFORM}"
  [pheno-mem0]="https://github.com/mem0ai/mem0/releases/download/${VERSION}/mem0-${PLATFORM}"
  [pheno-config]="https://github.com/KooshaPari/Configra/releases/download/${VERSION}/configra-${PLATFORM}"
  [pheno-tracing]="https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v0.110.0/otelcol-contrib_${PLATFORM}"
)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

for plugin in "${!SIDECAR_URLS[@]}"; do
  bin_dir="$REPO_ROOT/plugins/$plugin/bin"
  if [[ ! -d "$bin_dir" ]]; then
    echo "fetch-sidecars.sh: skip $plugin (no bin/ dir)" >&2
    continue
  fi
  # Determine the binary name from plugin.env
  env_file="$REPO_ROOT/plugins/$plugin/plugin.env"
  binary_name="${plugin#pheno-}"
  if [[ -f "$env_file" ]]; then
    # shellcheck source=/dev/null
    source "$env_file"
    binary_name="${PHENO_BINARY_NAME:-$binary_name}"
  fi
  dest="$bin_dir/$binary_name"
  url="${SIDECAR_URLS[$plugin]}"
  echo "fetching $plugin -> $url"
  if ! curl -fsSL --retry 3 -o "$dest" "$url"; then
    echo "fetch-sidecars.sh: failed to fetch $plugin from $url" >&2
    continue
  fi
  chmod +x "$dest"
  echo "  -> $dest (executable, $(wc -c < "$dest") bytes)"
done

echo "fetch-sidecars.sh: done"
