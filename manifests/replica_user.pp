# A define type to manage the creation of 'ordinary' (non-super-) postgres users.
# In particular, it manages the necessary grants to have such a user that is not
# also the database owner.
#
# @param user_name [String] The name of the postgres user
# @param database [String] The name of the database to grant access to.
# @param database_password [String] The login password for the user; use the empty
#        string to disable password authentication.
# @param db_owner [String] The user which owns the database (i.e. the migration user
#        for the database)
define pe_external_postgresql::replica_user(
  String $user_name,
  String $database,
  String $database_password,
  Boolean $write_access,
  String $db_owner,
) {
  $_database_password = $database_password ? {
    ''      => undef,
    default => $database_password
  }

  pe_postgresql::server::role { $user_name:
    password_hash => $_database_password,
  }

  pe_external_postgresql::grant_connect { "${database} grant connect perms to ${user_name}":
    database => $database,
    schema   => 'public',
    user     => $user_name,
    require  => Pe_postgresql::Server::Role[$user_name],
  }

  if $write_access {
    pe_external_postgresql::write_grant {"${database} grant write perms on existing objects to ${user_name}":
      table_writer => $user_name,
      database     => $database,
      schema       => 'public',
      require      => Pe_postgresql::Server::Role[$user_name],
    }

    [$db_owner].each |$owner| {
      pe_external_postgresql::default_write_grant {"${database} grant write perms on new objects from ${owner} to ${user_name}":
        table_creator => $owner,
        table_writer  => $user_name,
        database      => $database,
        schema        => 'public',
        require       => Pe_postgresql::Server::Role[$user_name],
      }
    }
  } else {
    [$db_owner].each |$owner| {
      pe_external_postgresql::default_read_grant {"${database} grant read perms on new objects from ${owner} to ${user_name}":
        table_creator => $owner,
        table_reader  => $user_name,
        database      => $database,
        schema        => 'public',
        require       => Pe_postgresql::Server::Role[$user_name],
      }
    }
  }
}
