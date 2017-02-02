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
  $jre = undef
) {
  require ::artifactory

  if $jre {
    $jar = "postgresql-${version}.${jre}.jar"
  }
  else {
    $jar = "postgresql-${version}.jar"
  }

  archive {
    "${target}/${jar}":
      ensure => present,
      user   => $::artifactory::owner,
      group  => $::artifactory::group,
      source => "https://jdbc.postgresql.org/download/${jar}";
  }
}
