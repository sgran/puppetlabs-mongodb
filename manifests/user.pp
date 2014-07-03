# == Class: mongodb::user
#
# Class for creating mongodb users.
#
# == Parameters
#
#  password - Plain text user password.
#  password_hash - Hashed password. Hex encoded md5 hash of "$username:mongo:$password".
#  roles (default: ['dbAdmin']) - array with user roles.
#  database (default: 'admin') - database the roles apply to.
#  tries (default: 10) - The maximum amount of two second tries to wait MongoDB startup.
#
define mongodb::user (
  $password,
  $user          = $name,
  $roles         = ['dbAdmin'],
  $database      = 'admin',
  $tries         = 10,
) {

  $hash = mongodb_password($user, $password)

  mongodb_user { $user:
    ensure        => present,
    password      => $password,
    password_hash => $hash,
    database      => $database,
    roles         => $roles
  }
}
