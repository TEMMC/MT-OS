#!/usr/bin/env bash
# Fetch the exact already-built A04e kernel artifact; never compile a new Image.gz.
set -euo pipefail

REPO="TEMMC/MT-OS"
RUN_ID="41811886477"
ARTIFACT="a04e-kernel-build-diagnostics"
EXPECTED_SHA256="c0327e1a7bb6aac89188581e05d3fbe4db9543f15a9d5498bfb5b27b4b62bd3c"
EXPECTED_SHA512="3781c2b7d2a62372c56334dacfba191b78e2632baa61430454ede4410cdf183e5acd26ebb7d8c01b158e5845a2b72a9728f07472c9e2b88637432a1df00a1f48"

DEST="${1:?Usage: fetch-a04e-kernel-artifact.sh /path/to/linux-samsung-a04e/Image.gz}"
command -v gh >/dev/null || { echo "GitHub CLI (gh) is required" >&2; exit 1; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
gh run download "$RUN_ID" --repo "$REPO" --name "$ARTIFACT" --dir "$tmp"

image="$tmp/Image.gz"
test -s "$image" || { echo "Image.gz missing from kernel artifact" >&2; exit 1; }
printf '%s  %s\n' "$EXPECTED_SHA256" "$image" | sha256sum -c -
printf '%s  %s\n' "$EXPECTED_SHA512" "$image" | sha512sum -c -

install -D -m 0644 "$image" "$DEST"
echo "Installed verified prebuilt A04e Image.gz at $DEST"
echo "Kernel source commit: 7c1b304f2df8df4c85abe6fe84b8238d7521bd58"
echo "No kernel compilation was performed."
echo "NOTE: source artifact run $RUN_ID is retained only until 2026-11-18."
