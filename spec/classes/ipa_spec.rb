require 'spec_helper'

distpkg = { :Debian => ['sssd', 'kstart', 'krb5-config', 'krb5-user', 'libpam-krb5' ], 
            :RedHat => ['sssd', 'ipa-client', 'kstart' ],
            :Suse => ['sssd', 'kstart' ] }

describe 'ipa' do
  shared_examples_for 'a supported operating system' do
    it { is_expected.to contain_class('ipa') }
    it { is_expected.to contain_class('ipa::defaults') }
    it { is_expected.to contain_class('ipa::install').that_comes_before('ipa::config') }
    it { is_expected.to contain_class('ipa::config').that_notifies('ipa::service') }
    it { is_expected.to contain_class('ipa::service') }
    it { is_expected.to contain_class('ipa::install::repo') }
    it { is_expected.to contain_class('ipa::install::client') }
        
    it { is_expected.to contain_file('/etc/ipa').with({'ensure' => 'directory'}) }
    it { is_expected.to contain_file('/etc/ipa/ca.pem').with({'ensure' => 'file'}) }
    it { is_expected.to contain_file('/etc/ipa/ipa.crt').with({'ensure' => 'file'}) }
    it { is_expected.to contain_file('/etc/ipa/ca.crt').with({'ensure' => 'file'}) }

    it { is_expected.to contain_file('/var/log/krb5').with({'ensure' => 'directory'}) }
    it { is_expected.to contain_file('/etc/krb5.conf').with({'ensure' => 'file'}) }
  end

  context 'supported operating systems' do
   ['Debian', 'RedHat', 'Suse'].each { |osfamily|
    describe "ipa client without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
        }}
        it { is_expected.to compile.with_all_deps }
        it_behaves_like 'a supported operating system'

        if osfamily == 'RedHat' 
          it { is_expected.to contain_yumrepo('mkosek-freeipa') }
        end
        distpkg[osfamily.to_sym].each do |pkg|
          it { is_expected.to contain_package(pkg).with_ensure('present') }
        end
        it { is_expected.to contain_service('sssd').with_ensure('running') }
        #it { should_not contain_notify('Operating System Nexenta is not supported by the Puppet DSL part of the IPA module.') }
      end
   }
  end

  context 'unsupported operating system' do
    describe 'ipa class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('ipa') }
      #it { is_expected.to_not contain_class('ipa::defaults') }
      #it { is_expected.to_not contain_class('ipa::install') }
      #it { is_expected.to_not contain_class('ipa::config') }
      #it { is_expected.to_not contain_class('ipa::service') }
      it { is_expected.to contain_notify('Operating System Nexenta is not supported by the Puppet DSL part of the IPA module.') }
      #it { expect { is_expected.to contain_package('ipa') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end

  context 'on an IPA Server' do
    [ 'master', 'replica'].each do |role|
      describe "#{role} role on RedHat" do
        let(:params) {{
          :role => role
        }}
        let(:facts) {{
          :osfamily => 'RedHat',
          :ipa_role => role
        }}
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('ipa') }
        it { is_expected.to contain_class('ipa::install::server') }
        ['sssd', 'freeipa-server', 'ipa-client' ].each do |pkg|
          it { is_expected.to contain_package(pkg).with_ensure('present') }
        end
        [ 'ipa-dnskeysyncd', 'sssd', 'ipa-ods-exporter', 'ipa', 'ipa_memcached'].each do |svc|
         it { is_expected.to contain_service(svc).with_ensure('running') }
        end # end svc
      end # end describe
    end # end role
  end # end context
  

  context 'on an IPA Server' do
    [ 'master', 'replica'].each do |role|
      describe "#{role} role on an unsupported platform" do
        let(:params) {{
          :role => role
        }}
        let(:facts) {{
          :osfamily => 'Suse',
          :ipa_role => role
        }}
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('ipa') }
        ['freeipa-server', 'ipa-client' ].each do |pkg|
          it { should_not contain_package(pkg).with_ensure('present') }
        end
        [ 'ipa-dnskeysyncd', 'ipa-ods-exporter', 'ipa', 'ipa_memcached'].each do |svc|
         it { should_not contain_service(svc).with_ensure('running') }
        end # end svc
        it { is_expected.to contain_package('sssd').with_ensure('present') }
        it { is_expected.to contain_service('sssd').with_ensure('running') }
      end # end describe
    end # end role
  end # end context
  
end
