import
  useradd,
  useradd/crypt

const
  password = "hello"
  salt = "$6$mycustomslt$"

echo encrypt(password)
echo encrypt(password, salt)

echo "Success: " & $addUser( # Add user with your own self-hashed password.
  name = "mygenericusername",
  uid = 99121,
  gid = 99322,
  home = "/home/mygenericusername",
  pw = $encrypt(password, salt),
  pwIsEncrypted = true
)