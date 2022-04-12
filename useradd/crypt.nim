##[
  Password Encryption Module

  https://linux.die.net/man/3/crypt

  Glibc notes
    The glibc2 version of this function supports additional encryption algorithms.

    If salt is a character string starting with the characters "$id$" followed by a string terminated by "$":
        $id$salt$encrypted 
    then instead of using the DES machine, id identifies the encryption method used and this then determines how the rest of the password string is interpreted. The following values of id are supported:
    So $5$salt$encrypted is an SHA-256 encoded password and $6$salt$encrypted is an SHA-512 encoded one.

    "salt" stands for the up to 16 characters following "$id$" in the salt. The encrypted part of the password string is the actual computed password. The size of this string is fixed:

    The characters in "salt" and "encrypted" are drawn from the set [a-zA-Z0-9./]. In the MD5 and SHA implementations the entire key is significant (instead of only the first 8 bytes in DES).
]##

import
  std/[
    strutils,
    sequtils,
    sysrand
  ]

from posix import crypt

const
  rawBytePoolSize = 1024
  saltCharAmount = 16
  delimiter = '$'
  idNumSHA512 = '6'
  idSHA512 = delimiter & idNumSHA512 & delimiter

func toChar(bytes: seq[byte]): seq[char] = bytes.mapIt(it.chr)
func getASCII(input: seq[char]): seq[char] = input.filterIt(it.isAlphaAscii)
func getMaxSaltAmount(input: seq[char], amount: int): seq[char] = input[0..amount-1]
func getSaltFull(salt: string): cstring = cstring(idSHA512 & salt)
proc crypt(salt: cstring, password: string): cstring = password.crypt(salt)
proc encrypt*(password, salt: string): cstring = salt.crypt(password) ## Expects full salt, according to this pattern: $id$salt$

proc encrypt*(password: string): cstring =
  ## Encrypts password with random salt.
  ## Salt is 16 characters long and is drawn from the set [a-zA-Z0-9./].
  ## Uses the SHA512 algorithm to encrypt the actual password.
  ## Check out the manual for more information:
  ## https://linux.die.net/man/3/crypt
  urandom(rawBytePoolSize)
    .toChar()
    .getASCII()
    .getMaxSaltAmount(saltCharAmount)
    .join()
    .getSaltFull()
    .crypt(password)


when isMainModule:
  let
    pw: cstring = "hello"
    pwString = "hello"
    rawBytes = urandom(rawBytePoolSize)
    charBytes = rawBytes.toChar()
    asciiCharBytes = charBytes.getASCII
    asciiCharBytesLimited = asciiCharBytes.getMaxSaltAmount(saltCharAmount)
    saltString = asciiCharBytesLimited.join()
    salt = cstring(idSHA512 & saltString)
  echo()
  echo "salt:                     " & $salt
  echo "salt.len-3:               " & $(salt.len-3)
  echo()
  echo "Crypt Result:             " & $pw.crypt(salt)
  echo "Auto-Crypt Result:        " & $pwString.encrypt()