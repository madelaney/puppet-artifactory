source ENV['GEM_SOURCE'] || 'https://rubygems.org'

def location_for(place, version = nil)
  if place =~ /^(git[:@][^#]*)#(.*)/
    [version, { git: Regexp.last_match(1), branch: Regexp.last_match(2), require: false }].compact
  elsif place =~ %r{^file:\/\/(.*)}
    ['>= 0', { path: File.expand_path(Regexp.last_match(1)), require: false }]
  else
    [place, version, { require: false }].compact
  end
end

group :development, :unit_tests do
  gem 'facterdb',                  require: false
  gem 'json',                      require: false
  gem 'metadata-json-lint',        require: false
  gem 'puppet-blacksmith',         require: false
  gem 'puppet_facts',              require: false
  gem 'puppetlabs_spec_helper',    require: false
  gem 'rspec-puppet', '>= 2.3.2',  require: true
  gem 'rspec-puppet-facts',        require: false
  gem 'rubocop',                   require: false
end

group :system_tests do
  gem 'beaker',                        *location_for(ENV['BEAKER_VERSION'])
  gem 'beaker-hostgenerator',          *location_for(ENV['BEAKER_HOSTGENERATOR_VERSION'])
  gem 'beaker-module_install_helper',  require: false
  gem 'beaker-puppet',                 require: false
  gem 'beaker-puppet_install_helper',  require: false
  gem 'beaker-rspec',                  *location_for(ENV['BEAKER_RSPEC_VERSION'] || '>= 3.4')
  gem 'beaker-vagrant',                '>= 0.5.0'
  gem 'master_manipulator',            require: false
  gem 'serverspec',                    require: false
end

puppetversion = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : ['>= 4.0', '< 6.0']
gem 'facter', '>= 1.7.0'
gem 'puppet', puppetversion
gem 'puppet-strings'
gem 'safe_yaml', '~> 1.0.4'
