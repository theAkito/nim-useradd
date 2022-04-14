import strformat

const
  dockerLabelExample = "testuseradd"

proc buildDocker*(tag, dockerfile: string) =
  ## Build Docker Image Example.
  exec &"""
    docker \
      build \
        --no-cache \
        --build-arg UID=9234 \
        --build-arg GID=9432 \
        -t {tag} \
        -f {dockerfile} \
      .
  """

proc runDocker*(tag: string) =
  ## Run Docker Image Example.
  exec &"""
    docker \
      run \
        -it \
      {tag}
  """

proc deleteExampleDockerArtifacts*() =
  ## Delete all related Docker Containers Examples, safely.
  discard gorge &"""docker container prune --force --filter "label={dockerLabelExample}" """
  ## Delete all related Docker Image Examples, safely.
  discard gorge &"""docker image prune --force --all --filter "label={dockerLabelExample}" """

proc execDockerExampleLifecycle*(tag, dockerfile: string) =
  ## Build Docker Image Example.
  buildDocker(tag, dockerFile)

  ## Run Docker Image Example.
  runDocker(tag)

  ## Delete Docker Example containers & images.
  deleteExampleDockerArtifacts()