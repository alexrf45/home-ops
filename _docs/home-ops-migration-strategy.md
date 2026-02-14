# Home-Ops Flux Repository Migration Strategy

## Current Structure Analysis

The repository currently organizes Kubernetes manifests across four top-level directories that Flux reconciles per cluster:

```
home-ops/
├── clusters/
│   ├── horus/        → prod (Flux entrypoint: --path=clusters/horus)
│   ├── memphis/      → dev  (Flux entrypoint: --path=clusters/memphis)
│   └── abydos/       → test (Flux entrypoint: --path=clusters/abydos)
├── components/       → shared CRDs, HelmRepositories, Namespaces
├── controllers/
│   ├── base/         → cert-manager, external-secrets, tailscale, cnpg, freenas-csi, etc.
│   ├── dev/          → overlay for memphis
│   ├── prod/         → overlay for horus
│   └── test/         → overlay for abydos
├── applications/
│   ├── base/         → freshrss, it-tools, wallabag base manifests
│   ├── dev/          → overlay for memphis (gateway, external-dns, wallabag, silverbullet)
│   ├── prod/         → overlay for horus (gateway, external-dns, cnpg backups, wallabag)
│   └── test/         → overlay for abydos (gateway, external-dns)
└── infra/
    ├── horus/        → Terraform for prod cluster
    ├── memphis/      → Terraform for dev cluster
    └── abydos/       → Terraform for test cluster
```

Each cluster YAML (e.g., `horus.yaml`) defines three Flux Kustomizations with a linear dependency chain: `components → controllers → applications`. All clusters share a single `components/` directory with no per-environment variation.

---

## Identified Pain Points

**1. Ambiguous Naming Convention**
Cluster names (horus, memphis, abydos) map to environments (prod, dev, test) but this mapping only exists in developers' heads. The overlay directories use environment names while the cluster directories use codenames, creating a mental translation layer that makes onboarding and documentation harder.

**2. Shared Components Without Escape Hatches**
Every cluster reconciles the same `./components` path, meaning all CRDs, HelmRepositories, and Namespaces are identical. When a new controller is tested (e.g., adding Falco or Trivy repositories), it pollutes the prod cluster's repository list immediately.

**3. Mixed Infrastructure and Application Concerns**
Gateway API definitions, external-dns, and cert-manager issuers live under `applications/` alongside Wallabag and SilverBullet. These are infrastructure primitives that other applications depend on, but the flat `applications` Kustomization has no internal dependency ordering. A Gateway that reconciles after the HTTPRoutes referencing it causes transient failures.

**4. Duplicated Flux Components**
Each cluster directory contains its own `gotk-components.yaml` (~2500+ lines). Three copies of the same Flux controller definitions drift independently and make version upgrades a three-file manual edit.

**5. Flat Dependency Model**
The three-layer chain (`components → controllers → applications`) is too coarse. There is no way to express that external-secrets must be healthy before wallabag's ExternalSecret can resolve, or that cnpg-operator must be running before a PostgreSQL Cluster resource is applied. Everything within a layer races.

**6. Environment-Specific Secrets Scattered**
`freenas-csi` and `external-secrets` have per-environment overlays with encrypted secrets (`secrets.enc.yaml`), but other controllers reference secrets from `base/` directly. There is no consistent pattern for where environment-specific secret material lives.

**7. Scaling Friction**
Adding a new cluster (e.g., a staging environment or a second prod cluster for HA) requires creating a new `clusters/<name>/` entry, a new overlay under `controllers/<env>/`, a new overlay under `applications/<env>/`, and manually wiring the Flux Kustomizations in a new cluster YAML. The process is undocumented and error-prone.

---

## Migration Strategy 1: Cluster-Scoped Monorepo

This approach restructures around the cluster as the primary organizational unit, with each cluster owning its full manifest tree. Shared definitions are pulled in via Kustomize bases within a `_lib/` directory.

### Proposed Layout

