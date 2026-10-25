# Architecture decision records

| # | Decision | Status |
|---|---|---|
| [ADR-001](#adr-001-terraform) | Terraform as the IaC tool | Accepted |
| [ADR-002](#adr-002-stacks-modules-and-environment-files) | Stacks, modules and environment files instead of workspaces | Accepted |
| [ADR-003](#adr-003-s3-backend-with-native-locking) | S3 backend with native locking | Accepted |
| [ADR-004](#adr-004-talos-linux-on-graviton) | Talos Linux on Graviton | Accepted |
| [ADR-005](#adr-005-public-subnets-without-nat) | Public subnets without NAT | Accepted, revisit for production |
| [ADR-006](#adr-006-single-control-plane-node) | Single control plane node | Accepted, revisit for production |
| [ADR-007](#adr-007-elastic-ip-as-cluster-endpoint) | Elastic IP as cluster endpoint | Accepted |
| [ADR-008](#adr-008-apply-from-the-operator-workstation) | Apply from the operator workstation | Accepted, revisit when OIDC is available |
| [ADR-009](#adr-009-admin-cidrs-supplied-at-runtime) | Admin CIDRs supplied at runtime | Accepted |

## ADR-001: Terraform

**Context.** Terraform and OpenTofu are both viable. OpenTofu offers client-side state encryption; Terraform has the broader ecosystem and adoption.
**Decision.** Terraform, pinned in `.terraform-version`. Version 1.15 or later is required because the S3 backend supports `aws login` credentials from that release.
**Consequences.** No client-side state encryption; the state bucket compensates with encryption at rest, TLS enforcement, versioning and no public access.

## ADR-002: Stacks, modules and environment files

**Context.** The platform must support several environments without duplicated code, and a failure in one area must not put others at risk.
**Decision.** Separate stacks with separate state; reusable modules without provider configuration; `environments/<env>.tfvars` and `<env>.backend.hcl` per stack.
**Consequences.** Commands need `-var-file` and `-backend-config`, wrapped by the Makefile. Workspaces were rejected because they share backend and credentials across environments.

## ADR-003: S3 backend with native locking

**Context.** State contains the cluster PKI and must be shared, protected and recoverable.
**Decision.** One bucket created by the `bootstrap` stack, with SSE-S3, versioning, public access block, a TLS-only policy, 90-day expiry of non-current versions and `prevent_destroy`. Locking uses `use_lockfile`.
**Consequences.** No DynamoDB table to manage. SSE-S3 is used instead of a customer-managed KMS key to avoid key cost and key policy management.

## ADR-004: Talos Linux on Graviton

**Context.** Nodes should be immutable, minimal and fully declarative, at low cost.
**Decision.** Talos Linux on `t4g` (arm64) instances, using the official AMI looked up by version and restricted to Sidero Labs' account. Cluster lifecycle is managed with the `siderolabs/talos` provider.
**Consequences.** No SSH; all access through `talosctl`. Container images must support arm64.

## ADR-005: Public subnets without NAT

**Context.** A NAT gateway costs about 35 USD per month, above the environment's budget.
**Decision.** Nodes run in public subnets with public IPs; inbound access is restricted by the security group to admin CIDRs on ports 50000 and 6443.
**Consequences.** Larger exposure than a private design. Production should use private subnets with NAT and a load balancer or VPN for API access.

## ADR-006: Single control plane node

**Context.** Three nodes give high availability but triple the cost; `t4g.small` (2 GiB) is too small for the control plane plus Argo CD.
**Decision.** One `t4g.medium` control plane node with the control plane taint removed so it also runs workloads. Nodes are a map, so scaling to three AZs is a data change.
**Consequences.** No tolerance for node or AZ failure.

## ADR-007: Elastic IP as cluster endpoint

**Context.** Auto-assigned public IPs change on stop and start, but the Kubernetes endpoint and certificates are bound to the address. Nodes are stopped outside working hours.
**Decision.** One Elastic IP per node; the first node's Elastic IP is the cluster endpoint.
**Consequences.** About 0.12 USD per day while stopped. A multi-node control plane needs a load balancer or shared address as the endpoint.

## ADR-008: Apply from the operator workstation

**Context.** The target design is GitHub Actions with OIDC: plan on pull requests, apply on merge, no stored keys. The AWS account is an AWS-managed project whose service control policy explicitly denies IAM OIDC provider actions. Lifting it requires activating advanced account features, which is irreversible and removes the account's spend limit.
**Decision.** CI validates every pull request; apply runs from `main` on the operator's workstation after merge.
**Consequences.** Apply depends on operator discipline and there is no scheduled drift detection. The target design remains: an IAM OIDC provider for `token.actions.githubusercontent.com`, a plan role trusted for pull requests, an apply role trusted only for `refs/heads/main`, saved plans posted to the pull request and applied on merge, and a nightly `plan -detailed-exitcode`.

## ADR-009: Admin CIDRs supplied at runtime

**Context.** The repository is public, and the operator's IP is personal and dynamic.
**Decision.** `TF_VAR_admin_cidrs` is set from the current public IP by the Makefile and never stored in the repository.
**Consequences.** An IP change appears as a security group rule replacement on the next plan. With CI apply, a single source of truth (for example a repository secret or SSM parameter) is required to avoid local runs and CI replacing each other's rules.
