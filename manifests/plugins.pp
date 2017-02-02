# == Class artifactory::plugins
#
# This class is called from artifactory for service config.
#
# @param [Array] plugins Array of plugins to install
#
class artifactory::plugins (
  $plugins = $::artifactory::plugins
) {
  validate_hash($plugins)
  create_resources('::artifactory::plugin', $plugins)
}
