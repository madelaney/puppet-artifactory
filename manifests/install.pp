# artifactory::install
#
#
# @param [String] artifactory_home
# @param [String] install_dir
# @param [String] user
# @param [String] group
# @param [Hash] sources
# @param [String] version
# @param [String] data_dir
# @param [Boolean] manage_user
#
class artifactory::install (
  Stdlib::Absolutepath $install_dir = $::artifactory::install_dir,
  String $user                      = $::artifactory::user,
  String $group                     = $::artifactory::group,
  Hash $sources                     = $::artifactory::sources,
  Variant $data_dir                 = $::artifactory::data_dir,
  Boolean $manage_user              = $::artifactory::manage_user
) {
  if empty($sources) {
    fail('Using source install but source version is empty')
  }

  assert_private()

  exec {
    "mktree ${data_dir}":
      command   => "mkdir -vp ${data_dir}",
      path      => ['/bin', '/usr/bin'],
      creates   => $data_dir,
      user      => 'root',
      group     => 'root',
      logoutput => on_failure,
      before    => Class['::artifactory::config'];
  }

  $data_dir_list = [
    "${data_dir}/data",
    "${data_dir}/etc",
    "${data_dir}/etc/plugins",
    "${data_dir}/logs",
    "${data_dir}/misc",
    "${data_dir}/support",
    "${data_dir}/run",
    "${data_dir}/access"
  ]

  file {
    $data_dir_list:
      ensure  => directory,
      owner   => $user,
      group   => $group,
      mode    => '0750',
      require => Exec["mktree ${data_dir}"];

    "${data_dir}/etc/mimetypes.xml":
      ensure  => file,
      replace => false,
      owner   => $user,
      group   => $group,
      mode    => '0640',
      source  => 'puppet:///modules/artifactory/etc/mimetypes.xml',
      require => File["${data_dir}/etc"];

    "${data_dir}/etc/logback.xml":
      ensure  => file,
      replace => false,
      owner   => $user,
      group   => $group,
      mode    => '0640',
      source  => 'puppet:///modules/artifactory/etc/logback.xml',
      require => File["${data_dir}/etc"];

    "${data_dir}/etc/artifactory.config.xml":
      ensure  => file,
      replace => false,
      owner   => $user,
      group   => $group,
      mode    => '0640',
      source  => 'puppet:///modules/artifactory/etc/artifactory.config.xml',
      require => File["${data_dir}/etc"];

    "${data_dir}/etc/binarystore.xml":
      ensure  => file,
      replace => false,
      owner   => $user,
      group   => $group,
      mode    => '0640',
      source  => 'puppet:///modules/artifactory/etc/binarystore.xml',
      require => File["${data_dir}/etc"];
  }

  if $manage_user {
    group {
      $group:
        ensure => present;
    }
    user {
      $user:
        ensure  => present,
        require => Group[$group];
    }
  }

  file {
    $install_dir:
      ensure => directory,
      owner  => $user,
      group  => $group,
      mode   => '0750';

    "${install_dir}/.archives":
      ensure => directory,
      require => File[$install_dir]
  }

  exec {
    "mktree ${install_dir}":
      command   => "mkdir -vp ${install_dir}",
      path      => ['/bin', '/usr/bin'],
      creates   => $install_dir,
      user      => 'root',
      group     => $group,
      logoutput => on_failure,
      before    => [Class['::artifactory::config'], File[$install_dir]];
  }

  $defaults = {
    before  => Class['::artifactory::config']
  }

  create_resources('::artifactory::package::source', $sources, $defaults)
}
