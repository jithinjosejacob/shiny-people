#!/usr/bin/env bash

die() { echo "deploy app failed: $*" >&2; exit 1; }

[[ ! -d .git ]] && die "not in root or missing ops/cf/ecr"

if ! hash buildkite-agent &>/dev/null; then
  echo "$0: local build"
  exit
fi

hash sfm 2>/dev/null || die "missing dep: sfm"
hash aws 2>/dev/null || die "missing dep: aws"

echo "~~~ :cloudformation: deploy elb"
vpc=$(buildkite-agent meta-data get "VpcId" 2>/dev/null) || die "get vpc id"
subnets=$(buildkite-agent meta-data get "Subnets" 2>/dev/null) || die "get vpc subnets"

stack="shiny-people-elb"
tmpl="ops/cf/elb/template.yml"
parm="ops/cf/elb/params.yml"

VpcId="$vpc" \
Subnets="$subnets" \
sfm exec -env -p "$parm" "$stack" < "$tmpl" \
  || die "failed to deploy '$stack'"

sfm wait -dots "$stack"

st=$(sfm stat "$stack") || die "unable to stat stack '$stack'"

[[ "$st" =~ (FAILED|ROLLBACK) ]] && { sfm stat -e "$stack"; exit 1; }

echo "$st"

echo "acquiring metadata from $stack"
sfm stat -o "$stack" |while read -r k v; do
  echo "├── $k = $v"
  buildkite-agent meta-data set "$k" "$v" || die "failed to set $k"
done


echo "~~~ :cloudformation: deploy asg"
asg_stacks=$(sfm ls -1 "shiny-people-asg-*" 2>/dev/null)

keypair="shiny-people-app"
if ! aws ec2 describe-key-pairs --key-names "$keypair" &>/dev/null; then
  prvkey=$(aws ec2 create-key-pair --key-name "$keypair" --query KeyMaterial --output text 2>/dev/null) \
    || die "create new keypair '$keypair'"
  aws ssm put-parameter --type SecureString --name "/shiny-people/ec2-pem" --value "$prvkey" &>/dev/null \
    || die "write pem to ssm"
fi

bucket=$(buildkite-agent meta-data get "DeploymentBucket" 2>/dev/null) || die "get deployment bucket"
profile=$(buildkite-agent meta-data get "InstanceProfile" 2>/dev/null) || die "get instance profile"
privates=$(buildkite-agent meta-data get "PrivateSubnets" 2>/dev/null) || die "get vpc private subnets"
elb=$(buildkite-agent meta-data get "ELB" 2>/dev/null) || die "get elb"
elbsg=$(buildkite-agent meta-data get "ELBSecurityGroup" 2>/dev/null) || die "get elb security group"

stack="shiny-people-asg-$BUILDKITE_BUILD_NUMBER"
tmpl="ops/cf/asg/template.yml"
parm="ops/cf/asg/params.yml"

KeyName="$keypair" \
DeploymentBucket="$bucket" \
InstanceProfile="$profile" \
VpcId="$vpc" \
PrivateSubnets="$privates" \
ELB="$elb" \
ELBSecurityGroup="$elbsg" \
sfm exec -env -p "$parm" "$stack" < "$tmpl" \
  || die "failed to deploy '$stack'"

sfm wait -dots "$stack"

st=$(sfm stat "$stack") || die "unable to stat stack '$stack'"

[[ "$st" =~ (FAILED|ROLLBACK) ]] && { sfm stat -e "$stack"; exit 1; }

echo "$st"

echo "~~~ cleaning up old asg"

for stack in $asg_stacks; do
  echo "removing $stack"
  sfm rm "$stack"
done

url=$(buildkite-agent meta-data get "URL" 2>/dev/null) || die "get url"
buildkite-agent annotate --style "info" <<🐈
  <a href="$url">Shiny People ELB Endpoint</a>
🐈
