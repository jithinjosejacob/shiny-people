#!/usr/bin/env bash

die() { echo "$*" >&2; exit 1; }

if ! hash buildkite-agent &>/dev/null; then
  echo "$0: local build"
fi

hash aws 2>/dev/null        || die "missing dep: aws"
hash docker 2>/dev/null     || die "missing dep: docker"
hash shellcheck 2>/dev/null || die "missing dep: shellcheck"

shopt -s globstar extglob nullglob

## cfn
echo "~~~ :cloudformation: validating CFN templates"
for t in ops/cf/**/!(param*).yml; do
    aws cloudformation validate-template --template-body "file://$t" >/dev/null \
        || die "failed to validate '$t'"
done


## docker
echo "~~~ :docker: linting Dockerfiles"
for d in **/Dockerfile; do
    docker run --rm -i hadolint/hadolint <"$d" \
        || die "failed to lint '$d'"
done


## scripts
echo "~~~ :bash: linting scripts"
for s in **/*.sh; do
    shellcheck -- "$s"
done
