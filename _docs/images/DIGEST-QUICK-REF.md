# Image Digest Quick Reference

## Get Image Digest

```bash
# Docker (requires daemon)
docker pull adminer:4.8.1 && docker inspect --format='{{index .RepoDigests 0}}' adminer:4.8.1

# Skopeo (no daemon required)
skopeo inspect docker://docker.io/adminer:4.8.1 | jq -r '.Digest'

# Crane (lightweight)
crane digest adminer:4.8.1

# Using provided script
./update-image-digest.sh adminer 4.8.1 deployment.yaml
```

## Current Adminer Digest

```
adminer:4.8.1@sha256:b3025d9191b6e29b327c69394a7ebee20e25e98a0f68b570f23e0e860655a4fb
```

## Verify Running Pod

```bash
# Get digest from running pod
kubectl get pod -n adminer -l app=adminer \
  -o jsonpath='{.items[0].status.containerStatuses[0].imageID}'

# Compare with deployment
kubectl get deployment adminer -n adminer \
  -o jsonpath='{.spec.template.spec.containers[0].image}'
```

## Update Workflow

```bash
# 1. Get new digest
./update-image-digest.sh adminer 4.8.1 deployment.yaml

# 2. Review changes
git diff deployment.yaml

# 3. Commit
git add deployment.yaml
git commit -m "Update Adminer digest to sha256:..."

# 4. Push and reconcile
git push
flux reconcile kustomization adminer
```

## Security Scanning

```bash
# Scan by digest
trivy image adminer@sha256:b3025d9191b6e29b327c69394a7ebee20e25e98a0f68b570f23e0e860655a4fb

# Scan current deployment
kubectl get deployment adminer -n adminer -o jsonpath='{.spec.template.spec.containers[0].image}' | xargs trivy image
```

## Image Format

```yaml
# ✅ Best: Tag + Digest (readable + secure)
image: adminer:4.8.1@sha256:b3025d9191b6e29b327c69394a7ebee20e25e98a0f68b570f23e0e860655a4fb

# ⚠️ Acceptable: Digest only
image: adminer@sha256:b3025d9191b6e29b327c69394a7ebee20e25e98a0f68b570f23e0e860655a4fb

# ❌ Avoid: Tag only (mutable)
image: adminer:4.8.1
```

## Troubleshooting

```bash
# Digest not pulling
docker pull adminer@sha256:b3025d9191b6e29b327c69394a7ebee20e25e98a0f68b570f23e0e860655a4fb

# Check registry
skopeo list-tags docker://docker.io/adminer | grep 4.8.1

# Test manifest exists
crane manifest adminer:4.8.1 | jq -r '.config.digest'
```

---
**For detailed documentation see: IMAGE-DIGEST-GUIDE.md**
