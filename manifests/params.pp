# artifactory::params
#
# Smart params class for Artifactory
#
class artifactory::params() {
  $version = '4.10.0'
  $manage_artifactory_home = true
  $manage_user = true
  $source_download_url = undef
  $service_name = 'artifactory'

  $owner = 'artifactory'
  $group = 'artifactory'

  $db_type = 'derby'
  $db_name = 'artifactory'

  $db_driver = undef
  $db_host = undef
  $db_port = undef

  $storage_properties = {
    'binary_provider_type' => 'filesystem',
    'binary.provider.cache.maxSize' => '5GB'
  }

  $system_properties = {
    'artifactory.plugin.scripts.refreshIntervalSecs' => '60'
  }

  case $::osfamily {
    /FreeBSD|Darwin/: {
      $install_type = 'source'
      $oss_package_name = 'artifactory'
      $pro_package_name = undef
      $install_dir = '/usr/local/artifactory'
      $data_dir = '/usr/local/etc/artifactory'
      $service_dir = '/usr/local/etc/rc.d'
      $update_shebang = true
    }
    /RedHat|CentOS/: {
      $install_type = 'yum'
      $pro_package_name = 'jfrog-artifactory-pro'
      $oss_package_name = 'jfrog-artifactory-oss'
      $install_dir = '/opt/jfrog/artifactory'
      $data_dir = '/var/lib/artifactory'
      $service_dir = '/etc/rc.d/init.d'
      $update_shebang = true
    }
    default: {
      $install_type = 'apt'
      $oss_package_name = 'jfrog-artifactory-oss'
      $pro_package_name = 'jfrog-artifactory-pro'
      $install_dir = '/opt/jfrog/artifactory'
      $data_dir = '/var/lib/artifactory'
      $service_dir = '/etc/init.d'
      $update_shebang = false
    }
  }
}
