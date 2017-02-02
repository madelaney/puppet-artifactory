# artifactory::package::yum
#
# Installs Artifactory from Redhat/YUM repository
#
# @param [String] ensure
# @param [String] type
#
class artifactory::repo::yum(
  $ensure = $::artifactory::ensure,
  $type = $::artifactory::type
) {
  $repo = $type ? {
    'pro'   => 'http://jfrog.bintray.com/artifactory-pro-rpms',
    default => 'http://jfrog.bintray.com/artifactory-rpms'
  }

  yumrepo {
    "artifactory-${type}-repo":
      descr    => 'artifactory-pro-rpms',
      baseurl  => $repo,
      gpgcheck => '0',
      enabled  => '1';
  }
}
