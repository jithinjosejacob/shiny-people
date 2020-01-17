#!/usr/bin/env bash
die() { echo "push failed: $*" >&2; exit 1; }

[[ ! -d .git ]] && die "not in repo root"

if hash buildkite-agent &>/dev/null; then
  port="80"
  ecr=$(buildkite-agent meta-data get "RootECR" 2>/dev/null)
else
  echo "$0: local build"
  port="8080"
  ecr="shiny-people-local"
fi

shopt -s globstar nullglob

{
  echo "port: $port"
  for d in **/Dockerfile; do
    n=$(dirname "$d")
    echo "$n: $ecr/$n"
  done
}| yj -m - docker-compose.yml.tmpl > docker-compose.yml || die "patch docker-compose"

echo "service will be published on port $port"

if ! hash buildkite-agent &>/dev/null; then
  exit
fi

bucket=$(buildkite-agent meta-data get "DeploymentBucket" 2>/dev/null) || die "get bucket"
aws s3 cp docker-compose.yml "s3://$bucket" || die "docker-compose to s3"
