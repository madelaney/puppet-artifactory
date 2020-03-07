require 'spec_helper'

describe 'artifactory' do
  ['oss', 'pro'].each do |artifactory_type|
    context artifactory_type.to_s do
      let :default_params do
        {
          'ensure'       => 'present',
          'type'         => artifactory_type,
          'data_dir'     => '/opt/artifactory-data',
          'plugins'      => {
            'download-directory' => {
              'url' => 'https://github.com/JFrogDev/artifactory-user-plugins/blob/master/cleanup/buildCleanup/buildCleanup.groovy',
            },
            'build-properties' => {
              'url' => 'https://github.com/JFrogDev/artifactory-user-plugins/blob/master/build/buildPropertySetter/buildPropertySetter.groovy',
            },
            'layout-properties' => {
              'url' => 'https://github.com/JFrogDev/artifactory-user-plugins/blob/master/storage/layoutProperties/layoutProperties.groovy',
            },
          },
          'sources' => {
            'v6.1.0' => {
              'ensure'  => 'present',
              'version' => '6.1.0',
            },
          },
        }
      end

      context 'supported operating systems' do
        on_supported_os.each do |os, facts|
          context "on #{os} (#{facts[:os]['family']})" do
            let(:facts) { facts }
            let(:params) { default_params }

            custom_data_dir = '/opt/artifactory-data'

            data_dir = case facts[:os]['family']
                       when 'FreeBSD'
                         '/usr/local/etc/artifactory'
                       when 'RedHat'
                         '/var/lib/artifactory'
                       else
                         '/var/opt/jfrog/artifactory'
                       end

            it { is_expected.to contain_exec('mktree /opt/artifactory-data') }

            it { is_expected.to contain_file("#{custom_data_dir}/etc/mimetypes.xml") }
            it { is_expected.to contain_file("#{custom_data_dir}/etc/logback.xml") }
            it { is_expected.to contain_file("#{custom_data_dir}/etc/binarystore.xml") }
            it { is_expected.to contain_file("#{custom_data_dir}/etc/artifactory.config.xml") }
            it { is_expected.to contain_file("#{custom_data_dir}/etc/artifactory.system.properties") }
            it { is_expected.to contain_file("#{custom_data_dir}/etc/storage.properties") }
            it { is_expected.to contain_file("#{custom_data_dir}/etc/db.properties") }
            it { is_expected.to contain_file("#{custom_data_dir}/etc/artifactory.lic").with_ensure('absent') }
            it { is_expected.to contain_file("#{custom_data_dir}/etc/plugins") }

            it { is_expected.not_to contain_file("#{data_dir}/etc/artifactory.system.properties") }
            it { is_expected.not_to contain_file("#{data_dir}/etc/storage.properties") }
            it { is_expected.not_to contain_file("#{data_dir}/etc/db.properties") }
            it { is_expected.not_to contain_file("#{data_dir}/etc/artifactory.lic").with_ensure('absent') }
            it { is_expected.not_to contain_file("#{data_dir}/etc/plugins") }
          end
        end
      end
    end
  end
end
