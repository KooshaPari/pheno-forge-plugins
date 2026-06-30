#!/usr/bin/env bats
# bats test_tags=teardown
# Tests for scripts/teardown.sh

setup() {
  cd "$BATS_TEST_DIRNAME/.." || exit 1
}

@test "teardown: fails with exit 64 when no plugin name given" {
  run ./scripts/teardown.sh
  [ "$status" -eq 64 ]
}

@test "teardown: fails with exit 64 when given empty string" {
  run ./scripts/teardown.sh ""
  [ "$status" -eq 64 ]
}

@test "teardown: emits error message on stderr when no plugin name" {
  run ./scripts/teardown.sh
  [ "$status" -eq 64 ]
  echo "$output" | grep -qi "PHENO_PLUGIN_NAME"
}
