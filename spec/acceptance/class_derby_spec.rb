require 'spec_helper_acceptance'

describe 'artifactory class' do
  context 'default parameters' do
    if default['platform'] =~ /el-7-x86_64/
      it 'should work with no errors on centos' do
        pp = <<-EOS
        java::oracle {
          'jdk8' :
            ensure  => 'present',
            version => '8',
            java_se => 'jdk',
        } ->
        class {
          'artifactory':
            ensure  => present;
        }
        EOS

        # Run it twice and test for idempotency
        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe package('jfrog-artifactory-oss') do
        it { is_expected.to be_installed }
      end

    elsif default['platform'] =~ /freebsd/
      it 'should work with no errors on freebsd' do
        pp = <<-EOS
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
                version => '4.10.0',
                current => true
              }
            };
        }
        EOS

        # Run it twice and test for idempotency
        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end
    end

    describe service('artifactory') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end
end
