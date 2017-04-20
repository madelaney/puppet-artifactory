require 'spec_helper'

describe 'artifactory' do
  let :default_params do
    {
      'ensure'       => 'present',
      'license'      => 'my_license_key',
      'type'         => 'pro',
      'install_type' => 'source'
    }
  end

  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:params) { default_params }
        let(:facts) { facts }

        include_examples :compile

        context 'artifactory should enable a service' do
          it { is_expected.to contain_class('artifactory::service').that_requires('artifactory::install') }
        end
      end
    end
  end
end
