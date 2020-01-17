#!/usr/bin/env bash

die() { echo "push failed: $*" >&2; exit 1; }

[[ ! -d .git ]] && die "not in repo root"

if ! hash buildkite-agent &>/dev/null; then
  echo "$0: local build"
  exit
fi

shopt -s globstar nullglob

ecr=$(buildkite-agent meta-data get "RootECR") || die "get ecr uri"

for d in **/Dockerfile; do
  n=$(dirname "$d")
  echo "~~~ :ecr: push $n"
  docker push "$ecr/$n:latest" || die "docker push"
done

