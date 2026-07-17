#!/usr/bin/env bash
set -e

sudo rm -rf work

CACHE_DIR="$(pwd)/pacman-cache"

# Full clean
if [[ "$1" == "--clean" ]]; then
  sudo rm -rf out "$CACHE_DIR"
fi

# Setup packages
declare -A file_permissions
source "$(pwd)/profile/profiledef.sh"

BASE_PACKAGES_FILE="$(pwd)/profile/packages_base.$arch"
LIVE_PACKAGES_FILE="$(pwd)/profile/packages_live.$arch"
SYSTEM_LIVE_PACKAGES_FILE="$(pwd)/profile/airootfs/jappeos/packages_live"
OUT_PACKAGES_FILE="$(pwd)/profile/packages.$arch"

sudo cp "$LIVE_PACKAGES_FILE" "$SYSTEM_LIVE_PACKAGES_FILE"
sudo chown "root:root" "$SYSTEM_LIVE_PACKAGES_FILE"

{
  grep -vxFf "$LIVE_PACKAGES_FILE" "$BASE_PACKAGES_FILE"
  cat "$LIVE_PACKAGES_FILE"
} | grep -v '^[[:space:]]*$' > "$OUT_PACKAGES_FILE"

# Build
mkdir -p out work
docker build -t jappeos-build .
docker run --rm -it \
  --privileged \
  -v "$(pwd)/profile:/build" \
  -v "$(pwd)/out:/out" \
  -v "$(pwd)/work:/work" \
  -v "$(pwd)/pacman-cache:/var/cache/pacman/pkg" \
  jappeos-build \
  bash -c "mkarchiso -v -w /work -o /out /build"

sudo chown -R "$USER:$USER" out