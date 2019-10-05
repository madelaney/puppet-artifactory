# artifactory::package::source
#
# Installs Artifactory from "source" (Tomcat) vs. a OS specific package
#
# @param [String] ensure
# @param [String] type Artifactory install type (oss, or pro)
# @param [String] version Version of artifactory to install
# @param [String] install_dir Directory to install artifactory into
# @param [String] user Owner of the artifactory install direcetory
# @param [String] group Group owner of the artifactory install directory
# @param [String] download_url URL to download the artifactory zip file form
# @param [String] data_dir Data directory for artifactory
# @param [String] db_type Database type
# @param [String] driver_version Database driver
# @param [Boolean] Update the script shebang to use 'env'
# @param [Boolean] current Should this be the current version of artifactory
#
define artifactory::package::source(
  Artifactory::Version $version,
  Enum['present', 'absent'] $ensure = present,
  Artifactory::Distribution $type   = $::artifactory::type,
  Stdlib::Absolutepath $install_dir = $::artifactory::install_dir,
  String $user                      = $::artifactory::user,
  String $group                     = $::artifactory::group,
  Optional[String] $download_url    = $::artifactory::source_download_url,
  Stdlib::Absolutepath $data_dir    = $::artifactory::data_dir,
  Artifactory::Database $db_type    = $::artifactory::db_type,
  String $driver_version            = '9.4.1211',
  Boolean $update_shebang           = $::artifactory::update_shebang,
  Boolean $current                  = false,
) {
  $filename = "artifactory-${type}-${version}"
  $zip_filename = "jfrog-${filename}"
  $archive_filename = "${zip_filename}.zip"

  if $download_url {
    $_real_download_url = $download_url
  }
  else {
    $_real_download_url = $type ? {
      pro     => "https://dl.bintray.com/jfrog/artifactory-pro/org/artifactory/pro/jfrog-artifactory-pro/${version}/${archive_filename}",
      default => "https://dl.bintray.com/jfrog/artifactory/${archive_filename};bt_package=jfrog-artifactory-oss-zip"
    }
  }

  $_real_install_dir = "${install_dir}/${filename}"
  $_real_archive_dir = "${install_dir}/.archives"

  if $ensure == 'present' {
    archive {
      $archive_filename:
        source       => $_real_download_url,
        path         => "${_real_archive_dir}/${archive_filename}",
        extract      => true,
        extract_path => $install_dir,
        cleanup      => false,
        user         => $user,
        group        => $group,
        require      => File[$install_dir];
    }

    exec {
      "update _real_install_dir permissions (${version})":
        command     => "chown ${user}:${group} ${_real_install_dir}",
        path        => ['/bin', '/usr/sbin'],
        subscribe   => Archive[$archive_filename],
        refreshonly => true;

      "tomcat permission (${version})":
        command     => "chown ${user}:${group} ${_real_install_dir}",
        path        => ['/bin', '/usr/sbin'],
        subscribe   => Archive[$archive_filename],
        refreshonly => true;
    }

    unless $facts['os']['kernel'] == 'FreeBSD' {
      $_real_java_opts = concat(['-server',
                                  "-Xms${artifactory::java_xms}",
                                  "-Xmx${artifactory::java_xmx}"],
                                  $artifactory::java_opts)
      file {
        "${_real_install_dir}/artifactory.default":
          ensure  => file,
          content => template('artifactory/artifactory.default.erb'),
          owner   => $user,
          group   => $group,
          mode    => '0400';
      }

      /*
      file_line {
        "update default file (${version})":
          ensure  => present,
          path    => "${_real_install_dir}/bin/artifactoryManage.sh",
          line    => "artDefaultFile=\"${_real_install_dir}/artifactory.default\"",
          match   => "^artDefaultFile=",
          require => Archive[$archive_filename],
          before  => Service['artifactory'];
      }
      */
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

    artifactory::links {
      "data links for ${version}":
        install_dir => $_real_install_dir,
        data_dir    => $data_dir,
        revision    => $version,
        require     => Archive[$archive_filename]
    }

    if $update_shebang {
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
          owner  => $user,
          target => $_real_install_dir;
      }
    }
  }
  else {
    file {
      $_real_install_dir:
        ensure => absent,
        force  => true;
    }
  }
}
