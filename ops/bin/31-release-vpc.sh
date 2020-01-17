#!/usr/bin/env bash

die() { echo "$*" >&2; exit 1; }

[[ ! -d .git ]] && die "not in root or missing ops/cf/ecr"

if ! hash buildkite-agent &>/dev/null; then
  echo "$0: local build"
  exit
fi

hash sfm 2>/dev/null || die "missing dep: sfm"

stack="shiny-people-vpc"
tmpl="ops/cf/vpc/template.yml"
parm="ops/cf/vpc/params.yml"

sfm exec -p "$parm" "$stack" < "$tmpl" || die "failed to deploy '$stack'"
sfm wait -dots "$stack"

st=$(sfm stat "$stack") || die "unable to stat stack '$stack'"

[[ "$st" =~ (FAILED|ROLLBACK) ]] && { sfm stat -e "$stack"; exit 1; }

echo "$st"

