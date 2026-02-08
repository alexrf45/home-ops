# Image Digest Management Guide

## Why Use Image Digests?

Image digests provide immutable references to container images, which is critical for security and reproducibility in your home lab:

### Security Benefits
- **Tag Mutation Prevention**: Tags can be overwritten (e.g., `adminer:4.8.1` could point to different content tomorrow)
- **Supply Chain Security**: Ensures you deploy the exact image you tested
- **Audit Trail**: Digests provide cryptographic proof of image content
- **CVE Tracking**: Security scanners can track vulnerabilities to specific image builds

### Reproducibility Benefits
- **GitOps Integrity**: Cluster can be rebuilt with identical container images
- **Rollback Confidence**: Previous versions are guaranteed unchanged
- **CI/CD Reliability**: Eliminates "works on my machine" with image tags
- **Compliance**: Meet requirements for immutable deployments

## Current Configuration

The Adminer deployment uses digest-pinned images:

```yaml
image: adminer:4.8.1@sha256:b3025d9191b6e29b327c69394a7ebee20e25e98a0f68b570f23e0e860655a4fb
```

**Format**: `<image>:<tag>@sha256:<digest>`

**Benefits of including both tag and digest**:
- Tag provides human-readable version information
- Digest provides cryptographic integrity
- Both together give best of readability and security

## Getting Image Digests

### Method 1: Using Docker (Most Common)

```bash
# Pull the image
docker pull adminer:4.8.1

# Get the digest
docker inspect --format='{{index .RepoDigests 0}}' adminer:4.8.1

# Output: adminer@sha256:b3025d9191b6e29b327c69394a7ebee20e25e98a0f68b570f23e0e860655a4fb
```

### Method 2: Using Skopeo (No Docker Daemon Required)

```bash
# Install skopeo (if not already installed)
# Debian/Ubuntu: apt-get install skopeo
# Fedora: dnf install skopeo
# macOS: brew install skopeo

# Get digest
skopeo inspect docker://docker.io/adminer:4.8.1 | jq -r '.Digest'

# Output: sha256:b3025d9191b6e29b327c69394a7ebee20e25e98a0f68b570f23e0e860655a4fb
```

### Method 3: Using Crane (Lightweight, Google)

```bash
# Install crane
go install github.com/google/go-containerregistry/cmd/crane@latest
# Or download from: https://github.com/google/go-containerregistry/releases

# Get digest
crane digest adminer:4.8.1

# Output: sha256:b3025d9191b6e29b327c69394a7ebee20e25e98a0f68b570f23e0e860655a4fb
```

### Method 4: Using Registry API (No Tools Required)

```bash
# Get authentication token
TOKEN=$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:library/adminer:pull" | jq -r .token)

# Get digest
curl -s -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
  https://registry-1.docker.io/v2/library/adminer/manifests/4.8.1 | jq -r '.config.digest'
```

## Automated Digest Updates

### Using the Provided Script

The repository includes `update-image-digest.sh` for automated updates:

```bash
# Make script executable
chmod +x update-image-digest.sh

# Update Adminer deployment
./update-image-digest.sh

# Update different image
./update-image-digest.sh nginx 1.25.3 nginx-deployment.yaml

# Just fetch digest without updating
./update-image-digest.sh postgres 15.4 /dev/null
```

### Integration with GitOps Workflow

```bash
# 1. Check for new image versions
./update-image-digest.sh adminer 4.8.1 deployment.yaml

# 2. Review changes
git diff deployment.yaml

# 3. Commit and push
git add deployment.yaml
git commit -m "Update Adminer to digest sha256:b3025d91..."
git push

# 4. Flux reconciles automatically
flux reconcile kustomization adminer
```

## Flux Image Automation (Advanced)

For automated digest updates when new images are released:

### Install Flux Image Automation Controllers

```bash
flux install --components-extra=image-reflector-controller,image-automation-controller
```

### Configure Image Repository Scanning

