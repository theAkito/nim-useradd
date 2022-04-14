#!/usr/bin/env nim
mode = ScriptMode.Silent
switch("hints", "off")

## Build Docker Image Example.
exec """
docker \
  build \
    --no-cache \
    --build-arg UID=9234 \
    --build-arg GID=9432 \
    -t testuseradd/simple:example \
    -f examples/simple/simple.Dockerfile \
  .
"""
## Run Docker Image Example.
exec """
docker \
  run \
    -it \
  testuseradd/simple:example
"""

## Delete all related Docker Containers Examples, safely.
discard gorge """docker container prune --force --filter "label=testuseradd""""
## Delete all related Docker Image Examples, safely.
discard gorge """docker image prune --force --all --filter "label=testuseradd""""