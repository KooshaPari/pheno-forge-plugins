#!/usr/bin/env bats
# bats test_tags=spawn
# Tests for scripts/spawn.sh

setup() {
  cd "$BATS_TEST_DIRNAME/.." || exit 1
}

@test "spawn: fails with exit 64 when no plugin name given" {
  run ./scripts/spawn.sh
  [ "$status" -eq 64 ]
}

@test "spawn: fails with exit 64 when given empty string" {
  run ./scripts/spawn.sh ""
  [ "$status" -eq 64 ]
}

@test "spawn: emits error message on stderr when no plugin name" {
  run ./scripts/spawn.sh
  [ "$status" -eq 64 ]
  # Should mention the error on stderr
  echo "$output" | grep -qi "PHENO_PLUGIN_NAME"
}