```yaml
# adminer-image-repo.yaml
apiVersion: image.toolkit.fluxcd.io/v1beta2
kind: ImageRepository
metadata:
  name: adminer
  namespace: flux-system
spec:
  image: docker.io/adminer
  interval: 10m
  secretRef:
    name: docker-registry-creds  # Optional, for private registries
---
# adminer-image-policy.yaml
apiVersion: image.toolkit.fluxcd.io/v1beta2
kind: ImagePolicy
metadata:
  name: adminer
  namespace: flux-system
spec:
  imageRepositoryRef:
    name: adminer
  policy:
    semver:
      range: 4.8.x  # Only patch updates
  filterTags:
    pattern: '^[0-9]+\.[0-9]+\.[0-9]+$'  # Only semantic versions
```

### Annotate Deployment for Auto-Update

```yaml
# deployment.yaml
spec:
  template:
    spec:
      containers:
      - name: adminer
        image: adminer:4.8.1@sha256:b3025d9191b6e29b327c69394a7ebee20e25e98a0f68b570f23e0e860655a4fb # {"$imagepolicy": "flux-system:adminer"}
```

### Configure Auto-Commit

```yaml
# adminer-image-update.yaml
apiVersion: image.toolkit.fluxcd.io/v1beta1
kind: ImageUpdateAutomation
metadata:
  name: adminer
  namespace: flux-system
spec:
  interval: 30m
  sourceRef:
    kind: GitRepository
    name: flux-system
  git:
    checkout:
      ref:
        branch: main
    commit:
      author:
        email: fluxcdbot@users.noreply.github.com
        name: fluxcdbot
      messageTemplate: |
        Automated image update
        
        Automation name: {{ .AutomationObject }}
        
        Files:
        {{ range $filename, $_ := .Updated.Files -}}
        - {{ $filename }}
        {{ end -}}
        
        Objects:
        {{ range $resource, $_ := .Updated.Objects -}}
        - {{ $resource.Kind }} {{ $resource.Name }}
        {{ end -}}
        
        Images:
        {{ range .Updated.Images -}}
        - {{.}}
        {{ end -}}
  update:
    path: ./apps/adminer
    strategy: Setters
```

## Verification

### Verify Digest in Running Pod

```bash
# Get the running container's digest
kubectl get pod -n adminer -l app=adminer -o jsonpath='{.items[0].status.containerStatuses[0].imageID}'

# Compare with deployment spec
kubectl get deployment adminer -n adminer -o jsonpath='{.spec.template.spec.containers[0].image}'
```

### Verify Image Integrity

```bash
# Pull by digest
docker pull adminer@sha256:b3025d9191b6e29b327c69394a7ebee20e25e98a0f68b570f23e0e860655a4fb

# Verify it matches the tag
docker pull adminer:4.8.1

# Compare digests
docker inspect --format='{{index .RepoDigests 0}}' adminer:4.8.1
```

## Security Scanning with Digests

### Trivy Scanning

```bash
# Scan by digest for accurate results
trivy image adminer@sha256:b3025d9191b6e29b327c69394a7ebee20e25e98a0f68b570f23e0e860655a4fb

# Compare with tag-based scan
trivy image adminer:4.8.1
```

### Policy Enforcement with Kyverno

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-image-digest
spec:
  validationFailureAction: enforce
  rules:
  - name: check-image-digest
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "Images must use digests (@sha256:...)"
      pattern:
        spec:
          containers:
          - image: "*@sha256:*"
```

### Admission Controller with OPA Gatekeeper

```yaml
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: requirdigest
spec:
  crd:
    spec:
      names:
        kind: RequirDigest
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package requirdigest
        
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          not contains(container.image, "@sha256:")
          msg := sprintf("Container %v must use digest", [container.name])
        }
```

## Troubleshooting

### Issue: Digest Not Found

```bash
# Error: manifest unknown
# Solution: Ensure the tag exists
docker pull adminer:4.8.1

# Verify tag exists in registry
skopeo list-tags docker://docker.io/adminer | grep 4.8.1
```

### Issue: ImagePullBackOff with Digest

```bash
# Check pod events
kubectl describe pod -n adminer -l app=adminer

# Common causes:
# 1. Digest doesn't exist in registry
# 2. Private registry authentication issues
# 3. Network policy blocking registry access

# Verify digest exists
crane digest adminer:4.8.1
```

### Issue: Flux Not Reconciling Updated Digest

```bash
# Force reconciliation
flux reconcile kustomization adminer --with-source

# Check Flux logs
kubectl logs -n flux-system deploy/kustomize-controller -f

