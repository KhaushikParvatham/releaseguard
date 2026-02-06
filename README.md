# ReleaseGuard

ReleaseGuard is an internal DevOps deployment safety tool designed to
automatically validate application health after deployment and
roll back unhealthy releases with zero manual intervention.

## Problem
Successful deployments can still silently break production.

## Solution
ReleaseGuard introduces automated health-based validation,
blue–green traffic switching, and rollback logic to reduce downtime.

> This repository is built as a production-style DevOps project
> using AWS EC2, Docker, Nginx, and GitHub Actions.

