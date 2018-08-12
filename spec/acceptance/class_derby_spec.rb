require 'spec_helper_acceptance'

describe 'artifactory class' do
  context 'default parameters' do
    if default['platform'] =~ /freebsd/
      it 'should work with no errors on freebsd' do
        pp = <<-CATALOG
        package {
          ['openjdk8', 'bash']:
            ensure => present,
            before => Class['artifactory'];
        }

        class {
          'artifactory':
            ensure  => present,
            sources => {
              "v4.5.1" => {
                version => '4.5.1'
              },
              "v4.10.0" => {
                version => '4.10.0'
              },
              "v6.1.0" => {
                version => '6.1.0',
                current => true
              }
            };
        }
        CATALOG

        # Run it twice and test for idempotency
        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end
    else
      it "should work with no errors #{default['platform']}" do
        pp = <<-CATALOG
        package {
          'unzip':
            ensure => present;
        }

        class {
          'java':
            distribution => 'jdk',
            version      => 'latest';
        }

        class {
          'artifactory':
            ensure       => present,
            sources      => {
              "v4.5.1" => {
                version => '4.5.1'
              },
              "v4.10.0" => {
                version => '4.10.0'
              },
              "v6.1.0" => {
                version => '6.1.0',
                current => true
              }
            };
        }
        CATALOG

        # Run it twice and test for idempotency
        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe package('jfrog-artifactory-oss') do
        it { is_expected.to_not be_installed }
      end
    end

    describe service('artifactory') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end
end
