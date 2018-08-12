# Class: artifactory
# ===========================
#
# Full description of class artifactory here.
#
# Parameters
# ----------
#
# @param [String] ensure
# @param [String] license
# @param [String] type
# @param [String] pro_package_name
# @param [String] oss_package_name
# @param [String] db_driver
# @param [String] db_type
# @param [String] db_name
# @param [Intger] db_port
# @param [String] db_host
# @param [String] db_username
# @param [String] db_password
# @param [Hash] plugins
# @param [String] user
# @param [String] group
# @param [String] install_dir
# @param [Boolean] manage_install_dir
# @param [Boolean] manage_arifactory_home
# @param [Hash] sources
# @param [String] source_download_url
# @param [Hash] storage_properties
# @param [Hash] system_properties
# @param [Boolean] manage_user
# @param [String] data_dir
# @param [Boolean] update_shebang
#
#
class artifactory(
  Enum['present', 'absent'] $ensure,
  Optional[String] $license,
  Artifactory::Distribution $type,
  String $pro_package_name,
  String $oss_package_name,
  Optional[String] $db_driver,
  Artifactory::Database $db_type,
  String $db_name,
  Optional[Integer] $db_port,
  Optional[String] $db_host,
  Optional[String] $db_username,
  Optional[String] $db_password,
  Hash $plugins,
  Optional[String] $plugins_repo,
  String $user,
  String $group,
  Stdlib::Absolutepath $install_dir,
  Boolean $manage_install_dir,
  Boolean $manage_arifactory_home,
  Hash $sources,
  Optional[String] $source_download_url,
  Hash $storage_properties,
  Hash $system_properties,
  Hash $db_properties,
  Boolean $manage_user,
  Stdlib::Absolutepath $data_dir,
  Boolean $update_shebang,
  String $java_home,
  String $java_xms,
  String $java_xmx,
  Array $java_opts
) {

  if !empty($plugins) and $plugins_repo != undef {
    fail('You cannot set both pluing sources, and plugins repos')
  }

  class{'::artifactory::install': } ->
  class{'::artifactory::config': } ->
  class{'::artifactory::plugins': } ->
  class{'::artifactory::service': }

  Class['::artifactory::config'] ~>
  Class['::artifactory::service']

  Class['::artifactory::plugins'] ~>
  Class['::artifactory::service']
}
