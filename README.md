[![Nimble](https://raw.githubusercontent.com/yglukhov/nimble-tag/master/nimble.png)](https://nimble.directory/pkg/useradd)

[![Source](https://img.shields.io/badge/project-source-2a2f33?style=plastic)](https://github.com/theAkito/nim-useradd)
[![Language](https://img.shields.io/badge/language-Nim-orange.svg?style=plastic)](https://nim-lang.org/)

![Last Commit](https://img.shields.io/github/last-commit/theAkito/nim-useradd?style=plastic)

[![GitHub](https://img.shields.io/badge/license-GPL--3.0-informational?style=plastic)](https://www.gnu.org/licenses/gpl-3.0.txt)
[![Liberapay patrons](https://img.shields.io/liberapay/patrons/Akito?style=plastic)](https://liberapay.com/Akito/)

## What
This is an extended `adduser`/`useradd` [Nim](https://nim-lang.org/) library with batteries included.

It takes care of password encryption, file locking during user modification and so on.

You don't have to take care of anything. Just add or remove your user and that's it. No effort on your part needed!

## Why
Low-level user management without a CLI tool in Linux (and UNIX in general) is a pain. You have to know a lot of stuff. You can *very easily* break one of the most important parts of the system, if you do one little mistake like fail to hash the password correctly.

Using the native C API to manage users is a huge pain in the way described above.
This module intends to take that effort and all those headaches away from you by entirely taking care of the C API bloat.

## How

First, install this library.
```nim
nimble install useradd
```

Make sure, you are linking your project during compilation with the [`crypt(3)`](https://linux.die.net/man/3/crypt) library.
```bash
nim c --passL="-lcrypt" example
```
### Usage Examples
#### Add User

Simplest Example:
```nim
import useradd

echo "Success: " & $addUser(
  name = "mygenericusername",
  uid = 99121, # No GID provided -> GID will be same as UID.
  home = "/home/testuserapi",
  pw = "myInsecurePassword"
)
```

A bit more advanced example:
```nim
import useradd

echo "Success: " & $addUser(
  name = "mygenericusername",
  uid = 99121,
  gid = 99322,
  home = "/home/testuserapi",
  pw = "myInsecurePassword"
)
```

An advanced example, with a pre-hashed password:

```nim
import useradd

echo "Success: " & $addUser(
  name = "mygenericusername",
  uid = 99121,
  gid = 99322,
  home = "/home/testuserapi",
  pw = "$6$FCIBNRCTLwRrEErx$coMD2oCFWgtH7SzwNQnXo8D3ngexpLVpLkiYmw70zh7/Vc8xIOrpXEMDqgw.890JW2C/IJmIu6tsX/6hC/qBB.",
  pwIsEncrypted = true
)
```

This is useful for migrating passwords from a Shadow database, where the actual passwords are unknown.

An advanced example, where the file operations are done manually, omitting the C API, in case the C API imposes any arbitrary limitations:

```nim
import useradd

echo "Success: " & $addUserMan( # Only the `proc` name changed. The API stays exactly the same!
  name = "mygenericusername",
  uid = 290111,
  gid = 290112,
  home = "/home/testuserapi",
  pw = "$6$FCIBNRCTLwRrEErx$coMD2oCFWgtH7SzwNQnXo8D3ngexpLVpLkiYmw70zh7/Vc8xIOrpXEMDqgw.890JW2C/IJmIu6tsX/6hC/qBB.",
  pwIsEncrypted = true
)
```

### Remove User

```nim
import useradd

echo "Success Delete User: " & $deleteUser("mygenericusername") # Deletes from `/etc/passwd`, `/etc/shadow` and `/etc/group` by name!
```

## Features
* Automatic File Locking -> Do not worry about corrupting `/etc/passwd`, `/etc/shadow` or `/etc/group`!
* Automatic Password Encryption -> Do not worry about properly hashing the password, if providing one!
* Convenient API -> For example, providing a UID but no GID, will assign the UID's value to the GID. It won't break your user creation!
* Optional Advanced API -> Migrating an existing `/etc/shadow` database? No, problem, just provide the password hashes and turn on `pwIsEncrypted`!
* Optional Advanced API -> Want to omit the C API and modify the databases directly, by reading/writing to the actual files? Just replace your `addUser` usages with `addUserMan` (same API)!

## Where
Linux.

Other UNIX derivatives might work, but are not officially supported.
This project is primarily supposed to work on Linux.

If you want to provide reliable macOS or *BSD support, go ahead I will check it out. But I only will accept it, if it does not reduce the quality of the Linux related implementation. (Hint: using `when`s is probably the way to go.)

## Goals
* Reliability
* Convenience

## Project Status
Stable Beta.

This library is well tested & works, but needs more testing and feedback from 3rd parties. --> Please help!

## TODO
* Track Project Tests with this Git repository.

## License
Copyright © 2022  Akito <the@akito.ooo>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.