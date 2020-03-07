# artifactory::plugin
#
# Defines a plugin to be installed in Artifactory
#
# @param [String] url
# @param [String] user
# @param [String] group
#
#
define artifactory::plugin(
  String $url,
  String $user  = $::artifactory::user,
  String $group = $::artifactory::group
) {
  archive {
    $title:
      source => $url,
      path   =>"${::artifactory::data_dir}/etc/plugins/${title}",
      user   => $user,
      group  => $group;
  }
}
