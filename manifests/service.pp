# artifactory::service
#
# Sets up the service
#
# @param [String] service_name
# @param [Boolean] service_enable
# @param [String] service_ensure
# @param [String] service_dir
# @param [Boolean] service_manage
# @param [String] service_restart
# @param [String] install_dir
#
class artifactory::service(
  $service_name    = $::artifactory::params::service_name,
  $service_enable  = true,
  $service_ensure  = running,
  $service_dir     = $::artifactory::service_dir,
  $service_manage  = true,
  $service_restart = undef,
  $install_dir     = $::artifactory::install_dir
) {
  validate_bool($service_enable)
  validate_bool($service_manage)

  case $service_ensure {
    true, false, 'running', 'stopped': {
      $_service_ensure = $service_ensure
    }
    default: {
      $_service_ensure = undef
    }
  }

  $artifactory_home = "${install_dir}/current"

  $service_hasrestart = $service_restart == undef

  file {
    "${service_dir}/artifactory":
        ensure  => file,
        mode    => '0755',
        content => template("artifactory/rc.d-${::osfamily}.erb")
  }

  if $service_manage {
    if $::osfamily == 'FreeBSD' {
      case $service_ensure {
        true, 'running': {
          $_rc_ensure = 'YES'
        }
        default: {
          $_rc_ensure = NO
        }
      }

      file_line {
        "${service_name} rc.d entry":
          ensure            => present,
          path              => '/etc/rc.conf',
          line              => "${service_name}_enable=${_rc_ensure}",
          match             => "^${service_name}_enable=",
          match_for_absence => true,
          before            => Service['artifactory'];
      }
    }

    service {
      'artifactory':
        ensure     => $_service_ensure,
        name       => $service_name,
        enable     => $service_enable,
        restart    => $service_restart,
        hasrestart => $service_hasrestart,
        require    => File["${service_dir}/artifactory"],
        subscribe  => File["${service_dir}/artifactory"];
    }
  }
}
