# artifactory::package::apt
#
# Installs Artifactory from a Debian/APT package
#
# @param [String] ensure
# @param [String] type
#
class artifactory::repo::apt(
  $ensure = $::artifactory::ensure,
  $type = $::artifactory::type
) {
  require ::apt

  $repo = $type ? {
    'pro'   => 'https://jfrog.bintray.com/artifactory-pro-debs',
    default => 'https://jfrog.bintray.com/artifactory-debs'
  }

  file {
    '/tmp/artifactory-key.asc':
      ensure => file,
      source => 'puppet:///modules/artifactory/jfrog-public.key.asc',
      mode   => '0400';
  }

  apt::key {
    'artifactory-key':
      id     => 'A3D085F542F740BBD7E3A2846B219DCCD7639232',
      source => '/tmp/artifactory-key.asc'
  }

  apt::source {
    'artifactory-pro':
      ensure   => $ensure,
      location => $repo,
      release  => $::lsbdistcodename,
      repos    => 'main';
  }
}
