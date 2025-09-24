#!/usr/bin/env bash
set -e

sudo rm -rf out work
mkdir -p out work

docker build -t jappeos-build .

docker run --rm -it \
  --privileged \
  -v "$(pwd)/profile:/build" \
  -v "$(pwd)/out:/out" \
  -v "$(pwd)/work:/work" \
  jappeos-build \
  bash -c "mkarchiso -v -w /work -o /out /build"

sudo chown -R $USER:$USER out