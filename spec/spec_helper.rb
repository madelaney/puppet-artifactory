require 'puppetlabs_spec_helper/module_spec_helper'
require 'hiera'
require 'rspec-puppet'

require 'rspec-puppet-facts'
include RspecPuppetFacts

RSpec.configure do |c|
  c.before(:each) do
    Puppet::Util::Log.level = :warning
    Puppet::Util::Log.newdestination(:console)
  end

  c.color = true
  c.formatter = :documentation

  c.hiera_config = File.expand_path(File.join(__FILE__, '../fixtures/hiera.yaml'))

  # Generate Coverage report
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end

def print_catalog
  it { pp catalogue.resources }
end

shared_examples :compile, :compile => true do
  it { should compile.with_all_deps }
end
