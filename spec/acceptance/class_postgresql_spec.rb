require 'spec_helper_acceptance'

describe 'artifactory class' do
  context 'with postgre sql parameters' do
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
            ensure      => present,
            db_driver   => 'org.postgresql.Driver',
            db_type     => 'postgresql',
            db_host     => 'localhost',
            db_port     => 9876,
            db_name     => 'artifactory2',
            db_username => 'db-username',
            db_password => 'superPassword',
            sources     => {
              "v4.5.1" => {
                version => '4.5.1'
              },
              "v4.10.0" => {
                version => '4.10.0'
              },
              "v5.1.4" => {
                version => '5.1.4',
                current => true
              }
            }
        }
        CATALOG

        # Run it twice and test for idempotency
        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end
    else
      it "should work with no errors on #{default['platform']}" do
        pp = <<-CATALOG
        package {
          'unzip':
            ensure => present;
        }

        class {
          'java':
            distribution => 'jdk',
            version      => 'latest',
            before       => Class['artifactory'];
        }

        class {
          'artifactory':
            ensure      => present,
            db_driver   => 'org.postgresql.Driver',
            db_type     => 'postgresql',
            db_host     => 'localhost',
            db_port     => 9876,
            db_name     => 'artifactory2',
            db_username => 'db-username',
            db_password => 'superPassword',
            sources     => {
              "v5.1.4" => {
                version => '5.1.4',
                current => true
              }
            }
        }
        CATALOG

        # Run it twice and test for idempotency
        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe package('jfrog-artifactory-oss') do
        it { is_expected.to be_installed }
      end

    end

    describe service('artifactory') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end
end