```
kubernetes/
├── _lib/                              # Shared bases (never directly reconciled)
│   ├── controllers/
│   │   ├── cert-manager/
│   │   ├── external-secrets/
│   │   ├── onepassword-connect/
│   │   ├── tailscale/
│   │   ├── cloudnativepg/
│   │   ├── freenas-csi/
│   │   ├── kyverno/
│   │   ├── local-path/
│   │   └── renovate/
│   ├── apps/
│   │   ├── wallabag/
│   │   ├── freshrss/
│   │   ├── silverbullet/
│   │   └── adminer/
│   ├── components/
│   │   ├── crds/
│   │   ├── repositories/
│   │   └── namespaces/
│   └── security/
│       ├── kyverno-policies/
│       ├── trivy/
│       └── falco/
├── clusters/
│   ├── horus/                         # Prod
│   │   ├── flux-system/
│   │   ├── components/                # kustomization.yaml referencing _lib/components
│   │   ├── controllers/               # kustomization.yaml referencing _lib/controllers/*
│   │   ├── infrastructure/            # gateway, external-dns, cert-manager issuers
│   │   ├── apps/                      # kustomization.yaml referencing _lib/apps/*
│   │   ├── security/                  # kustomization.yaml referencing _lib/security/*
│   │   └── cluster.yaml              # Flux Kustomizations with full dependency DAG
│   ├── memphis/                       # Dev
│   │   └── (same structure)
│   └── abydos/                        # Test
│       └── (same structure)
└── infra/
    └── (terraform unchanged)
```

### Flux Kustomization DAG (per cluster)

The `cluster.yaml` expresses a proper dependency graph rather than a flat chain:

```yaml
# clusters/horus/cluster.yaml
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: components
  namespace: flux-system
spec:
  path: ./clusters/horus/components
  # ...
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: controllers
  namespace: flux-system
spec:
  dependsOn:
    - name: components
  path: ./clusters/horus/controllers
  healthChecks:
    - apiVersion: apps/v1
      kind: Deployment
      name: cert-manager
      namespace: cert-manager
    - apiVersion: apps/v1
      kind: Deployment
      name: external-secrets
      namespace: external-secrets
  # ...
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: infrastructure
  namespace: flux-system
spec:
  dependsOn:
    - name: controllers
  path: ./clusters/horus/infrastructure
  # ...
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: security
  namespace: flux-system
spec:
  dependsOn:
    - name: controllers
  path: ./clusters/horus/security
  # ...
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: apps
  namespace: flux-system
spec:
  dependsOn:
    - name: infrastructure
    - name: security
  path: ./clusters/horus/apps
  # ...
```

### Per-Cluster Overlay Example

```yaml
# clusters/horus/controllers/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../../_lib/controllers/cert-manager
  - ../../../_lib/controllers/external-secrets
  - ../../../_lib/controllers/onepassword-connect
  - ../../../_lib/controllers/tailscale
  - ../../../_lib/controllers/cloudnativepg
  - ../../../_lib/controllers/freenas-csi
  - ../../../_lib/controllers/renovate
  - ../../../_lib/controllers/local-path
  - ./overrides/freenas-csi # prod-specific configmap + secrets
  - ./overrides/external-secrets # prod ClusterSecretStore
```

### Pros

- Each cluster is fully self-contained and independently deployable; removing `clusters/abydos/` cleanly removes the test cluster from reconciliation.
- The `_lib/` prefix convention makes it immediately obvious which directories are templates vs. live reconciliation targets.
- Adding a new cluster is a `cp -r clusters/memphis clusters/new-cluster` followed by editing the overlay values. No changes outside the new directory.
- The five-layer dependency DAG (components → controllers → infrastructure → security → apps) allows proper health gating and eliminates race conditions.
- Infrastructure concerns (gateways, DNS, TLS) are separated from user-facing applications.
- Security tooling (Kyverno, Trivy, Falco) gets its own reconciliation layer that can be gated on controller health.

### Cons

- Relative path references to `_lib/` are verbose and fragile if directories are moved.
- Per-cluster overlay directories will contain many small `kustomization.yaml` files that mostly just list resources from `_lib/`.
- Clusters with near-identical configurations (dev and test) will duplicate most of their overlay wiring with minimal differences.
- The `_lib/` directory requires discipline; contributors must understand that it is never directly reconciled by Flux.
- Migrating three clusters simultaneously carries risk of partial failures during the transition.

---

## Migration Strategy 2: Tiered Environment Inheritance

This approach keeps the current base/overlay pattern but introduces a formal tier system with better layering. Environments inherit from a common tier definition, and only deviations are expressed per cluster.

### Proposed Layout