# Verify image policy status
flux get image policy adminer
```

## Best Practices

### 1. Pin All Images with Digests
```yaml
# ✅ Good: Tag + Digest
image: adminer:4.8.1@sha256:b3025d9191b6e29b327c69394a7ebee20e25e98a0f68b570f23e0e860655a4fb

# ⚠️ Acceptable: Digest only (less readable)
image: adminer@sha256:b3025d9191b6e29b327c69394a7ebee20e25e98a0f68b570f23e0e860655a4fb

# ❌ Bad: Tag only (mutable)
image: adminer:4.8.1

# ❌ Terrible: Latest tag (never use in production)
image: adminer:latest
```

### 2. Document Digest Updates in Git Commits

```bash
git commit -m "Update Adminer from sha256:abc123... to sha256:def456...

- Security patches included
- Trivy scan results: 0 critical, 0 high
- Tested in staging environment
- Changelog: https://github.com/vrana/adminer/releases/tag/v4.8.1"
```

### 3. Test Digest Changes Before Production

```bash
# 1. Update digest in staging overlay
cat > apps/adminer/overlays/staging/kustomization.yaml <<EOF
images:
- name: adminer
  newName: adminer
  digest: sha256:NEW_DIGEST_HERE
EOF

# 2. Deploy to staging
flux reconcile kustomization adminer-staging

# 3. Run tests
kubectl exec -n adminer-staging deploy/adminer -- adminer --version

# 4. If successful, update production
```

### 4. Monitor Digest Changes

Create alerts for unexpected image changes:

```yaml
# PrometheusRule for image digest changes
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: image-digest-monitoring
spec:
  groups:
  - name: image-integrity
    rules:
    - alert: UnexpectedImageDigestChange
      expr: |
        changes(kube_pod_container_status_image_id{namespace="adminer"}[5m]) > 0
        unless on(pod) 
        changes(kube_deployment_spec_replicas{namespace="adminer"}[5m]) > 0
      labels:
        severity: warning
      annotations:
        summary: "Pod image changed without deployment update"
```

### 5. Regularly Update Digests

```bash
# Weekly check for updates
0 0 * * 0 /path/to/update-image-digest.sh adminer 4.8.1 /path/to/deployment.yaml
```

### 6. Use Renovate Bot for Automated PRs

```json
// renovate.json
{
  "extends": ["config:base"],
  "kubernetes": {
    "fileMatch": ["\\.yaml$"],
    "pinDigests": true
  },
  "packageRules": [
    {
      "matchDatasources": ["docker"],
      "matchPackageNames": ["adminer"],
      "automerge": false,
      "schedule": ["before 4am on monday"]
    }
  ]
}
```

## Migration from Tags to Digests

For existing deployments using tags:

```bash
# 1. Backup current deployment
kubectl get deployment adminer -n adminer -o yaml > adminer-backup.yaml

# 2. Get current running digest
CURRENT_DIGEST=$(kubectl get pod -n adminer -l app=adminer -o jsonpath='{.items[0].status.containerStatuses[0].imageID}' | cut -d'@' -f2)

# 3. Update deployment with digest
kubectl patch deployment adminer -n adminer --type='json' -p='[
  {
    "op": "replace",
    "path": "/spec/template/spec/containers/0/image",
    "value": "adminer:4.8.1@'$CURRENT_DIGEST'"
  }
]'

# 4. Verify
kubectl get deployment adminer -n adminer -o jsonpath='{.spec.template.spec.containers[0].image}'
```

## Additional Resources

- [Kubernetes Image Pull Policy](https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy)
- [Flux Image Automation](https://fluxcd.io/flux/guides/image-update/)
- [Sigstore Cosign](https://docs.sigstore.dev/cosign/overview/) - Image signing
- [The Update Framework (TUF)](https://theupdateframework.io/) - Secure updates
- [Notary v2](https://github.com/notaryproject/notaryproject) - Supply chain security
- [Docker Content Trust](https://docs.docker.com/engine/security/trust/)

## Summary

Using image digests is a critical security practice that ensures:
- **Immutability**: Images cannot be silently replaced
- **Reproducibility**: Clusters can be rebuilt identically
- **Auditability**: Exact image versions are tracked
- **Security**: Supply chain attacks are mitigated

The provided tools and automation make digest management straightforward while maintaining the security and reproducibility benefits critical for your home lab infrastructure.
