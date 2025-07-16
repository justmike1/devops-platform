# DevOps / Cloud / Software Engineering Monorepo

This monorepo is a structured workspace for my continuous learning and experimentation in **DevOps**, **Cloud Infrastructure**, and **Software Engineering**.

Each major component in the repository is scoped to an area of practice and includes (or will include) its own README for detailed usage, configuration, and implementation notes.

---

## Projects

### GitHub Actions

**Path:** [`.github/workflows`](./.github/workflows/)  
Workflow automation for CI/CD pipelines. Demonstrates selective workflow triggering based on modified files in a commit.

---

### Infrastructure as Code (Terraform)

#### AWS

**Path:** [`infra-as-code/providers/aws/modules`](./infra-as-code/providers/aws/modules)

- `eks.tf`: EKS cluster provisioning
- `vpc.tf`: Custom VPC definition
- `ebs.tf`, `iam.tf`, `karpenter.tf`, `metrics-server.tf`, `s3-state.tf`: Supporting infrastructure modules

#### GCP

**Path:** [`infra-as-code/providers/gcp/modules`](./infra-as-code/providers/gcp/modules)

- `gke.tf`: GKE production-grade cluster
- Modules for networking, bastion, firewall rules, NAT, Traefik, Cloud Armor, service accounts

#### Azure

**Path:** [`infra-as-code/providers/azure/modules`](./infra-as-code/providers/azure/modules)

- `aks.tf`: AKS cluster provisioning
- Modules for PostgreSQL, App Gateway, VNet, DNS zones, and storage

#### Templates for Environments

**Path:** [`infra-as-code/environments`](./infra-as-code/environments)

- `azure-template/`: Base backend and main Terraform configs
- `gcp-template/`: Similar structure for GCP deployments

---

### Kubernetes / Helm Microservices

**Path:** [`kubernetes/helm`](./kubernetes/helm)

- Parent Helm chart (`Chart.yaml`)
- Microservice subcharts:
    - `kafka`, `opensearch`, `postgresql`, `rabbitmq`, `redis`, `tika`
- Shared chart templates (`_*.tpl`) for deployments, services, configmaps, etc.
- Global templates: `global-ingress.yaml`, `openshift-routes.yaml`, `secrets.yaml`
- Test manifest: `tests/test-connection.yaml`

This structure supports consistent Helm chart composition across services using DRY principles.

---

### Scripts

**Path:** [`scripts`](./scripts)

- [`utils.sh`](./scripts/utils.sh): Shared utility functions
- [`format_all.sh`](./scripts/format_all.sh): Format source code
- [`lint_all.sh`](./scripts/lint_all.sh): Run linters on the repository
- [`test_args.sh`](./scripts/test_args.sh): Validate `utils.sh` argument handling
- Other utilities:
    - `clean_local_docker.sh`: Cleanup script for Docker
    - `tunnel_service.sh`: Port forwarding or tunneling logic
    - `wait_for_pod.sh`: Waits for a Kubernetes pod to be ready
    - `migrate_repo.sh`, `site_status.sh`: Misc support scripts

---

### Tools

**Path:** [`tools`](./tools)

#### Slack Alert

**Path:** [`tools/slack_alert`](./tools/slack_alert)  
Sends Slack notifications from CI/CD pipelines for build status or other triggers.

#### Tavisod

**Path:** [`tools/tavisod`](./tools/tavisod)  
Python package for fetching secrets from Google Secret Manager.

- Python module under `tavisod/`
- `setup.py` and tests included

#### Google SQL Migrator

**Path:** [`tools/google_sql_migrator`](./tools/google_sql_migrator)  
Transfers data between Google Cloud SQL instances using local Postgres and Docker.

- Includes Dockerfile, database scripts, CLI, and requirements

#### Resources Calculator

**Path:** [`tools/resources`](./tools/resources)  
Calculates chart resource usage (`calc_chart_resources.py`).

#### Vulnerabilities Report

**Path:** [`tools/vulnerabilities`](./tools/vulnerabilities)  
Scripted vulnerability scanner and report generator with PDF and HTML template output.

---

## Miscellaneous

- [`nginx.conf`](./nginx.conf): NGINX server configuration file
- [`git.config`](./git.config): Git configuration used locally
- [`requirements.txt`](./requirements.txt): Python dependencies for repo-wide tools
- [`zshrc`](./zshrc): Custom shell configuration

---

## External Projects

These are other repositories I maintain separately from this monorepo you can find on my [GitHub](https://github.com/justmike1)

---

## Notes

- Each directory is self-contained and designed for modular usage or reuse.
- Terraform code follows provider/environment separation for flexibility.
- Scripts and tools are aligned with real-world DevOps automation tasks.

---

## Getting Started

```bash
git clone https://github.com/justmike1/devops-platform.git
cd devops-platform
```