```
kubernetes/
├── base/                              # Universal defaults
│   ├── components/
│   │   ├── crds/
│   │   ├── repositories/
│   │   └── namespaces/
│   ├── controllers/
│   │   ├── cert-manager/
│   │   ├── external-secrets/
│   │   ├── onepassword-connect/
│   │   ├── tailscale/
│   │   ├── cloudnativepg/
│   │   ├── freenas-csi/
│   │   ├── local-path/
│   │   └── renovate/
│   ├── infrastructure/
│   │   ├── gateway-class/
│   │   ├── external-dns/
│   │   └── cert-manager-issuers/
│   ├── security/
│   │   ├── kyverno/
│   │   ├── kyverno-policies/
│   │   ├── trivy/
│   │   └── falco/
│   └── apps/
│       ├── wallabag/
│       ├── freshrss/
│       ├── silverbullet/
│       └── adminer/
├── tiers/                             # Environment-class definitions
│   ├── production/
│   │   ├── components/
│   │   │   └── kustomization.yaml     # resources: [../../base/components] + patches
│   │   ├── controllers/
│   │   │   └── kustomization.yaml     # resources: [../../base/controllers/*] + prod secrets
│   │   ├── infrastructure/
│   │   │   └── kustomization.yaml     # prod gateway, DNS zones
│   │   ├── security/
│   │   │   └── kustomization.yaml     # strict policies
│   │   └── apps/
│   │       └── kustomization.yaml     # prod app selection + replicas
│   ├── development/
│   │   └── (same structure, relaxed policies, fewer replicas)
│   └── testing/
│       └── (same structure, minimal apps, experimental controllers)
├── clusters/
│   ├── horus/
│   │   ├── flux-system/
│   │   ├── cluster.yaml               # Flux Kustomizations pointing to tiers/production/*
│   │   └── overrides/                 # Cluster-specific patches only (IPs, secrets, hostnames)
│   ├── memphis/
│   │   ├── flux-system/
│   │   ├── cluster.yaml               # Points to tiers/development/*
│   │   └── overrides/
│   └── abydos/
│       ├── flux-system/
│       ├── cluster.yaml               # Points to tiers/testing/*
│       └── overrides/
└── infra/
    └── (terraform unchanged)
```

### Flux Kustomization Pattern

```yaml
# clusters/horus/cluster.yaml
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: controllers
  namespace: flux-system
spec:
  dependsOn:
    - name: components
  path: ./tiers/production/controllers
  postBuild:
    substituteFrom:
      - kind: ConfigMap
        name: cluster-config # cluster-specific values (IPs, hostnames)
      - kind: Secret
        name: cluster-secrets
  patches:
    - target:
        kind: Kustomization
        name: controllers
      patch: |
        - op: add
          path: /spec/patches/-
          value:
            target:
              kind: ConfigMap
              name: truenas-config
            patch: |-
              - op: replace
                path: /data/TRUENAS_HOST
                value: "10.3.3.10"
```

### Pros

- Three-layer inheritance (base → tier → cluster) minimizes duplication across clusters that share an environment class.
- Adding a second production cluster only requires a new `clusters/<name>/` directory with its overrides; the `tiers/production/` path is reused.
- The tier abstraction creates a natural place to enforce organizational policy (e.g., "all production clusters must include Falco and Trivy").
- `postBuild.substituteFrom` with cluster-specific ConfigMaps keeps environment-specific values (IPs, hostnames, storage endpoints) out of the tier definitions entirely.
- Clear audit trail: reviewing `tiers/production/` shows exactly what runs in production regardless of which physical cluster hosts it.

- Three levels of indirection (base → tier → cluster) can be hard to reason about when debugging reconciliation failures. Tracing a single resource requires checking up to three kustomization files.
- The `tiers/` concept is non-standard in the Flux ecosystem; most community examples use a two-level base/overlay model, meaning less reference material.
- `postBuild` variable substitution can mask what actually gets deployed; the rendered manifests differ from what is in Git, which partially undermines the GitOps auditability principle.
- If clusters within a tier diverge significantly over time, the tier abstraction becomes a liability rather than a simplification. The overrides directory grows to the point where it effectively shadows the tier.
- Requires a ConfigMap and Secret to be pre-seeded on each cluster before Flux can reconcile, adding a bootstrap dependency that does not exist today.

---

## Migration Strategy 3: Flux OCI + Componentized Modules

This approach treats each logical grouping (a controller, an app, a security stack) as a self-contained Flux OCI artifact or Git subtree that is versioned and consumed independently. The cluster definition becomes a bill of materials.

