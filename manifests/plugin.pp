# artifactory::plugin
#
# Defines a plugin to be installed in Artifactory
#
# @param [String] url
# @param [String] owner
# @param [String] group
#
#
define artifactory::plugin(
  $url,
  $owner = $::artifactory::owner,
  $group = $::artifactory::group
) {
  $plugin_name =  regsubst($url, '.+\/([^\/]+)$', '\1')
  wget::fetch {
    $title:
      source      => $url,
      destination => "${::artifactory::data_dir}/etc/plugins/",
      timeout     => 0,
      verbose     => false,
  }
}
