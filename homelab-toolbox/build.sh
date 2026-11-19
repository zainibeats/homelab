#!/usr/bin/env bash
# Build the homelab-toolbox image with the versions pinned in versions.env.
# Usage: ./build.sh [extra docker build args, e.g. --platform linux/arm64 or --no-cache]
set -euo pipefail
IFS=$'\n\t'

# ---- CONFIG ----
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
IMAGE="${HOMELAB_BOX_IMAGE:-homelab-toolbox:latest}"
# UID of the in-image "ops" user. Must match the user who runs homelab-box,
# or the SSH agent socket and files written to /work won't line up.
BOX_UID="${HOMELAB_BOX_UID:-$(id -u)}"

# ---- MAIN ----
build_args=(--build-arg "UID=$BOX_UID")
while IFS='=' read -r key value || [[ -n "$key" ]]; do
  [[ -z "$key" || "$key" == \#* ]] && continue
  build_args+=(--build-arg "$key=$value")
done < "$SCRIPT_DIR/versions.env"

docker build "${build_args[@]}" --tag "$IMAGE" "$@" "$SCRIPT_DIR"
