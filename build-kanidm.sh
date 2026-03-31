#!/bin/bash
set -euo pipefail

# --- Configuration ---
RUST_VERSION="${RUST_VERSION:-1.94.0}"
AUR_PACKAGE="${AUR_PACKAGE:-kanidm}"
OUTPUT_DIR="./output"
IMAGE_NAME="kanidm-builder"

# --- Detect container runtime ---
if [[ -n "${RUNTIME:-}" ]]; then
    command -v "${RUNTIME}" &>/dev/null || { echo "Error: ${RUNTIME} not found." >&2; exit 1; }
elif command -v podman &>/dev/null; then
    RUNTIME="podman"
elif command -v docker &>/dev/null; then
    RUNTIME="docker"
else
    echo "Error: Neither podman nor docker found in PATH." >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMPDIR=$(mktemp -d)
trap 'rm -rf "${TMPDIR}"' EXIT

echo "Container runtime: ${RUNTIME}"
echo "Building AUR package: ${AUR_PACKAGE}"
echo "Rust version: ${RUST_VERSION}"

echo "==> Building container image..."
"${RUNTIME}" build \
    --build-arg RUST_VERSION="${RUST_VERSION}" \
    --build-arg AUR_PACKAGE="${AUR_PACKAGE}" \
    -t "${IMAGE_NAME}" \
    -f "${SCRIPT_DIR}/Dockerfile" \
    "${SCRIPT_DIR}"

# --- Extract the package ---
echo "==> Extracting built package..."
mkdir -p "${OUTPUT_DIR}"
CONTAINER_ID=$("${RUNTIME}" create "${IMAGE_NAME}")
"${RUNTIME}" cp "${CONTAINER_ID}:/home/builder/build/" "${TMPDIR}/pkg"
"${RUNTIME}" rm "${CONTAINER_ID}" > /dev/null

# Copy only the .pkg.tar.zst files
find "${TMPDIR}/pkg" -name "*.pkg.tar.zst" -exec cp {} "${OUTPUT_DIR}/" \;

echo "==> Done! Packages:"
ls -1 "${OUTPUT_DIR}"/*.pkg.tar.zst
echo ""
echo "Install with:  sudo pacman -U ${OUTPUT_DIR}/*.pkg.tar.zst"
