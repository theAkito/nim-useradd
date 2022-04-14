import
  useradd,
  useradd/crypt,
  useradd/utils

const
  password = "hello"
  salt = "$6$mycustomsaltidxi$"

let pwEnc = encrypt(password, salt).toDedicated(106)

echo "Password in Shadow format with fixed  Salt #1: " & $pwEnc
echo "Password in Shadow format with random Salt #1: " & $encrypt(password)
echo "Password in Shadow format with fixed  Salt #2: " & $encrypt(password, salt)
echo "Password in Shadow format with random Salt #2: " & $encrypt(password)

echo "Success adding user with self-salted password: " & $addUser(
  name = "mygenericusername",
  uid = 99121,
  gid = 99322,
  home = "/home/mygenericusername",
  pw = $encrypt(password, salt),
  pwIsEncrypted = true
)