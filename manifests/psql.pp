# A wrapper for pe_postgres_psql with some reasonable defaults.
define pe_external_postgresql::psql(
  String $db,
  String $command,
  Integer $port      = $postgresql::params::port,
  String $psql_user  = $postgresql::params::user,
  String $psql_group = $postgresql::params::group,
  String $psql_path  = $postgresql::params::psql_path,
  $unless = undef
) {
  postgresql_psql { $title:
    port       => $port,
    psql_user  => $psql_user,
    psql_group => $psql_group,
    psql_path  => $psql_path,
    db         => $db,
    command    => $command,
    unless     => $unless,
  }
}
