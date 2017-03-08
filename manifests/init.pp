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
# @param install_type
# @param [String] service_name
# @param [String] pro_package_name
# @param [String] oss_package_name
# @param [String] artifactory_home
# @param [Boolean] manage_artifactory_home
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
  $ensure                             = present,
  $license                            = undef,
  $type                               = 'oss',
  $install_type                       = $::artifactory::params::install_type,
  $service_name                       = $::artifactory::params::service_name,
  $pro_package_name                   = $::artifactory::params::pro_package_name,
  $oss_package_name                   = $::artifactory::params::oss_package_name,
  $artifactory_home                   = $::artifactory::params::artifactory_home,
  $manage_artifactory_home            = $::artifactory::params::manage_artifactory_home,
  $db_driver                          = $::artifactory::params::db_driver,
  $db_type                            = $::artifactory::params::db_type,
  $db_name                            = $::artifactory::params::db_name,
  $db_port                            = $::artifactory::params::db_port,
  $db_host                            = $::artifactory::params::db_host,
  $db_username                        = undef,
  $db_password                        = undef,
  $plugins                            = {},
  $user                               = $::artifactory::params::owner,
  $group                              = $::artifactory::params::group,
  $install_dir                        = $::artifactory::params::install_dir,
  $manage_install_dir                 = true,
  $manage_arifactory_home             = true,
  $sources                            = {},
  $source_download_url                = $::artifactory::params::source_download_url,
  $storage_properties                 = $::artifactory::params::storage_properties,
  $system_properties                  = $::artifactory::params::system_properties,
  $db_properties                      = $::artifactory::params::db_properties,
  $manage_user                        = $::artifactory::params::manage_user,
  $data_dir                           = $::artifactory::params::data_dir,
  $update_shebang                     = $::artifactory::params::update_shebang
) inherits ::artifactory::params {

  validate_string($data_dir)

  validate_hash($sources)
  validate_hash($plugins)

  validate_re($install_type, ['source', 'yum', 'apt'])
  validate_re($type, ['oss', 'pro'])
  validate_re($db_type, ['mysql', 'derby', 'postgresql'])

  validate_hash($sources)
  validate_hash($plugins)

  class{'::artifactory::install': } ->
  class{'::artifactory::config': } ->
  class{'::artifactory::plugins': } ->
  class{'::artifactory::service': }

  Class['::artifactory::config'] ~>
  Class['::artifactory::service']

  Class['::artifactory::plugins'] ~>
  Class['::artifactory::service']
}
