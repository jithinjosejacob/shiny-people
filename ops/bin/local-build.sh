#!/usr/bin/env bash

die() { echo "$*" >&2; exit 1; }

hash buildkite-agent &>/dev/null && die "buildkite-agent detected, not a local build"

for script in ops/bin/[[:digit:]]*.sh; do
  $script || die "failed: $script"
done
