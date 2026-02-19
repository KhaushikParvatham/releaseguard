# ReleaseGuard

Health-Gated Blue–Green Deployment System on AWS EC2 using Docker, Nginx, and GitHub Actions.

ReleaseGuard is a production-style deployment controller designed to prevent silent production failures by enforcing automated health validation before traffic switching. It implements deterministic blue–green deployments with automatic rollback on a single EC2 instance, without relying on Kubernetes or managed orchestration platforms.

---

## Problem Statement

In traditional deployment workflows, applications may deploy successfully at the infrastructure level but fail at runtime due to configuration errors, startup issues, or dependency problems. This often results in:

- Silent production failures  
- Manual post-deployment validation  
- Emergency rollbacks  
- Temporary downtime during restarts  

ReleaseGuard addresses this by enforcing health validation before allowing new releases to receive production traffic.

---

## Objectives

- Detect unhealthy deployments in under 60 seconds  
- Eliminate manual post-deployment validation  
- Implement automatic rollback on failure  
- Achieve near zero-downtime deployments  
- Demonstrate production-grade CI/CD without orchestration frameworks  

---

## Architecture Overview

Developer Push  
      |  
      v  
GitHub Actions (CI/CD)  
      |  
      v  
AWS EC2 Production Node  
   ├── Build Docker image  
   ├── Deploy to inactive color  
   ├── Health validation (<60s)  
   ├── Switch Nginx upstream (if healthy)  
   └── Automatic rollback (if unhealthy)  

---

## System Components

- Flask Application — Business logic and `/health` endpoint  
- Docker — Containerized runtime environment  
- Nginx — Blue–green traffic switching layer  
- Bash Deployment Script — Health gate and rollback controller  
- GitHub Actions — CI/CD automation  
- AWS EC2 — Production execution node  

---

## Blue–Green Deployment Strategy

Two containers are maintained:

- releaseguard-blue  
- releaseguard-green  

Only one container receives production traffic at any given time.

The active upstream configuration is stored at:

/tmp/nginx-upstreams/active.conf

Deployment flow:

1. Detect active color  
2. Deploy new image to inactive color  
3. Perform health validation  
4. If healthy, switch traffic atomically via Nginx reload  
5. Remove previous container  

If health validation fails:

- Traffic remains on the previous stable version  
- The failed container is removed  
- CI pipeline exits with failure  

---

## Health-Gated Deployment Logic

The deployment controller validates:

- Configuration integrity  
- Application readiness  
- Uptime stability  

Health checks are performed with a retry loop:

- 12 attempts  
- 5-second intervals  
- Maximum detection window: 60 seconds  

If the application fails to become healthy within this window, the deployment is aborted and rolled back automatically.

---

## CI/CD Workflow

Triggered on:

push → main

Pipeline sequence:

1. Checkout repository  
2. Copy project to EC2 via SSH  
3. Build Docker image on EC2  
4. Execute deploy.sh  
5. Validate health  
6. Switch traffic or rollback  

No manual SSH access is required during normal deployments.

---

## Measurable Outcomes

- Detect unhealthy deployments in <60 seconds via timed health validation loop  
- Reduce deployment downtime using atomic blue–green traffic switching  
- Prevent broken releases through health gating before traffic shift  
- Eliminate manual validation using fully automated CI/CD workflow  

---

## Failure Handling

If health validation fails:

docker rm releaseguard-<inactive-color>  
exit 1  

Outcome:

- No traffic switch occurs  
- Previous version remains live  
- CI job fails visibly  

This ensures containment of faulty releases without impacting users.

---

## Security Considerations

- SSH key-based authentication  
- Restricted inbound security group rules  
- Docker network isolation  
- Non-root container execution  
- Deterministic deployment scripting  

---

## Technology Stack

- AWS EC2 (Ubuntu)  
- Docker  
- Nginx  
- Flask (Python)  
- GitHub Actions  
- Bash scripting  

---

## Local Development

Clone repository:

git clone https://github.com/<your-username>/releaseguard.git  
cd releaseguard  

Build images:

docker build -t releaseguard:local -f docker/Dockerfile .  
docker build -t releaseguard-nginx:local -f docker/Dockerfile.nginx .  

---

## Future Enhancements

- Amazon ECR integration  
- Multi-node deployment support  
- Application Load Balancer integration  
- Slack notification on deployment failure  
- Centralized logging  
- Metrics instrumentation  

---

## Author

Khaushik  
DevOps Engineer (Aspiring)  
India  

---

## Project Summary

ReleaseGuard demonstrates that resilient deployment systems can be engineered using core DevOps primitives—health contracts, container isolation, deterministic scripting, and atomic traffic switching—without relying on orchestration frameworks.


