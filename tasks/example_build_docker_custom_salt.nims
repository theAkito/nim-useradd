#!/usr/bin/env nim
mode = ScriptMode.Silent
switch("hints", "off")

import common

const
  dockerTag = "testuseradd/custom_salt:example"
  dockerFile = "examples/custom_salt/custom_salt.Dockerfile"

execDockerExampleLifecycle(dockerTag, dockerFile)