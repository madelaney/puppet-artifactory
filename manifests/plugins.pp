# == Class artifactory::plugins
#
# This class is called from artifactory for service config.
#
# @param [Array] plugins Array of plugins to install
#
class artifactory::plugins (
  Stdlib::Absolutepath $data_dir  = $::artifactory::data_dir,
  Hash $plugins                   = $::artifactory::plugins,
  Optional[String] $plugins_repo  = $::artifactory::plugins_repo,
) {
  if !empty($plugins) {
    create_resources('::artifactory::plugin', $plugins)
  }
  elsif $plugins_repo {
    vcsrepo {
      "${data_dir}/etc/plugins/":
        ensure   => present,
        provider => git,
        revision => 'master',
        source   => $plugins_repo;
    }
  }
}
