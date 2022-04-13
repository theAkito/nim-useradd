##[
  Master Module
]##

import
  useradd/[
    meta,
    utils,
    crypt
  ],
  std/[
    times,
    strformat,
    strutils,
    posix
  ]

##[
  Passwd File Information
  =======================

  testuser:x:99123:99321::/home/testuser:/bin/bash
      1   :2:  3  :  4  :5:       6     :    7

  1. Username, up to 8 characters. Case-sensitive, usually all lowercase
  2. An "x" in the password field. Passwords are stored in the ``/etc/shadow'' file.
  3. Numeric user id. This is assigned by the ``adduser'' script. Unix uses this field, plus the following group field, to identify which files belong to the user.
  4. Numeric group id. Red Hat uses group id's in a fairly unique manner for enhanced file security. Usually the group id will match the user id.
  5. https://www.redhat.com/sysadmin/linux-gecos-demystified
  6. User's home directory. Usually /home/username (eg. /home/smithj). All user's personal files, web pages, mail forwarding, etc. will be stored here.
  7. User's "shell account". Often set to ``/bin/bash'' to provide access to the bash shell.

  https://tldp.org/LDP/lame/LAME/linux-admin-made-easy/shadow-file-formats.html
]##

##[
  Shadow API Information
  ======================

  The putspent() function writes the contents of the supplied struct spwd *p as a text line in the shadow password file format to the stream fp.
  String entries with value NULL and numerical entries with value -1 are written as an empty string. 

  The lckpwdf() function is intended to protect against multiple simultaneous accesses of the shadow password database.
  It tries to acquire a lock, and returns 0 on success, or -1 on failure (lock not obtained within 15 seconds).
  The ulckpwdf() function releases the lock again.
  Note that there is no protection against direct access of the shadow password file.
  Only programs that use lckpwdf() will notice the lock.

  https://linux.die.net/man/3/putspent
]##

##[
  Shadow File Information
  =======================

  struct spwd {
    char *sp_namp;     /* Login name */
    char *sp_pwdp;     /* Encrypted password */
    long  sp_lstchg;   /* Date of last change
                          (measured in days since
                          1970-01-01 00:00:00 +0000 (UTC)) */
    long  sp_min;      /* Min # of days between changes */
    long  sp_max;      /* Max # of days between changes */
    long  sp_warn;     /* # of days before password expires
                          to warn user to change it */
    long  sp_inact;    /* # of days after password expires
                          until account is disabled */
    long  sp_expire;   /* Date when account expires
                          (measured in days since
                          1970-01-01 00:00:00 +0000 (UTC)) */
    unsigned long sp_flag;  /* Reserved */
  };


  testuser:$6$FCIBNRCTLwRrEErx$coMD2oCFWgtH7SzwNQnXo8D3ngexpLVpLkiYmw70zh7/Vc8xIOrpXEMDqgw.890JW2C/IJmIu6tsX/6hC/qBB.:19095:0:99999:7:::
      1   :                                                           2                                              :  3  :4:  5  :6:7:8:9

  1. Username, up to 8 characters. Case-sensitive, usually all lowercase. A direct match to the username in the /etc/passwd file.
  2. Password, 13 character encrypted. A blank entry (eg. ::) indicates a password is not required to log in (usually a bad idea), and a ``*'' entry (eg. :*:) indicates the account has been disabled.
  3. The number of days (since January 1, 1970) since the password was last changed.
  4. The number of days before password may be changed (0 indicates it may be changed at any time).
  5. The number of days after which password must be changed (99999 indicates user can keep his or her password unchanged for many, many years).
  6. The number of days to warn user of an expiring password (7 for a full week).
  7. The number of days after password expires that account is disabled.
  8. The number of days since January 1, 1970 that an account has been disabled.
  9. A reserved field for possible future use.

  https://tldp.org/LDP/lame/LAME/linux-admin-made-easy/shadow-file-formats.html


  Special Characters instead of a password hash may have a special meaning and implication:
    https://superuser.com/a/623882
]##

