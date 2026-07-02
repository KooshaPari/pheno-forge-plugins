#!/usr/bin/env bats
# bats test_tags=healthcheck
# Tests for scripts/healthcheck.sh

setup() {
  # Change to repo root so relative paths resolve
  cd "$BATS_TEST_DIRNAME/.." || exit 1
}

@test "healthcheck: fails with exit 64 when no plugin name given" {
  run ./scripts/healthcheck.sh
  [ "$status" -eq 64 ]
  # Output must be valid JSON with status:error
  echo "$output" | jq -e '.status == "error"' >/dev/null
}

@test "healthcheck: fails with exit 64 when PHENO_PLUGIN_NAME is empty string" {
  run ./scripts/healthcheck.sh ""
  [ "$status" -eq 64 ]
  echo "$output" | jq -e '.status == "error"' >/dev/null
}

@test "healthcheck: emits valid JSON on error" {
  run ./scripts/healthcheck.sh
  echo "$output" | jq -e '.detail != null' >/dev/null
}

@test "healthcheck: emits JSON with all required keys" {
  run ./scripts/healthcheck.sh
  echo "$output" | jq -e 'has("status") and has("detail")' >/dev/null
}
