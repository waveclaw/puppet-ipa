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

  context 'when using ipa-client' do
    it "should return nil when there is an error" do
      expect(Facter::Util::Ipa_utils).to receive(:prepare_kinit) { '/bin/true' }
      expect(Facter::Util::Resolution).to receive(:exec) { throw Error }
      expect{ Facter::Util::Ipa_client_registered.ipa_client(
        'foo.example.com') }.to raise_error(NameError, /.*/)
    end
    it "should return true when there is a registration" do
      expect(Facter::Util::Ipa_utils).to receive(:prepare_kinit).with(
      "/usr/bin/ipa host-show $(hostname).$(domainname)") { nil }
      expect(Facter::Util::Resolution).to receive(:exec).with(nil) { true }
      expect(Facter::Util::Ipa_client_registered.ipa_client).to eq(true)
    end
    it "should return false when there is no registration" do
      expect(Facter::Util::Ipa_utils).to receive(:prepare_kinit).with(
      "/usr/bin/ipa host-show $(hostname).$(domainname)") { nil }
      expect(Facter::Util::Resolution).to receive(:exec).with(nil) { nil }
      expect(Facter::Util::Ipa_client_registered.ipa_client).to eq(false)
    end
  end

  context 'when using IPA JSON API' do
    let(:fake_class) { Class.new }
    def prep_bot
      fake_IPA = double("IPA")
      stub_const("IPA", fake_class)
      expect(IPA).to receive(:new) { fake_IPA }
      expect(fake_IPA).to receive(:create_robot)
      fake_IPA
    end
    it "should return nothing when there is an error" do
      fake_IPA = prep_bot
      expect(fake_IPA).to receive(:post) { throw Error }
      expect{ Facter::Util::Ipa_client_registered.ipa_query(
       ipa_master='bar', fqdn='foo.example.com') }.to raise_error(NameError, /.*/)
    end
    it "should return false when there is a registration that doesn't match fqdn" do
      fake_IPA = prep_bot
      expect(fake_IPA).to receive(:post).with('host_find',[['foo.example.com'],{}]) {
        { 'result' => {'result' => [{ 'fqdn' => ['something']}]} }
      }
      expect(Facter::Util::Ipa_client_registered.ipa_query(
             ipa_master='bar', fqdn='foo.example.com')).to eq(false)
    end
    it "should return true when there is a registration that does match fqdn" do
      fake_IPA = prep_bot
      expect(fake_IPA).to receive(:post).with('host_find',[['foo.example.com'],{}]) {
        { 'result' => {'result' => [{ 'fqdn' => ['foo.example.com']}]} }
      }
      expect(Facter::Util::Ipa_client_registered.ipa_query(
             ipa_master='bar', fqdn='foo.example.com')).to eq(true)
    end
  end

  context 'when using k5start + ldapsearch' do
    cmd = "/usr/bin/k5start -u host/foo.example.com -f /etc/krb5.keytab" +
       " -- /usr/bin/ldapsearch -Y GSSAPI -H ldap://bar -b EXAMPLE.COM" +
       " fqdn=foo.example.com | awk '/^krbLastPwdChange/ { print $2}'"
    it "should return nothing when there is an error" do
      expect(Facter::Util::Resolution).to receive(:exec).with(cmd) { throw Error }
      expect{ Facter::Util::Ipa_client_registered.k5start_registration(
        ipa_master='bar', ipa_domain='EXAMPLE.COM', fqdn='foo.example.com')
        }.to raise_error(NameError, /.*/)
    end
    it "should return true when there is a registration" do
      expect(Facter::Util::Resolution).to receive(:exec).with(cmd) { 'stuff' }
      expect(Facter::Util::Ipa_client_registered.k5start_registration(
        ipa_master='bar', ipa_domain='EXAMPLE.COM', fqdn='foo.example.com') ).to eq(true)
    end
    it "should return false when nothing was returned" do
      expect(Facter::Util::Resolution).to receive(:exec).with(cmd) { nil }
      expect(Facter::Util::Ipa_client_registered.k5start_registration(
        ipa_master='bar', ipa_domain='EXAMPLE.COM', fqdn='foo.example.com') ).to eq(false)
    end
  end

  context 'when using just ldapsearch' do
    cmd = '/usr/bin/ldapsearch -x -b dc=example,dc=com -h ldap://bar ' +
          'fqdn=foo.example.com,cn=computers,cn=accounts,dc=example,dc=com'
    it "should return nothing when there is an error" do
      expect(Facter::Util::Resolution).to receive(:exec).with(cmd) { throw Error }
      expect{Facter::Util::Ipa_client_registered.ldaps_registration(
        ipa_master='bar', ipa_domain='example.com', fqdn='foo.example.com')
      }.to raise_error(NameError, /.*/)
    end
    it "should return true when there is a registration" do
      expect(Facter::Util::Resolution).to receive(:exec).with(cmd) { 'stuff' }
      expect(Facter::Util::Ipa_client_registered.ldaps_registration(
        ipa_master='bar', ipa_domain='example.com', fqdn='foo.example.com')
        ).to eq(true)
    end
    it "should return false when there is no registration" do
      expect(Facter::Util::Resolution).to receive(:exec).with(cmd) { nil }
      expect(Facter::Util::Ipa_client_registered.ldaps_registration(
        ipa_master='bar', ipa_domain='example.com', fqdn='foo.example.com')
        ).to eq(false)
    end
  end

  context 'when falling back to getent' do
    cmd = '/usr/bin/getent passwd'
    it "should return nothing when there is an error" do
      expect(Facter::Util::Resolution).to receive(:exec).with(cmd) { throw Error }
      expect{Facter::Util::Ipa_client_registered.getent_registration
       }.to raise_error(NameError, /.*/)
    end
    it "should return true when there is a registration" do
      expect(Facter::Util::Resolution).to receive(:exec).with(cmd) { 'stuff' }
      expect(File).to receive(:readlines).with('/etc/passwd') { "not\nstuff\n" }
      expect(Facter::Util::Ipa_client_registered.getent_registration).to eq(true)
    end
    it "should return nothing when there is no registration" do
      expect(Facter::Util::Resolution).to receive(:exec).with(cmd) { 'stuff' }
      expect(File).to receive(:readlines).with('/etc/passwd') { 'stuff' }
      expect(Facter::Util::Ipa_client_registered.getent_registration).to eq(nil)
    end
    it "should return no getent result was found" do
      expect(Facter::Util::Resolution).to receive(:exec).with(cmd) { '' }
      expect(File).to receive(:readlines).with('/etc/passwd') { '' }
      expect(Facter::Util::Ipa_client_registered.getent_registration).to eq(nil)
    end

  end

