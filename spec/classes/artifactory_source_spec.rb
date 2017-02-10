require 'spec_helper'

describe 'artifactory' do
  ['oss', 'pro'].each do |artifactory_type|
    context "#{artifactory_type}" do
      let :default_params do
        {
          'ensure'       => 'present',
          'type'         => artifactory_type,
          'install_type' => 'source',
          'plugins'      => {
            'download-directory' => {
              'url' => 'https://github.com/JFrogDev/artifactory-user-plugins/blob/master/cleanup/buildCleanup/buildCleanup.groovy'
            },
            'build-properties' => {
              'url' => 'https://github.com/JFrogDev/artifactory-user-plugins/blob/master/build/buildPropertySetter/buildPropertySetter.groovy'
            },
            'layout-properties' => {
              'url' => 'https://github.com/JFrogDev/artifactory-user-plugins/blob/master/storage/layoutProperties/layoutProperties.groovy'
            }
          },
          'sources'      => {
            'v4.5.1' => {
              'ensure'  => 'present',
              'version' => '4.5.1'
            },
            'v4.5.2' => {
              'ensure'  => 'present',
              'version' => '4.5.2'
            },
            'v5.0.1' => {
              'ensure'  => 'absent',
              'version' => '5.0.1'
            }
          }
        }
      end

      context 'supported operating systems' do
        on_supported_os.each do |os, facts|
          context "on #{os}" do
            let(:facts) { facts }
            let(:params) { default_params }

            case facts[:kernel]
              when 'FreeBSD'
                data_dir = '/usr/local/etc/artifactory'
                install_dir = '/usr/local/artifactory'
              else
                data_dir = '/var/lib/artifactory'
                install_dir = '/opt/jfrog/artifactory'
            end

            include_examples :compile

            context 'user/group exists' do
              it { is_expected.to contain_user('artifactory') }
              it { is_expected.to contain_group('artifactory') }
            end

            context 'installation without license key' do
              it { is_expected.to contain_class('artifactory::install').that_comes_before('artifactory::config') }
              it { is_expected.to contain_class('artifactory::config').that_comes_before('artifactory::plugins') }

              it { is_expected.to contain_class('artifactory') }
              it { is_expected.to contain_class('artifactory::config') }
              it { is_expected.to contain_class('artifactory::params') }

              it { is_expected.to contain_class('artifactory::plugins') }
              it { is_expected.to contain_class('artifactory::service').that_subscribes_to('artifactory::config') }
              it { is_expected.to contain_class('artifactory::service').that_subscribes_to('artifactory::plugins') }

              it { is_expected.to contain_service('artifactory') }
              it { is_expected.to contain_class('artifactory::params') }

              it { is_expected.to contain_class('artifactory::params') }

              it { is_expected.to contain_artifactory__package__source('v4.5.1') }
              it { is_expected.to contain_exec('tomcat permission (4.5.1)') }
              it { is_expected.to contain_exec('update _real_install_dir permissions (4.5.1)') }

              it { is_expected.to contain_artifactory__package__source('v4.5.2') }
              it { is_expected.to contain_exec('tomcat permission (4.5.2)') }
              it { is_expected.to contain_exec('update _real_install_dir permissions (4.5.2)') }

              it { is_expected.to contain_artifactory__package__source('v5.0.1') }
              it { is_expected.to contain_file("#{install_dir}/artifactory-#{artifactory_type}-5.0.1").with_ensure('absent') }

              it { is_expected.to_not contain_package('jfrog-artifactory') }

              it { is_expected.to_not contain_class('artifactory::repo::yum') }
              it { is_expected.to_not contain_class('artifactory::repo::apt') }

              it { is_expected.to contain_archive("jfrog-artifactory-#{artifactory_type}-4.5.1.zip") }
              it { is_expected.to contain_archive("jfrog-artifactory-#{artifactory_type}-4.5.2.zip") }

              it { is_expected.to contain_artifactory__plugin('build-properties').that_comes_before('artifactory::service') }
              it { is_expected.to contain_wget__fetch('build-properties').that_comes_before('artifactory::service') }

              it { is_expected.to contain_artifactory__plugin('download-directory').that_comes_before('artifactory::service') }
              it { is_expected.to contain_wget__fetch('download-directory').that_comes_before('artifactory::service') }

              it { is_expected.to contain_artifactory__plugin('layout-properties').that_comes_before('artifactory::service') }
              it { is_expected.to contain_wget__fetch('layout-properties').that_comes_before('artifactory::service') }

              it { is_expected.to contain_file("#{data_dir}/etc/artifactory.system.properties") }
              it { is_expected.to contain_file("#{data_dir}/etc/storage.properties") }
              it { is_expected.to contain_file("#{data_dir}/etc/artifactory.lic").with_ensure('absent') }
              it { is_expected.to contain_file("#{data_dir}/etc/plugins") }

              it { is_expected.to contain_file("#{install_dir}/artifactory-#{artifactory_type}-4.5.1/etc") }
              it { is_expected.to contain_file("#{install_dir}/artifactory-#{artifactory_type}-4.5.1/logs") }
              it { is_expected.to contain_file("#{install_dir}/artifactory-#{artifactory_type}-4.5.1/data") }

              it { is_expected.to contain_file("#{install_dir}/artifactory-#{artifactory_type}-4.5.2/etc") }
              it { is_expected.to contain_file("#{install_dir}/artifactory-#{artifactory_type}-4.5.2/logs") }
              it { is_expected.to contain_file("#{install_dir}/artifactory-#{artifactory_type}-4.5.2/data") }

              it { is_expected.to contain_exec("mktree #{install_dir}") }
              it { is_expected.to contain_file(install_dir) }
              it { is_expected.to contain_file(data_dir) }
              it { is_expected.to contain_file("#{data_dir}/data") }
              it { is_expected.to contain_file("#{data_dir}/logs") }
              it { is_expected.to contain_file("#{data_dir}/etc") }
              it { is_expected.to contain_file("#{data_dir}/misc") }

              case facts[:kernel]
              when 'FreeBSD'
                it { is_expected.to contain_exec('fix shebang on artifactory.sh (4.5.1)') }
                it { is_expected.to contain_exec('fix shebang on artifactory.sh (4.5.2)') }
                it { is_expected.to contain_file_line('artifactory rc.d entry') }
                it { is_expected.to contain_file('/usr/local/etc/rc.d/artifactory') }

              else
                if facts[:osfamily] == 'RedHat'
                  it { is_expected.to contain_file('/etc/rc.d/init.d/artifactory') }
                else
                  it { is_expected.to contain_file('/etc/init.d/artifactory') }
                end

              end
            end
          end
        end
      end
    end
  end
end
