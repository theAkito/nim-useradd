#!/usr/bin/env nim
mode = ScriptMode.Silent
switch("hints", "off")

import common

const
  dockerTag = "testuseradd/simple:example"
  dockerFile = "examples/simple/simple.Dockerfile"

execDockerExampleLifecycle(dockerTag, dockerFile)