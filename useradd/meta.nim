from logging import Level, ConsoleLogger, newConsoleLogger
from strutils import startsWith

const
  debug             * {.booldefine.} = false
  lineEnd           * {.strdefine.}  = "\n"
  defaultDateFormat * {.strdefine.}  = "yyyy-MM-dd'T'HH:mm:ss'.'fffffffff'Z'"
  logMsgPrefix      * {.strdefine.}  = "[$levelname]:[$datetime]"
  logMsgInter       * {.strdefine.}  = " ~ "
  logMsgSuffix      * {.strdefine.}  = " -> "
  appVersion        * {.strdefine.}  = "0.1.0"
  appRevision       * {.strdefine.}  = appVersion
  appDate           * {.strdefine.}  = appVersion
  configName        * {.strdefine.}  = "useradd.json"
  configPath        * {.strdefine.}  = ""
  configIndentation * {.intdefine.}  = 2
  sourcepage        * {.strdefine.}  = "https://github.com/theAkito/nim-useradd"
  homepage          * {.strdefine.}  = sourcepage
  wikipage          * {.strdefine.}  = sourcepage
  passwdPath        * {.strdefine.}  = "/etc/passwd"
  shadowPath        * {.strdefine.}  = "/etc/shadow"
  groupPath         * {.strdefine.}  = "/etc/group"
  cpuARM                           * = hostCPU.startsWith "arm"


func defineLogLevel*(): Level =
  if debug: lvlDebug else: lvlInfo

proc getLogger*(moduleName: string): ConsoleLogger =
  newConsoleLogger(defineLogLevel(), logMsgPrefix & logMsgInter & moduleName & logMsgSuffix)