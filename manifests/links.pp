define artifactory::links(
  Stdlib::Absolutepath $install_dir,
  Stdlib::Absolutepath $data_dir,
  Artifactory::Version $revision,
  String $owner = $::artifactory::user,
) {
  file {
    "${install_dir}/logs":
      ensure  => link,
      owner   => $owner,
      target  => "${data_dir}/logs",
      force   => true;

    "${install_dir}/etc":
      ensure  => link,
      owner   => $owner,
      target  => "${data_dir}/etc",
      force   => true;

    "${install_dir}/data":
      ensure  => link,
      owner   => $owner,
      target  => "${data_dir}/data",
      force   => true;
  }

  if versioncmp($revision, '5.1.1') >= 0 {
    file {
      "${install_dir}/access":
        ensure  => link,
        owner   => $owner,
        target  => "${data_dir}/access",
        force   => true;

      "${install_dir}/support":
        ensure  => link,
        owner   => $owner,
        target  => "${data_dir}/support",
        force   => true;

      "${install_dir}/run":
        ensure  => link,
        owner   => $owner,
        target  => "${data_dir}/run",
        force   => true;
    }
  }
}
