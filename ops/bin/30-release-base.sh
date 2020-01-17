#!/usr/bin/env bash

die() { echo "$*" >&2; exit 1; }

[[ ! -d .git ]] && die "not in repo root"

if ! hash buildkite-agent &>/dev/null; then
  echo "$0: local build"
  exit
fi

hash sfm 2>/dev/null || die "missing dep: sfm"

shopt -s globstar nullglob

stack="shiny-people-base"
tmpl="ops/cf/base/template.yml.tmpl"

{
  echo "images:"
  for d in **/Dockerfile; do
    echo "  - $(dirname "$d")"
  done
} | yj -m - "$tmpl" | sfm exec "$stack" || die "failed to deploy '$stack'"
sfm wait -dots "$stack"

st=$(sfm stat "$stack") || die "unable to stat stack '$stack'"

[[ "$st" =~ (FAILED|ROLLBACK) ]] && { sfm stat -e "$stack"; exit 1; }

echo "$st"

