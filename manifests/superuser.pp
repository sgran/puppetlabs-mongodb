# == Class: mongodb::superuser
#
# Class for creating mongodb superuser.
#
# == Parameters
#
#  password - Plain text user password.
#  tries (default: 10) - The maximum amount of two second tries to wait MongoDB startup.
#
define mongodb::superuser (
  $password,
  $user          = $name,
  $tries         = 10,
) {

  $hash = mongodb_password($user, $password)

  mongodb_user { $user:
    ensure        => present,
    password      => $password,
    password_hash => $hash,
    database      => 'admin',
    roles         => ['root'],
  }

	file { '/etc/mongorc.js':
		content => template('mongodb/mongorc.js.erb'),
		mode    => '0640',
		owner   => root,
		group   => root,
	}

}
