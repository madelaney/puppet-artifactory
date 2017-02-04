# artifactory::package::source
#
# Installs Artifactory from "source" (Tomcat) vs. a OS specific package
#
# @param [String] ensure
# @param [String] type Artifactory install type (oss, or pro)
# @param [String] version Version of artifactory to install
# @param [String] install_dir Directory to install artifactory into
# @param [String] owner Owner of the artifactory install direcetory
# @param [String] group Group owner of the artifactory install directory
# @param [String] download_url URL to download the artifactory zip file form
# @param [String] data_dir Data directory for artifactory
# @param [String] db_type Database type
# @param [String] driver_version Database driver
# @param [Boolean] Update the script shebang to use 'env'
# @param [Boolean] current Should this be the current version of artifactory
#
define artifactory::package::source(
  $ensure         = present,
  $type           = $::artifactory::type,
  $version        = $::artifactory::version,
  $install_dir    = $::artifactory::install_dir,
  $owner          = $::artifactory::user,
  $group          = $::artifactory::group,
  $download_url   = $::artifactory::source_download_url,
  $data_dir       = $::artifactory::data_dir,
  $db_type        = $::artifactory::db_type,
  $driver_version = '9.4.1211',
  $update_shebang = $::artifactory::update_shebang,
  $current        = false,
) {
  validate_bool($current)

  $filename = "artifactory-${type}-${version}"
  $zip_filename = "jfrog-${filename}"
  $archive_filename = "${zip_filename}.zip"

  # https://dl.bintray.com/jfrog/artifactory-pro/org/artifactory/pro/jfrog-artifactory-pro/4.10.0/jfrog-artifactory-pro-4.10.0.zip
  # https://api.bintray.com/content/jfrog/artifactory/jfrog-artifactory-oss-4.10.0.zip;bt_package=jfrog-artifactory-oss-zip

  if $download_url {
    $_real_download_url = $download_url
  }
  else {
    $_real_download_url = $type ? {
      pro     => "https://dl.bintray.com/jfrog/artifactory-pro/org/artifactory/pro/jfrog-artifactory-pro/${version}/${archive_filename}",
      default => "https://api.bintray.com/content/jfrog/artifactory/${archive_filename};bt_package=jfrog-artifactory-oss-zip"
    }
  }

  $_real_install_dir = "${install_dir}/${filename}"

  archive {
    $archive_filename:
      source       => $_real_download_url,
      path         => "/tmp/${archive_filename}",
      extract      => true,
      extract_path => $install_dir,
      cleanup      => false,
      user         => $owner,
      group        => $group,
      require      => File[$install_dir];
  }

  exec {
    "update _real_install_dir permissions (${version})":
      command     => "chown ${owner}:${group} ${_real_install_dir}",
      path        => ['/bin', '/usr/sbin'],
      subscribe   => Archive[$archive_filename],
      refreshonly => true;

    "tomcat permission (${version})":
      command     => "chown ${owner}:${group} ${_real_install_dir}",
      path        => ['/bin', '/usr/sbin'],
      subscribe   => Archive[$archive_filename],
      refreshonly => true;
  }

  case $db_type {
    'derby': {}
    'postgresql': {
      artifactory::db::postgresql {
        "artifactory ${version} postgresql ${driver_version}":
          target  => "${_real_install_dir}/tomcat/lib",
          version => $driver_version,
          require => Archive[$archive_filename];
      }
    }
    default: {
      notice("Database type ${db_type} is not supported")
    }
  }

  file {
    "${_real_install_dir}/logs":
      ensure  => link,
      owner   => $owner,
      target  => "${data_dir}/logs",
      force   => true,
      require => Archive[$archive_filename];

    "${_real_install_dir}/etc":
      ensure  => link,
      owner   => $owner,
      target  => "${data_dir}/etc",
      force   => true,
      require => Archive[$archive_filename];

    "${_real_install_dir}/data":
      ensure  => link,
      owner   => $owner,
      target  => "${data_dir}/data",
      force   => true,
      require => Archive[$archive_filename];
  }

  if $::artifactory::update_shebang {
    exec {
      "fix shebang on artifactory.sh (${version})":
        command     => 'perl -p -i -e \'s/\#\!\/bin\/bash/\#\!\/usr\/bin\/env bash\'/ bin/artifactory.sh',
        path        => ['/usr/bin', '/usr/local/bin'],
        cwd         => $_real_install_dir,
        subscribe   => Archive[$archive_filename],
        refreshonly => true;
    }
  }

  if $current {
    file {
      "${install_dir}/current":
        ensure => link,
        target => $_real_install_dir;
    }
  }
}
