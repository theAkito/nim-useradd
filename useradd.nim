##[
  Master Module
]##

when isMainModule:
  import
    useradd/meta,
    logging

  let logger = getLogger("useradd")
  logger.log(lvlNotice, "appVersion: " & appVersion)
  logger.log(lvlNotice, "appRevision: " & appRevision)
  logger.log(lvlNotice, "appDate: " & appDate)
