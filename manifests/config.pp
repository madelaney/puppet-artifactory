# == Class artifactory::config
#
# This class is called from artifactory for service config.
#
# @param [String] owner Owner of installed config files
# @param [String] group Group owner of installed config files
# @param [String] db_type Database type
# @param [String] db_host Database host/ip address
# @param [Integer] db_port Database port (postgresql only)
# @param [String] db_name Database name
# @param [String] db_username Database username
# @param [String] db_password Database password
# @param [Hash] storage_properties Hash of storage related properties
# @param [Hash] system_properties Hash of system properties
#
class artifactory::config(
  String $user                    = $::artifactory::user,
  String $group                   = $::artifactory::group,
  Artifactory::Database $db_type  = $::artifactory::db_type,
  Optional[String] $db_host       = $::artifactory::db_host,
  Optional[Integer] $db_port      = $::artifactory::db_port,
  Optional[String] $db_name       = $::artifactory::db_name,
  Optional[String] $db_username   = $::artifactory::db_username,
  Optional[String] $db_password   = $::artifactory::db_password,
  Hash $storage_properties        = $::artifactory::storage_properties,
  Hash $system_properties         = $::artifactory::system_properties,
  Hash $db_properties             = $::artifactory::db_properties,
  String $java_xms                = $::artifactory::java_xms,
  String $java_xmx                = $::artifactory::java_xmx,
  Array $java_opts                = $::artifactory::java_opts
) {
  assert_private()

  case $db_type {
    'derby': {
      $jdbc_driver_url = "jdbc:derby:${db_name}"
      $db_driver = undef
    }
    'postgresql': {
      $jdbc_driver_url = "jdbc:postgresql://${db_host}:${db_port}/${db_name}"
      $db_driver = $::artifactory::db_driver ? {
        undef   => 'org.postgresql.Driver',
        default => $::artifactory::db_driver
      }
    }
    default: {
      notice("Unsure of database: ${db_type}")
    }
  }

  if empty($::artifactory::license) {
    file {
      "${::artifactory::data_dir}/etc/artifactory.lic":
        ensure  => absent;
    }
  }
  else {
    file {
      "${::artifactory::data_dir}/etc/artifactory.lic":
        ensure  => file,
        content => $::artifactory::license,
        owner   => $user,
        group   => $group,
        mode    => '0664';
    }
  }

  file {
    "${::artifactory::data_dir}/etc/storage.properties":
      ensure  => file,
      content => template('artifactory/storage.properties.erb'),
      owner   => $user,
      group   => $group,
      mode    => '0400';

    "${::artifactory::data_dir}/etc/artifactory.system.properties":
      ensure  => file,
      content => template('artifactory/artifactory.system.properties.erb'),
      owner   => $user,
      group   => $group,
      mode    => '0400';

    "${::artifactory::data_dir}/etc/db.properties":
      ensure  => file,
      content => template('artifactory/db.properties.erb'),
      owner   => $user,
      group   => $group,
      mode    => '0400';
  }
}
