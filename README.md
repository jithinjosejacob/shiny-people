# Payroll

[![Build status](https://badge.buildkite.com/daa4529480875fa6acfb1b9e2419361d50a80324389b5528de.svg)](https://buildkite.com/myob/shiny-people)

The playground for showing your skills.

# ops

## containers

Each Dockerfile in the repo will be built and deployed to its own ECR, which will be named `shiny-people/<container>`. The container will have the same name as the directory containing the Dockerfile.

The build process creates a templated `docker-compose.yml`, wherein the `image` for each container is filled in as above, using the directory name that contains the Dockerfile.

To add a new service, for example a service called `foobar`, you would create a Dockerfile in a directory called `foobar`, and add the service to the template `docker-compose.yml.tmpl` as follows:

```yaml
services:
  foobar:
    image: "{{ .foobar }}"
```

This is Go text/template language and the templated compose file is created by `ops/bin/51-deploy-compose.sh`.

## nginx

The nginx container holds the repo backup and serves it at `/shiny-people.zip`, this container
fronts the whole service and all other requests are forwarded to the internal container network.

## local build

You can build locally by running `ops/bin/local-build.sh`, you will need to be authenticated
with any myob aws account that has buildkite deployed, in order to be able to create the repo
backup and to lint the cloudformation templates.

The local build will produce a docker-compose.yml that runs the service at `localhost:8080`.

The local build will not deploy any infrastructure.

## ci build

Building on Buildkite will stand up all the infrastructure and the containers will be deployed
to ECR. The docker-compose.yml is deployed to an S3 bucket and when it runs will publish on port 80.

## infrastructure

The *base stack* comprises a private S3 bucket and one ECR for each container that will be created.

The *VPC stack* has a VPC, public and private subnets across 3 AZs, internet and NAT gateways and
associated route tables.

The *ELB stack* contains an ELB and a Route53 hosted zone pointing to the ELB.

The *ASG stack* comprises ASG and Launch Configuration, which will be deployed inside the
VPC and using the ELB.
When an EC2 instance launches it will copy the compose file from S3 and run it.

The *ASG stack* will be A-B deployed for each build.

# test

## api tests
```
cd payments/app && npm install && npm test
```

## web tests

### start dependencies
```
cd payroll/app/client && npm install
cd payroll/app && npm install && npm run start-test
cd payments/app && npm install && npm start
cd tax/app && npm install && npm start
```

### run tests
```
cd payroll/app && npm test
```
