# artifactory::db::postgresql
#
# Downloads a PostgreSQL jdbc driver
#
# @param [String] target Artifactory target to install jar into
# @param [String] version Version of postgre JDBC driver to install
# @param [String] jre Use the JRE version of the JDBC driver
#
define artifactory::db::postgresql(
  $target,
  $version,
  $user  = $::artifactory::user,
  $group = $::artifactory::group,
  $jre   = undef
) {
  # The base class must be included first because it is used by parameter defaults
  if ! defined(Class['artifactory']) {
    fail('You must include the Artifactory base class before using any Artifactory defined resources')
  }

  if $jre {
    $jar = "postgresql-${version}.${jre}.jar"
  }
  else {
    $jar = "postgresql-${version}.jar"
  }

  archive {
    "${target}/${jar}":
      ensure => present,
      user   => $user,
      group  => $group,
      source => "https://jdbc.postgresql.org/download/${jar}";
  }
}
