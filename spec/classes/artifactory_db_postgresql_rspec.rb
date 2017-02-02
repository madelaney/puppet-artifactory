require 'spec_helper'

describe 'artifactory' do
  ['oss', 'pro'].each do |artifactory_type|
    context "#{artifactory_type}" do
      let :default_params do
        {
          'ensure'       => 'present',
          'license'      => 'my_license_key',
          'type'         => artifactory_type,
          'install_type' => 'source'
        }
      end

      context 'supported operating systems' do
        on_supported_os.each do |os, facts|
          context "on #{os}" do
            let(:facts) { facts }
            let(:params) do
              {
                'db_type' => 'postgresql'
              }.merge(default_params)
            end

            include_examples :compile

            context 'should install postgre jdbc driver' do
              it { is_expected.to contain_artifactory__db__postgresql('artifactory 4.5.1 postgresql 9.4.1211').that_comes_before('artifactory::service') }
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
