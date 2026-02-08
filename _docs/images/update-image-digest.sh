#!/usr/bin/env bash
# Script to fetch and update image digests in Kubernetes manifests
# This ensures immutable image references for security and reproducibility

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to get image digest using docker
get_digest_docker() {
    local image="$1"
    echo -e "${YELLOW}Pulling image: ${image}${NC}"
    docker pull "${image}" >/dev/null 2>&1
    docker inspect --format='{{index .RepoDigests 0}}' "${image}" | cut -d'@' -f2
}

# Function to get image digest using skopeo (doesn't require docker daemon)
get_digest_skopeo() {
    local image="$1"
    echo -e "${YELLOW}Inspecting image: ${image}${NC}"
    skopeo inspect "docker://${image}" | jq -r '.Digest'
}

# Function to get image digest using crane (lightweight)
get_digest_crane() {
    local image="$1"
    echo -e "${YELLOW}Fetching digest: ${image}${NC}"
    crane digest "${image}"
}

# Function to get digest using the best available tool
get_digest() {
    local image="$1"
    local digest=""
    
    if command -v crane &> /dev/null; then
        digest=$(get_digest_crane "${image}")
    elif command -v skopeo &> /dev/null; then
        digest=$(get_digest_skopeo "${image}")
    elif command -v docker &> /dev/null; then
        digest=$(get_digest_docker "${image}")
    else
        echo -e "${RED}Error: No suitable tool found. Install docker, skopeo, or crane.${NC}"
        exit 1
    fi
    
    echo "${digest}"
}

# Function to update deployment manifest
update_manifest() {
    local manifest_file="$1"
    local image_name="$2"
    local image_tag="$3"
    local digest="$4"
    
    # Full image reference with digest
    local full_image="${image_name}:${image_tag}@${digest}"
    
    echo -e "${GREEN}Updating ${manifest_file}${NC}"
    echo -e "  Image: ${full_image}"
    
    # Backup original file
    cp "${manifest_file}" "${manifest_file}.bak"
    
    # Update the image line (handles various formatting)
    sed -i.tmp "s|image: ${image_name}:${image_tag}.*|image: ${full_image}|g" "${manifest_file}"
    rm -f "${manifest_file}.tmp"
    
    echo -e "${GREEN}✓ Updated successfully${NC}"
    echo -e "${YELLOW}Backup saved to: ${manifest_file}.bak${NC}"
}

# Main execution
main() {
    local image_name="${1:-adminer}"
    local image_tag="${2:-4.8.1}"
    local manifest="${3:-deployment.yaml}"
    
    echo "===================================="
    echo "Image Digest Updater"
    echo "===================================="
    echo ""
    
    # Get the digest
    echo -e "${YELLOW}Fetching digest for ${image_name}:${image_tag}${NC}"
    digest=$(get_digest "${image_name}:${image_tag}")
    
    if [ -z "${digest}" ]; then
        echo -e "${RED}Error: Failed to fetch digest${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Digest: ${digest}${NC}"
    echo ""
    
    # Update manifest if it exists
    if [ -f "${manifest}" ]; then
        update_manifest "${manifest}" "${image_name}" "${image_tag}" "${digest}"
    else
        echo -e "${YELLOW}Warning: Manifest file ${manifest} not found${NC}"
        echo -e "Full image reference: ${image_name}:${image_tag}@${digest}"
    fi
    
    echo ""
    echo "===================================="
    echo -e "${GREEN}✓ Complete${NC}"
    echo "===================================="
}

# Show usage
usage() {
    cat <<EOF
Usage: $0 [IMAGE_NAME] [IMAGE_TAG] [MANIFEST_FILE]

Fetches the SHA256 digest for a container image and updates the Kubernetes manifest.

Arguments:
  IMAGE_NAME     Container image name (default: adminer)
  IMAGE_TAG      Image tag (default: 4.8.1)
  MANIFEST_FILE  Path to deployment manifest (default: deployment.yaml)

Examples:
  # Update Adminer deployment with current digest
  $0

  # Update specific image
  $0 nginx 1.25.3 nginx-deployment.yaml

  # Just fetch digest without updating
  $0 postgres 15.4 /dev/null

Requirements:
  One of: docker, skopeo, or crane
  Optional: jq (for skopeo)

EOF
    exit 1
}

# Parse arguments
if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
fi

# Run main
main "$@"
