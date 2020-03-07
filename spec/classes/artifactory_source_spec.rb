require 'spec_helper'

class Version < Array
  def initialize(s)
    super(s.split('.').map { |e| e.to_i })
  end

  def <(other)
    (self <=> other) < 0
  end

  def >(other)
    (self <=> other) > 0
  end

  def ==(other)
    (self <=> other) == 0
  end
end

describe 'artifactory' do
  ['oss', 'pro'].each do |artifactory_type|
    context artifactory_type.to_s do
      let :default_params do
        {
          'ensure'       => 'present',
          'type'         => artifactory_type,
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
            'v4.5.1' => {
              'ensure'  => 'present',
              'version' => '4.5.1',
            },
            'v4.5.2' => {
              'ensure'  => 'present',
              'version' => '4.5.2',
            },
            'v5.1.4' => {
              'ensure'  => 'present',
              'version' => '5.1.4',
            },
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

            case facts[:os]['family']
            when 'FreeBSD'
              data_dir = '/usr/local/etc/artifactory'
              install_dir = '/usr/local/artifactory'
            when 'RedHat'
              data_dir = '/var/lib/artifactory'
              install_dir = '/opt/artifactory'
            else
              data_dir = '/var/opt/jfrog/artifactory'
              install_dir = '/opt/artifactory'
            end

            include_examples :compile

            context 'user/group exists' do
              it { is_expected.to contain_user('artifactory') }
              it { is_expected.to contain_group('artifactory') }
            end

            context 'installation of plugins' do
              it { is_expected.to contain_artifactory__plugin('build-properties').that_comes_before('Service[artifactory]') }
              it { is_expected.to contain_archive('build-properties').that_comes_before('Service[artifactory]') }

              it { is_expected.to contain_artifactory__plugin('download-directory').that_comes_before('Service[artifactory]') }
              it { is_expected.to contain_archive('download-directory').that_comes_before('Service[artifactory]') }

              it { is_expected.to contain_artifactory__plugin('layout-properties').that_comes_before('Service[artifactory]') }
              it { is_expected.to contain_archive('layout-properties').that_comes_before('Service[artifactory]') }

              it { is_expected.to have_vcsrepo_count(0) }
            end

            context 'installation without license key' do
              it { is_expected.to contain_class('artifactory::install').that_comes_before('Class[artifactory::config]') }
              it { is_expected.to contain_class('artifactory::config').that_comes_before('Class[artifactory::plugins]') }

              it { is_expected.to contain_class('artifactory') }
              it { is_expected.to contain_class('artifactory::config') }

              it { is_expected.to contain_class('artifactory::plugins') }
              it { is_expected.to contain_class('artifactory::service').that_subscribes_to('Class[artifactory::config]') }
              it { is_expected.to contain_class('artifactory::service').that_subscribes_to('Class[artifactory::plugins]') }

              it { is_expected.to contain_service('artifactory') }

              it { is_expected.to contain_file("#{data_dir}/etc/artifactory.system.properties") }
              it { is_expected.to contain_file("#{data_dir}/etc/storage.properties") }
              it { is_expected.to contain_file("#{data_dir}/etc/db.properties") }
              it { is_expected.to contain_file("#{data_dir}/etc/artifactory.lic").with_ensure('absent') }
              it { is_expected.to contain_file("#{data_dir}/etc/plugins") }
              it { is_expected.to contain_file("#{data_dir}/data") }
              it { is_expected.to contain_file("#{data_dir}/logs") }
              it { is_expected.to contain_file("#{data_dir}/etc") }
              it { is_expected.to contain_file("#{data_dir}/misc") }

              it { is_expected.to contain_exec("mktree #{install_dir}") }
              it { is_expected.to contain_exec("mktree #{data_dir}") }

              ['v4.5.1', 'v4.5.2', 'v5.1.4', 'v6.1.0'].each do |ver|
                version_str = ver.delete('v')

                it { is_expected.to contain_artifactory__package__source(ver) }
                it { is_expected.to contain_artifactory__links("data links for #{version_str}") }
                it { is_expected.to contain_exec("tomcat permission (#{version_str})") }
                it { is_expected.to contain_exec("update _real_install_dir permissions (#{version_str})") }

                it { is_expected.to contain_archive("jfrog-artifactory-#{artifactory_type}-#{version_str}.zip") }

                it { is_expected.to contain_file("#{install_dir}/artifactory-#{artifactory_type}-#{version_str}/artifactory.default") }
                it { is_expected.to contain_file("#{install_dir}/artifactory-#{artifactory_type}-#{version_str}/etc") }
                it { is_expected.to contain_file("#{install_dir}/artifactory-#{artifactory_type}-#{version_str}/logs") }
                it { is_expected.to contain_file("#{install_dir}/artifactory-#{artifactory_type}-#{version_str}/data") }

                if Version.new(version_str) > Version.new('5.1.1')
                  it { is_expected.to contain_file("#{install_dir}/artifactory-#{artifactory_type}-#{version_str}/access") }
                  it { is_expected.to contain_file("#{install_dir}/artifactory-#{artifactory_type}-#{version_str}/run") }
                  it { is_expected.to contain_file("#{install_dir}/artifactory-#{artifactory_type}-#{version_str}/support") }
                end

                case facts[:os]['family']
                when 'FreeBSD'
                  it { is_expected.to contain_exec("fix shebang on artifactory.sh (#{version_str})") }
                  it { is_expected.to contain_exec('set rcvar') }
                  it { is_expected.to contain_file('/usr/local/etc/rc.d/artifactory') }

                else
                  it { is_expected.to contain_file('/etc/systemd/system/multi-user.target.wants/artifactory.service') }

                end
              end
            end
          end
        end
      end
    end
  end
end
