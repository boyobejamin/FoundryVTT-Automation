# FoundryVTT Automation

This project provides IaC, CaC, and containers to provision FoundryVTT via docker-compose or AWS ECS Fargate.

## Getting started

A valid [FoundryVTT](https://foundryvtt.com/) license is required to build, run, and use FoundryVTT.

For docker, check out the ReadMe in `./foundryvtt`

## Dockerfiles

To support IaC a buildtime container for terraform is created in `./terraform`

`./foundryvtt` contains its own `Dockerfile` for building our base Foundry image running as a least privileged user. 

`./foundryvtt/nginx` will build an nginx proxy. The configuration is good for a lift and shift to another proxy solution. Whether running in the cloud or locally, I want to provide a proxy rather than exposing the nodejs app directly on the internet

## IaC

`./terraform-bootstrap` provides all infrastructure dependencies such as terraform state, certificates, load balancer, ecr, and an ecs cluster.

`./terraform-app` creates an ecs service, efs volume, iam roles/policies, and an s3 bucket for individual apps. The service will be registered using your unique name to the load balancer created in `./terraform-bootstrap`.

It is assumed that a certificate will be created for `*.vtt.<my-domain>` by which environments are spun up for individuals or specific efforts.