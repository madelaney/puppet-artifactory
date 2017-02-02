# artifactory::install
#
#
# @param [String] install_type
# @param [String] artifactory_home
# @param [String] install_dir
# @param [String] user
# @param [String] group
# @param [Hash] sources
# @param [String] version
# @param [String] data_dir
# @param [Boolean] manage_user
#
class artifactory::install(
  $install_type           = $::artifactory::install_type,
  $artifactory_home       = $::artifactory::artifactory_home,
  $install_dir            = $::artifactory::install_dir,
  $user                   = $::artifactory::user,
  $group                  = $::artifactory::group,
  $sources                = $::artifactory::sources,
  $version                = present,
  $data_dir               = $::artifactory::data_dir,
  $manage_user            = $::artifactory::manage_user
) {
  validate_hash($sources)

  file {
    $data_dir:
      ensure => directory,
      owner  => $user,
      group  => $group,
      mode   => '0750';

    "${data_dir}/data":
      ensure  => directory,
      owner   => $user,
      group   => $group,
      mode    => '0750',
      require => File[$data_dir];

    ["${data_dir}/etc", "${data_dir}/etc/plugins", "${data_dir}/logs", "${data_dir}/misc"]:
      ensure  => directory,
      owner   => $user,
      group   => $group,
      mode    => '0750',
      require => File[$data_dir];
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

  if $install_type != 'source' {
    case $install_type {
      'yum': { require ::artifactory::repo::yum }
      'apt': { require ::artifactory::repo::apt }
      default: {
        warning("Unknown install type: ${install_type}")
      }
    }

    $package_name = $::artifactory::type ? {
      'pro'   => $::artifactory::pro_package_name,
      default => $::artifactory::oss_package_name
    }

    package {
      $package_name:
        ensure => $version,
        before => Class['::artifactory::config'],
    }

    case $::osfamily {
      'Debian': {
        Package[$package_name] {
          require => Class['::artifactory::repo::apt']
        }
      }
      'Redhat': {
        Package[$package_name] {
          require => Class['::artifactory::repo::yum']
        }
      }
      default: {
        # Nothing
      }
    }
  }
  else {
    if empty($sources) {
      fail('Using source install but source version is empty')
    }

    file {
      $install_dir:
        ensure => directory,
        owner  => $user,
        group  => $group,
        mode   => '0750';
    }

    exec {
      "mktree ${install_dir}":
        command => "mkdir -m 0750 -vp ${install_dir}",
        path    => ['/bin', '/usr/bin'],
        creates => $install_dir,
        user    => 'root',
        group   => $group,
        before  => Class['::artifactory::config'];
    }

    $defaults = {
      before => Class['::artifactory::config']
    }

    create_resources('::artifactory::package::source', $sources, $defaults)
  }
}