context 'on an unsupported platform' do
  before :each do
    allow(File).to receive(:exist?).with('/etc/krb5.keytab') { false }
    allow(File).to receive(:exist?).with('/etc/ipa/ca.crt') { false }
  end
  it "should return nothing" do
    expect(Facter.value(:ipa_client_registered)).to eq(nil)
  end
end

context 'on a supported platform' do
  cases = {
    'IPA JSON API' => {
'ipa_query' => true,
'ipa' => false,
'ldapsearch' => false,
'k5start' => false,
'ldaponly' => false,
'getent'  => false },
    'IPA host-show' => {
'ipa_query' => false,
'ipa' => true,
'ldapsearch' => false,
'k5start' => false,
'ldaponly' => false,
'getent'  => false },
    'k5start+ldapsearch' => {
'ipa_query' => false,
'ipa' => false,
'ldapsearch' => true,
'k5start' => true,
'ldaponly' => false,
'getent'  => false },
    'ldaps only' => {
'ipa_query' => false,
'ipa' => false,
'ldapsearch' => true,
'k5start' => false,
'ldaponly' => true,
'getent'  => false },
    'getent' => {
'ipa_query' => false,
'ipa' => false,
'ldapsearch' => false,
'k5start' => false,
'ldaponly' => false,
'getent'  => true },
  }
  before :each do
    allow(Facter).to receive(:value).with(:ipa_client_registered).and_call_original
    allow(File).to receive(:exist?).with('/etc/krb5.keytab') { true }
    allow(File).to receive(:exist?).with('/etc/ipa/ca.crt') { true }
    allow(Facter).to receive(:value).with(:ipa_master) {'bar'}
    allow(Facter).to receive(:value).with(:ipa_domain) {'example.com'}
    allow(Facter).to receive(:value).with(:fqdn) {'foo.example.com'}
  end
  cases.keys.each { |key|
    it "should call #{key} as needed" do
      allow(File).to receive(:exist?).with('/usr/bin/ipa') { cases[key]['ipa'] }
      allow(File).to receive(:exist?).with('/usr/bin/k5start') { cases[key]['k5start'] }
      allow(File).to receive(:exist?).with('/usr/bin/ldapsearch') { cases[key]['ldapsearch'] }
      allow(File).to receive(:exist?).with('/usr/bin/getent') { cases[key]['getent'] }
      expect(Facter::Util::Ipa_client_registered).to receive(:ipa_query) { cases[key]['ipa_query'] }
      allow(Facter::Util::Ipa_client_registered).to receive(:ipa_client) { cases[key]['ipa'] }
      allow(Facter::Util::Ipa_client_registered).to receive(:k5start_registration) { cases[key]['k5start'] }
      allow(Facter::Util::Ipa_client_registered).to receive(:ldaps_registration) { cases[key]['ldaponly'] }
      allow(Facter::Util::Ipa_client_registered).to receive(:getent_registration) { cases[key]['getent'] }
      expect(Facter::Util::Ipa_client_registered.ipa_client_registered).to eq(true)
    end
  }
end

end
