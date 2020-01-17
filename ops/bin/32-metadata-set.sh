#!/usr/bin/env bash

die() { echo "$*" >&2; exit 1; }

if ! hash buildkite-agent &>/dev/null; then
  echo "$0: local build"
  exit
fi

for stack in shiny-people-base shiny-people-vpc; do
    echo "acquiring metadata from $stack"
    sfm stat -o "$stack" |while read -r k v; do
          echo "├── $k = $v"
          buildkite-agent meta-data set "$k" "$v" || die "failed to set $k"
    done
done