### Proposed Layout

```
kubernetes/
├── modules/                           # Each module is a self-contained unit
│   ├── controllers/
│   │   ├── cert-manager/
│   │   │   ├── base/
│   │   │   ├── variants/
│   │   │   │   ├── production.yaml    # patches for prod (replicas, resources)
│   │   │   │   ├── development.yaml
│   │   │   │   └── testing.yaml
│   │   │   └── kustomization.yaml
│   │   ├── external-secrets/
│   │   │   ├── base/
│   │   │   └── variants/
│   │   ├── freenas-csi/
│   │   │   ├── base/
│   │   │   └── variants/
│   │   └── ... (each controller is a module)
│   ├── infrastructure/
│   │   ├── gateway/
│   │   │   ├── base/                  # GatewayClass + base Gateway
│   │   │   └── variants/             # per-env listener configs, TLS refs
│   │   ├── external-dns/
│   │   └── cert-manager-issuers/
│   ├── security/
│   │   ├── kyverno/
│   │   │   ├── base/
│   │   │   ├── policies/
│   │   │   │   ├── baseline/          # PSS baseline policies
│   │   │   │   ├── restricted/        # PSS restricted policies
│   │   │   │   └── custom/            # Home-ops specific policies
│   │   │   └── variants/
│   │   ├── trivy/
│   │   └── falco/
│   ├── observability/
│   │   ├── prometheus/
│   │   ├── grafana/
│   │   ├── loki/
│   │   └── fluentbit/
│   └── apps/
│       ├── wallabag/
│       │   ├── base/                  # deployment, service, httproute
│       │   ├── database/              # cnpg cluster, backups, secrets
│       │   └── variants/
│       ├── freshrss/
│       ├── silverbullet/
│       └── adminer/
├── clusters/
│   ├── horus/
│   │   ├── flux-system/
│   │   └── kustomizations/
│   │       ├── components.yaml
│   │       ├── controllers.yaml       # References modules/controllers/* with variant
│   │       ├── infrastructure.yaml
│   │       ├── security.yaml
│   │       ├── observability.yaml
│   │       └── apps.yaml
│   ├── memphis/
│   │   └── kustomizations/
│   │       └── ...
│   └── abydos/
│       └── kustomizations/
│           └── ...
├── components/                        # Truly global: CRDs, HelmRepos
│   ├── crds/
│   └── repositories/
└── infra/
    └── (terraform unchanged)
```

### Module Internal Structure

Each module is self-contained with its own dependency declarations:

```yaml
# modules/apps/wallabag/base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - namespace.yaml
  - deployment.yaml
  - service.yaml
  - httproute.yaml
  - network-policy.yaml
  - service-monitor.yaml
```

```yaml
# modules/apps/wallabag/variants/production.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../base
  - ../database
patches:
  - target:
      kind: Deployment
      name: wallabag
    patch: |
      - op: replace
        path: /spec/replicas
        value: 2
      - op: replace
        path: /spec/template/spec/containers/0/resources/limits/memory
        value: "512Mi"
```

### Cluster Bill of Materials

```yaml
# clusters/horus/kustomizations/apps.yaml
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: wallabag
  namespace: flux-system
spec:
  dependsOn:
    - name: controllers
    - name: infrastructure
  path: ./modules/apps/wallabag/variants/production
  prune: true
  healthChecks:
    - apiVersion: postgresql.cnpg.io/v1
      kind: Cluster
      name: wallabag-prod-cluster
      namespace: wallabag
  # ...
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: freshrss
  namespace: flux-system
spec:
  dependsOn:
    - name: controllers
    - name: infrastructure
  path: ./modules/apps/freshrss/variants/production
  # ...
```

### Pros

- Each module is independently testable; you can run `kustomize build modules/apps/wallabag/variants/production` in CI without building the entire cluster.
- Per-application Flux Kustomizations enable granular dependency declarations and health checks. Wallabag can depend on the cnpg controller being healthy; FreshRSS does not need to wait for it.
- The `variants/` pattern makes it trivial to see exactly how an application differs across environments by diffing two YAML files.
- Adding observability as a first-class reconciliation layer (separate from controllers and apps) creates a natural home for Prometheus, Grafana, Loki, and FluentBit with their own dependency chain.
- Security modules with policy subdirectories (baseline/restricted/custom) align with Pod Security Standards and make progressive policy rollout straightforward.
- Modules can eventually be extracted into their own Git repositories or published as OCI artifacts for sharing across projects.