type
  Shadow* {.importc: "struct spwd", header: "<shadow.h>", final, pure.} = object
    sp_namp   : cstring
    sp_pwdp   : cstring
    sp_lstchg : clong
    sp_min    : clong
    sp_max    : clong
    sp_warn   : clong
    sp_inact  : clong
    sp_expire : clong
    sp_flag   : culong

const
  pwPlaceholder = "x"
  shadowNoValue = -1           ## Results in no value at all being written for the key which has this default value assigned in the Shadow structure.
  shadowMinDays = 0            ## Default value in most Linux deployments
  shadowExpireDays = 99999     ## Default value in most Linux deployments
  shadowWarnDays = 7           ## Default value in most Linux deployments

let
  logger = getLogger("useradd")
  timestamp = now().toTime.toUnix div 60 div 60 div 24 ## https://stackoverflow.com/questions/1094291/get-current-date-in-epoch-from-unix-shell-script/1094354#1094354

proc putpwent(p: ptr Passwd, stream: File): int {.importc, header: "<pwd.h>", sideEffect.} ## https://linux.die.net/man/3/putpwent
proc putspent(p: ptr Shadow, fp: File): int {.importc, header: "<shadow.h>", sideEffect.} ## https://linux.die.net/man/3/putspent
proc putgrent(grp: ptr Group, fp: File): int {.importc, header: "<grp.h>", sideEffect.} ## https://linux.die.net/man/3/putgrent

proc readPasswd(): seq[ptr Passwd] =
  ## Reads all password entries from `/etc/passwd`.
  var currentPwEnt: ptr Passwd
  while true:
    currentPwEnt = getpwent()
    if currentPwEnt == nil: break
    result.add currentPwEnt
  endpwent()

proc addUser(entry: ptr Passwd): bool =
  let passwdFile = passwdPath.open(mode = fmAppend)
  defer: passwdFile.close
  putpwent(entry, passwdFile) == 0

proc addShadow(entry: ptr Shadow): bool =
  let shadowFile = shadowPath.open(mode = fmAppend)
  defer: shadowFile.close
  putspent(entry, shadowFile) == 0

proc addGroup(entry: ptr Group): bool =
  let grpFile = groupPath.open(mode = fmAppend)
  defer: grpFile.close
  putgrent(entry, grpFile) == 0

proc addUser*(name: string, uid, gid: int, home: string, shell = "", pw = "", pwIsEncrypted = false, gecos = ""): bool {.discardable.} =
  ## Adds an OS user the official C API way.
  # TODO: lckpwdf()
  # TODO Check if UID is duplicate before adding this user.
  var
    realGid = gid.Gid
    passwd = Passwd(
      pw_name: name,
      pw_passwd: pwPlaceholder, ## Password will always be in shadow. I.e. we reference that fact with the default placeholder.
      pw_uid: uid.Uid,
      pw_gid: realGid,
      pw_gecos: gecos, # https://www.redhat.com/sysadmin/linux-gecos-demystified
      pw_dir: home,
      pw_shell: shell
    )
    grpMembers = @[name].allocCStringArray
    grp = Group(
      gr_name: name,
      gr_passwd: pw,
      gr_gid: realGid,
      gr_mem: grpMembers
    )
    pwEnc: cstring = if pwIsEncrypted or pw.isEmptyOrWhitespace: pw.cstring else: pw.encrypt()
    shadow = Shadow(
      sp_namp   : name,              ## Username, up to 8 characters. Case-sensitive, usually all lowercase. A direct match to the username in the /etc/passwd file.
      sp_pwdp   : pwEnc,             ## Password, encrypted. A blank entry (eg. ::) indicates a password is not required to log in (usually a bad idea), and a ``*'' entry (eg. :*:) indicates the account has been disabled.
      sp_lstchg : timestamp.int,     ## The number of days (since January 1, 1970) since the password was last changed.
      sp_min    : shadowMinDays,     ## The number of days before password may be changed (0 indicates it may be changed at any time)
      sp_max    : shadowExpireDays,  ## The number of days after which password must be changed (99999 indicates user can keep his or her password unchanged for many, many years)
      sp_warn   : shadowWarnDays,    ## The number of days to warn user of an expiring password (7 for a full week)
      sp_inact  : shadowNoValue,     ## The number of days after password expires that account is disabled
      sp_expire : shadowNoValue,     ## The number of days since January 1, 1970 that an account has been disabled
      sp_flag   : cast[culong](shadowNoValue) # This cast is the only way to NOT make a 0 appear, instead of nothing. Example: `testuser:$6$FCIBNRCTLwRrEErx$coMD2oCFWgtH7SzwNQnXo8D3ngexpLVpLkiYmw70zh7/Vc8xIOrpXEMDqgw.890JW2C/IJmIu6tsX/6hC/qBB.:19094:0:99999:7:::0` is wrong. `testuser:$6$FCIBNRCTLwRrEErx$coMD2oCFWgtH7SzwNQnXo8D3ngexpLVpLkiYmw70zh7/Vc8xIOrpXEMDqgw.890JW2C/IJmIu6tsX/6hC/qBB.:19094:0:99999:7:::` is correct.
    )
  defer: grpMembers.deallocCStringArray
  addUser(passwd.addr) and addGroup(grp.addr) and addShadow(shadow.addr)

