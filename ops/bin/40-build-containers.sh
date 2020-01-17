#!/usr/bin/env bash

die() { echo "build failed: $*" >&2; exit 1; }

cd "$(dirname "$(git rev-parse --absolute-git-dir)")" || die "not in repo root"

if hash buildkite-agent &>/dev/null; then
  ecr=$(buildkite-agent meta-data get "RootECR") || die "get root ecr"
else
  echo "$0: local build"
  ecr="shiny-people-local"
fi

shopt -s globstar nullglob

repo="shiny-people"

echo "~~~ :github: archiving $repo"
p=$(uname |tr '[:upper:]' '[:lower:]') # this will work for linux or darwin
hubr install -d ops/bin "ops-tools-github@v0.0.9:backup-$p:backup" || die "get backup tool"
mkdir -p nginx/zip
./ops/bin/backup "$repo" "nginx/zip/$repo.zip" || die "zip $repo"

for d in **/Dockerfile; do
  n=$(dirname "$d")
  echo "~~~ :docker: build $n"
  cd "$(dirname "$(git rev-parse --absolute-git-dir)")/$n" || die "cd to $n"
  docker build -t "$ecr/$n:latest" . || die "docker"
done

