require 'spec_helper'

describe 'artifactory' do
  ['oss', 'pro'].each do |artifactory_type|
    context "#{artifactory_type}" do
      let :default_params do
        {
          'ensure'       => 'present',
          'license'      => 'my_license_key',
          'type'         => artifactory_type,
          'user'         => 'jfrog',
          'group'        => 'jfrog'
        }
      end

      context 'supported operating systems' do
        on_supported_os.each do |os, facts|
          context "on #{os}" do
            let(:facts) { facts }
            let(:params) do
              {
                'db_driver'   => 'org.postgresql.Driver',
                'db_type'     => 'postgresql',
                'db_host'     => 'localhost',
                'db_port'     => 9876,
                'db_name'     => 'artifactory2',
                'db_username' => 'db-username',
                'db_password' => 'superPassword'
              }.merge!(default_params)
            end

            case facts[:kernel]
            when 'FreeBSD'
              install_dir = '/usr/local/artifactory'
            else
              install_dir = '/opt/artifactory'
            end

            include_examples :compile

            context 'should install postgre jdbc driver' do
              it { is_expected.to contain_artifactory__db__postgresql('artifactory 4.5.1 postgresql 9.4.1211').that_comes_before('Service[artifactory]') }
              it { is_expected.to contain_artifactory__db__postgresql('artifactory 4.5.2 postgresql 9.4.1211').that_comes_before('Service[artifactory]') }
            end

            context 'should assign the currect user' do
              it { is_expected.to contain_user('jfrog') }
              it { is_expected.to contain_group('jfrog') }
              it {
                is_expected.to contain_archive("#{install_dir}/artifactory-#{artifactory_type}-4.5.1/tomcat/lib/postgresql-9.4.1211.jar").with_user('jfrog')
              }
              it {
                is_expected.to contain_archive("#{install_dir}/artifactory-#{artifactory_type}-4.5.2/tomcat/lib/postgresql-9.4.1211.jar").with_user('jfrog')
              }
            end

            context 'should assign the correct group' do
              it { is_expected.to contain_archive("#{install_dir}/artifactory-#{artifactory_type}-4.5.1/tomcat/lib/postgresql-9.4.1211.jar").with_group('jfrog') }
              it { is_expected.to contain_archive("#{install_dir}/artifactory-#{artifactory_type}-4.5.2/tomcat/lib/postgresql-9.4.1211.jar").with_group('jfrog') }
            end
          end
        end
      end

      context 'supported operating systems' do
        on_supported_os.each do |os, facts|
          context "on #{os}" do
            let(:facts) { facts }
            let(:params) { default_params }

            include_examples :compile

            context 'with embedded db' do
              it { is_expected.to compile.with_all_deps }
              it { is_expected.to have_artifactory__db__postgresql_resource_count(0) }
            end
          end
        end
      end
    end
  end
end