proc addUserMan*(name: string, uid, gid: int, home: string, shell = "", pw = pwPlaceholder, pwIsEncrypted = false, gecos = "") =
  ## Adds an OS user the manual way, by appending a user entry to `/etc/passwd`, `/etc/shadow` and
  ## a corresponding group entry to `/etc/group`.
  ##
  ## This manual method guarantees, that IDs consisting of numbers larger than
  ## 256000 are successfully applied, when creating a user.
  ## In Alpine's BusyBox version of `adduser` this is a general restriction,
  ## which can (relatively) safely by avoided by adding an `/etc/passwd` entry,
  ## manually, by editing the file directly.
  ##
  ## For more information on this topic visit the following references.
  ## https://stackoverflow.com/a/42133612/1483861
  ## https://github.com/docksal/unison/issues/5
  ## https://github.com/docksal/unison/pull/1/files
  ## https://github.com/docksal/unison/pull/7
  ## https://github.com/docksal/unison/pull/1#issuecomment-471114725
  let
    passwdFile = passwdPath.open(mode = fmAppend)
    shadowFile = shadowPath.open(mode = fmAppend)
    groupFile = groupPath.open(mode = fmAppend)
    passwdLines = @[
      &"{name}:{pw}:{uid}:{gid}:{gecos}:{home}:"
    ]
    shadowLines = @[
      &"{name}:!:{timestamp}:0:99999:7:::"
    ]
    groupLines = @[
      &"{name}:{pw}:{gid}:{name}"
    ]
  defer: passwdFile.close
  defer: shadowFile.close
  defer: groupFile.close
  passwdFile.writeLines(passwdLines)
  shadowFile.writeLines(shadowLines)
  groupFile.writeLines(groupLines)

proc deleteUser*(name: string) =
  ## Deletes a user by manually deleting its entry from `/etc/passwd`, `/etc/shadow` and
  ## a corresponding group entry from `/etc/group`.
  let
    nameMatch = name & ":"
    passwdContent = utils.readLines(passwdPath)
    shadowContent = utils.readLines(shadowPath)
    groupContent = utils.readLines(groupPath)
    passwdContentClean = passwdContent.filterNotStartsWith(nameMatch)
    shadowContentClean = shadowContent.filterNotStartsWith(nameMatch)
    groupContentClean = groupContent.filterNotStartsWith(nameMatch)
  passwdPath.writeFile(passwdContentClean.join(lineEnd))
  shadowPath.writeFile(shadowContentClean.join(lineEnd))
  groupPath.writeFile(groupContentClean.join(lineEnd))


when isMainModule:
  const test_password_enc = "$6$FCIBNRCTLwRrEErx$coMD2oCFWgtH7SzwNQnXo8D3ngexpLVpLkiYmw70zh7/Vc8xIOrpXEMDqgw.890JW2C/IJmIu6tsX/6hC/qBB."
  echo "Success: " & $addUser(
    "testuser",
    99123,
    99321,
    "/home/testuser",
    pw = test_password_enc,
    pwIsEncrypted = true
  )