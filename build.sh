#!/usr/bin/env bash
set -e

sudo rm -rf work

CACHE_DIR="$(pwd)/pacman-cache"
STAMP="$CACHE_DIR/.last_refresh"
MAX_AGE_DAYS=7

# Weekly pacman cache invalidation
if [[ -d "$CACHE_DIR" && -f "$STAMP" ]]; then
  LAST_UPDATE=$(cat "$STAMP")
  NOW=$(date +%s)
  AGE_DAYS=$(( (NOW - LAST_UPDATE) / 86400 ))

  if (( AGE_DAYS > MAX_AGE_DAYS )); then
    echo "Pacman cache is old ($AGE_DAYS days), clearing..."
    rm -rf "$CACHE_DIR"
  fi
fi

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

# Mark successful cache usage
mkdir -p "$CACHE_DIR"
date +%s > "$STAMP"  # TODO: Fix permission denied

sudo chown -R "$USER:$USER" out