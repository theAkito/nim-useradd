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
    -t testuseradd/custom_salt:example \
    -f examples/custom_salt/custom_salt.Dockerfile \
  .
"""
## Run Docker Image Example.
exec """
docker \
  run \
    -it \
  testuseradd/custom_salt:example
"""

## Delete all related Docker Containers Examples, safely.
discard gorge """docker container prune --force --filter "label=testuseradd""""
## Delete all Docker Image Examples, safely.
discard gorge """docker image prune --force --all --filter "label=testuseradd""""