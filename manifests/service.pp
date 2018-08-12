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
  String $service_name,
  String $ensure,
  Boolean $enabled,
  Boolean $manage,
  Artifactory::Service $service_provider
) {
  assert_private()
  if $manage {
    case $service_provider {
      'sysv': {
        $service_dir = '/etc/init.d'
        $target_file = $service_name
        $file_mode = '0755'
      }
      'systemd': {
        $service_dir = '/etc/systemd/system/multi-user.target.wants'
        $target_file = "${service_name}.service"
        $file_mode = '0644'
      }
      'freebsd': {
        $service_dir = '/usr/local/etc/rc.d'
        $target_file = $service_name
        $file_mode = '0755'
      }
      default: {
        fail("Unsupported init system ${service_provider}")
      }
    }

    file {
      "${service_dir}/${target_file}":
        ensure  => file,
        mode    => $file_mode,
        content => template("artifactory/init/${service_provider}.${::facts['os']['family']}.erb")
    }

    if $facts['os']['family'] == 'FreeBSD' {
      $_rc_ensure = $enabled ? {
        false    => 'NO',
        default  => 'YES'
      }

      exec {
        'set rcvar':
          command => "sysrc ${service_name}_enable=${_rc_ensure}",
          path    => ['/bin', '/usr/sbin'],
          unless  => "test sysrc -c ${service_name}_enable=${_rc_ensure}",
          before  => Service[$service_name];
      }
    }

    service {
      $service_name:
        ensure     => $ensure,
        enable     => $enabled,
        provider   => $service_provider,
        require    => File["${service_dir}/${target_file}"],
        subscribe  => File["${service_dir}/${target_file}"];
    }
  }
}
