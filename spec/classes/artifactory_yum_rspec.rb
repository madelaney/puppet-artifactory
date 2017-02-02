require 'spec_helper'

describe 'artifactory' do
  let(:params) do
    {
      ensure: 'present',
      type: 'pro',
      license: 'my_license_key',
      install_type: 'yum'
    }
  end

  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        include_examples :compile

        context 'artifactory pro installing via yum repo' do
          it { is_expected.to contain_class('artifactory::repo::yum').that_comes_before('artifactory::config') }
          it { is_expected.to contain_package('jfrog-artifactory-oss') }

          it { is_expected.to_not contain_class('artifactory::repo::apt') }
        end
      end
    end
  end
end