### Cons

- Significantly more Flux Kustomization resources per cluster. A cluster with 15 modules could have 20+ Kustomization objects in flux-system, increasing reconciler load and the blast radius of Flux controller issues.
- The dependency DAG becomes complex with many edges; a typo in a `dependsOn` name silently breaks ordering without failing reconciliation.
- Developers must understand both Kustomize overlays (for the module internal structure) and Flux Kustomizations (for the cluster wiring). The cognitive overhead is higher than either Strategy 1 or 2.
- The `variants/` directory within each module creates many small files that duplicate boilerplate (apiVersion, kind, metadata). In a repo with 15 modules and 3 environments, that is 45 variant files.
- The transition is the most disruptive of the three strategies; every resource path changes and every Flux Kustomization must be rewritten simultaneously.

---

## Comparison Matrix

| Criteria                       | Strategy 1: Cluster-Scoped | Strategy 2: Tiered Inheritance | Strategy 3: Componentized Modules |
| ------------------------------ | :------------------------: | :----------------------------: | :-------------------------------: |
| Migration complexity           |           Medium           |             Medium             |               High                |
| New cluster onboarding         |        Copy + edit         |     Point to existing tier     |      Wire individual modules      |
| Dependency granularity         |          5 layers          |            5 layers            |            Per-module             |
| Duplication across clusters    |          Moderate          |              Low               |                Low                |
| CI testability                 |        Per-cluster         |            Per-tier            |            Per-module             |
| Cognitive overhead             |            Low             |             Medium             |               High                |
| Community alignment            |   High (common pattern)    |             Medium             |     Medium (growing adoption)     |
| Security layer isolation       |            Yes             |              Yes               |     Yes, with granular gating     |
| Observability stack separation |    Possible (add layer)    |      Possible (add layer)      |              Native               |
| Path to multi-repo / OCI       |         Difficult          |            Moderate            |              Natural              |
| Risk of configuration drift    |          Moderate          |      Low (tier enforced)       |      Low (variant enforced)       |

---

## Recommendation

For a home lab that prioritizes learning, documentation clarity, and the ability to experiment without breaking production, **Strategy 1 (Cluster-Scoped Monorepo)** offers the best balance of simplicity and flexibility. It maps cleanly to the existing bootstrap scripts (each script already targets a single cluster), it is the most widely documented pattern in the Flux and home-lab communities, and the migration path can be executed one cluster at a time by changing the `--path` argument in `flux bootstrap`.

If the lab grows to include multiple clusters per environment (e.g., two production clusters or a DR cluster), **Strategy 2** becomes more attractive because the tier abstraction prevents duplicating production-grade configurations. Consider evolving from Strategy 1 into Strategy 2 when the cluster count exceeds four.

**Strategy 3** is the most powerful long-term architecture, particularly as the security and observability stacks grow. It is worth adopting selectively: start with Strategy 1 for the overall structure but organize the `_lib/` directory internally using Strategy 3's module pattern (base + variants). This hybrid approach captures per-module testability without the full wiring complexity.

---

## Migration Execution Plan (Strategy 1)

Regardless of which strategy is chosen, the migration should follow this phased approach to minimize downtime:

**Phase 0 — Preparation (no cluster changes)**
Create the new directory structure alongside the existing one. Copy `base/` content into `_lib/`. Validate with `kustomize build` locally. Commit to a feature branch.

**Phase 1 — Migrate the test cluster (abydos)**
Update abydos's `gotk-sync.yaml` to point at the new path. Monitor reconciliation. Fix any path or dependency issues. This cluster is disposable; if it breaks, destroy and rebuild via Terraform.

**Phase 2 — Migrate the dev cluster (memphis)**
Repeat Phase 1. Validate that all applications reconcile correctly. Run the full application smoke test suite.

**Phase 3 — Migrate the prod cluster (horus)**
Schedule a maintenance window. Update the Flux bootstrap path. Monitor reconciliation of all controllers, infrastructure, and applications. Verify Wallabag, external-dns, cert-manager, and cnpg backups are functioning.

**Phase 4 — Cleanup**
Remove the old `controllers/{dev,prod,test}`, `applications/{dev,prod,test}`, and `components/` directories. Update Renovate's `includePaths` configuration. Update documentation and README.
