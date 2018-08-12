require 'beaker-rspec'
require 'beaker-puppet'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

# https://github.com/puppetlabs/beaker/tree/master/docs/how_to
# https://github.com/puppetlabs/beaker-rspec
# run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no' || ENV['BEAKER_set'] =~ /freebsd/

run_puppet_install_helper

install_module
install_module_dependencies

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    hosts.each do |host|
      if /freebsd/i =~ host
        on host, 'pkg install -y ruby23-gems'
        on host, 'pkg install -y puppet4'

        # FIXME: mdelaney
        # Beaker has a bug where when :disable_updates is true, and on FreeBSD,
        # the file /etc/hosts is updated to only contain the disabled
        # updated.puppetlabs.com entry
        #
        # on host, 'echo 127.0.0.1\tlocalhost >> /etc/hosts'
      end

      puppet_module_install(source: proj_root, module_name: 'artifactory')

      on host, puppet('module', 'install', 'puppetlabs-stdlib'), acceptable_exit_codes: [0, 1]
      on host, puppet('module', 'install', 'puppet-archive'), acceptable_exit_codes: [0, 1]
      on host, puppet('module', 'install', 'puppetlabs-vcsrepo'), acceptable_exit_codes: [0, 1]
      on host, puppet('module', 'install', 'puppetlabs-java'), acceptable_exit_codes: [0, 1]
    end
  end
end
