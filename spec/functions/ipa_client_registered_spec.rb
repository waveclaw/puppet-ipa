#!/usr/bin/ruby -S rspec
#
#  Test the ipa_client_registered fact
#
#   Copyright 2016 WaveClaw <waveclaw@hotmail.com>
#
#   See LICENSE for licensing.
#

require 'spec_helper'
require 'facter/ipa_client_registered'

describe Facter::Util::Ipa_client_registered, :type => :puppet_function do
  context 'on an unsupported platform' do
    before :each do
      allow(File).to receive(:exist?).with('/etc/krb5.keytab') { false }
      allow(File).to receive(:exist?).with('/etc/ipa/ca.pem') { false }      
    end
    it "should return nothing" do
      expect(Facter::Util::Ipa_client_registered.ipa_client_registered).to eq(false)
    end
  end
  context 'on a supported platform with ipa-client available' do
    before :each do
      allow(Facter).to receive(:value).with(:ipa_master) {'bar'}
      allow(Facter).to receive(:value).with(:ipa_domain) {'example.com'}
      allow(Facter).to receive(:value).with(:fqdn) {'foo.example.com'}
      allow(File).to receive(:exist?).with('/usr/sbin/ipa') { true }
    end
    it "should return false when there is an error" do
    end
    it "should return true when there is a registration" do
    end
  end
  context 'on a supported platform with ipa integration' do
    before :each do
    end
    it "should return false when there is an error" do
    end
    it "should return true when there is a registration" do
    end
  end
  context 'on a supported platform with k5start' do
    before :each do
      allow(Facter).to receive(:value).with(:ipa_master) {'bar'}
      allow(Facter).to receive(:value).with(:ipa_domain) {'example.com'}
      allow(Facter).to receive(:value).with(:fqdn) {'foo.example.com'}
      allow(File).to receive(:exist?).with('/usr/sbin/ipa') { false }
      allow(File).to receive(:exist?).with('/etc/ipa/ca.crt') { true }
      allow(File).to receive(:exist?).with('/usr/bin/k5start') { true }
      allow(File).to receive(:exist?).with('/usr/bin/ldapsearch') { true }
      allow(File).to receive(:exist?).with('/usr/lib/mit/bin/kadmin') { false }
      allow(File).to receive(:exist?).with('/usr/bin/getent') { false }
    end
=begin
    it "should return false when there is an error" do
      expect(Facter::Util::Resolution).to receive(:exec).with(
      '/usr/bin/ldapsearch -x -b dc=example,dc=com -h ldap://bar \
 fqdn=foo.example.com,cn=computers,cn=accounts,dc=example,dc=com') { throw Error }
      expect(Facter::Util::Ipa_client_registered.ipa_client_registered).to eq(false)
    end
    it "should return true when there is a registration" do
      expect(Facter::Util::Resolution).to receive(:exec).with(
      '/usr/bin/ldapsearch -x -b dc=example,dc=com -h ldap://bar \
fqdn=foo.example.com,cn=computers,cn=accounts,dc=example,dc=com') { 'stuff' }
      expect(Facter::Util::Ipa_client_registered.ipa_client_registered).to eq(true)
    end
=end
  end
  context 'on a supported platform with ldap only' do
    before :each do
      allow(Facter).to receive(:value).with(:ipa_master) {'bar'}
      allow(Facter).to receive(:value).with(:ipa_domain) {'example.com'}
      allow(Facter).to receive(:value).with(:fqdn) {'foo.example.com'}
      allow(File).to receive(:exist?).with('/usr/sbin/ipa') { false }
      allow(File).to receive(:exist?).with('/etc/ipa/ca.crt') { true }
      allow(File).to receive(:exist?).with('/usr/bin/k5start') { true }
      allow(File).to receive(:exist?).with('/usr/bin/ldapsearch') { true }
      allow(File).to receive(:exist?).with('/usr/lib/mit/bin/kadmin') { false }
      allow(File).to receive(:exist?).with('/usr/bin/getent') { false }
    end
=begin
    it "should return false when there is an error" do
      expect(Facter::Util::Resolution).to receive(:exec).with(
      '/usr/bin/ldapsearch -x -b dc=example,dc=com -h ldap://bar \
 fqdn=foo.example.com,cn=computers,cn=accounts,dc=example,dc=com') { throw Error }
      expect(Facter::Util::Ipa_client_registered.ipa_client_registered).to eq(false)
    end
    it "should return true when there is a registration" do
      expect(Facter::Util::Resolution).to receive(:exec).with(
      '/usr/bin/ldapsearch -x -b dc=example,dc=com -h ldap://bar \
fqdn=foo.example.com,cn=computers,cn=accounts,dc=example,dc=com') { 'stuff' }
      expect(Facter::Util::Ipa_client_registered.ipa_client_registered).to eq(true)
    end
  end
  context 'on a supported platform with just get_* libraries' do
    before :each do
      allow(Facter).to receive(:value).with(:ipa_master) {'bar'}
      allow(Facter).to receive(:value).with(:ipa_domain) {'example.com'}
      allow(Facter).to receive(:value).with(:fqdn) {'foo.example.com'}
      allow(File).to receive(:exist?).with('/usr/sbin/ipa') { false }
      allow(File).to receive(:exist?).with('/etc/ipa/ca.crt') { true }
      allow(File).to receive(:exist?).with('/usr/bin/k5start') { false }
      allow(File).to receive(:exist?).with('/usr/bin/ldapsearch') { false }
      allow(File).to receive(:exist?).with('/usr/lib/mit/bin/kadmin') { false }
      allow(File).to receive(:exist?).with('/usr/bin/getent') { true }
    end
    it "should return false when there is an error" do
    end
    it "should return true when there is a registration" do
    end
=end
  end
end
