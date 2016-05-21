#!/usr/bin/ruby -S rspec
#
#  Test the rhsm_available_repos fact
#
#   Copyright 2016 WaveClaw <waveclaw@hotmail.com>
#
#   See LICENSE for licensing.
#

require 'spec_helper'
require 'facter/util/ipa_utils'
require 'facter/ipa_domain'
ssd_examples = [
  {
    :desc     => 'nothing when there is no data',
    :data     => '',
    :expected => nil
  },
  {
    :desc     => 'the domain in a simple example',
    :data     => 'ipa_domain = example.com',
    :expected => 'example.com'
  },
  {
    :desc     => 'the domain in a set of garbage data',
    :data     => '
garbage
ipa_domain=example.com
some=moretrash
',
    :expected => 'example.com'
  },
  {
    :desc     => 'the domain when there is an alpha numeric domain',
    :data     => 'ipa_domain = freeipa0001.something.',
    :expected => 'freeipa0001.something.'
  }
]

ldap_examples = [
  {
    :desc     => 'nothing when there is no data',
    :data     => '',
    :expected => nil
  },
  {
    :desc     => 'nothing for non-null garbage',
    :data     => '
some nifty garbageURI stuff

',
    :expected => nil
  },
  {
    :desc     => 'an ldap BASE with comments',
    :data     => '
BASE dc=example,dc=net
#BASE dc=wrong,dc=example,dc=foo
ipa_server ldap.example.com
stuff',
    :expected => 'example.net'
  },
  {
    :desc     => 'an ldap BASE',
    :data     => 'BASE dc=example,dc=net',
    :expected => 'example.net'
  },
  {
    :desc     => 'an ldap BASE with no parts',
    :data     => 'BASE dc=example.net',
    :expected => 'example.net'
  },
]

krb5_examples = [
  {
    :desc     => 'a dotted example',
    :realm    => 'EXAMPLE.COM',
    :data     => '
default_realm = EXAMPLE.COM

[realms]
EXAMPLE.COM = {
  default_domain = example.com
}',
    :expected => 'example.com'
  },
  {
    :desc     => 'a simple example',
    :realm    => 'EXAMPLE.COM',
    :data     => '
default_realm = EXAMPLE.COM

[realms]
EXAMPLE.COM = {
  default_domain = example
}',
    :expected => 'example'
  },
  {
    :desc     => 'nothing for a commented example',
    :realm    => 'EXAMPLE.COM',
    :data     => '
default_realm = EXAMPLE.COM

#[realms]
#EXAMPLE.COM = {
#  default_domain = ipa.example.com
#}',
    :expected => nil
  }
]

describe Facter::Util::Ipa_domain, :type => :puppet_function do
  context 'when using ipatools' do
    before :each do
      allow(File).to receive(:exist?).with('/etc/sssd/sssd.conf') { false }
      allow(File).to receive(:exist?).with('/etc/openldap/ldap.conf') { false }
      allow(File).to receive(:exist?).with('/etc/krb5.conf' ) { false }
      allow(File).to receive(:exist?).with('/usr/sbin/ipa' ) { true }
    end
    it 'gets a value from the ipatools method' do
      expect(Facter::Util::Ipa_utils).to receive(:prepare_kinit) { 'foo' }
      expect(Facter::Util::Resolution).to receive(:exec).with('foo') { 'thing' }
      expect(Facter::Util::Ipa_domain.ipa_domain).to eq('thing')
    end
    it 'ipatools throws exceptions when there is an error' do
      expect(Facter::Util::Ipa_utils).to receive(:prepare_kinit) { throw Error }
      expect{Facter::Util::Ipa_domain.ipatools}.to raise_error(Exception)
    end
  end
  context 'with just sssd.conf' do
    before :each do
      allow(File).to receive(:exist?).with('/etc/sssd/sssd.conf') { true }
      allow(File).to receive(:exist?).with('/etc/krb5.conf') { false }
      allow(File).to receive(:exist?).with('/etc/openldap/ldap.conf') { false }
      allow(File).to receive(:exist?).with('/usr/sbin/ipa' ) { false }
    end
    it "should return nothing when there is an error" do
      expect(File).to receive(:open).with(
        '/etc/sssd/sssd.conf','r') { throw Error }
      expect(Facter::Util::Ipa_domain.ipa_domain).to eq(nil)
    end
    ssd_examples.each {|xample|
      it "should return #{xample[:desc]}" do
        expect(File).to receive(:open).with(
          '/etc/sssd/sssd.conf','r') { StringIO.new(xample[:data]) }
        expect(Facter::Util::Ipa_domain.ipa_domain).to eq(xample[:expected])
      end
    }
  end

  context 'with just ldap.conf' do
    before :each do
      allow(File).to receive(:exist?).with('/etc/sssd/sssd.conf' ) { false }
      allow(File).to receive(:exist?).with('/usr/sbin/ipa' ) { false }
      allow(File).to receive(:exist?).with('/usr/krb5.conf' ) { false }
    end
    it "should throw any error" do
      expect(Facter::Util::Ipa_utils).to receive(:search_ldap_conf).with(/^[^#]?BASE\s+(\S+)/) { throw Error }
      expect{Facter::Util::Ipa_domain.ldap}.to raise_error(NameError)
    end
    ldap_examples.each {|xample|
      it "should return a master for #{xample[:desc]}" do
        expect(File).to receive(:exist?).with('/etc/openldap/ldap.conf' ) { true }
        expect(File).to receive(:open).with(
          '/etc/openldap/ldap.conf','r') { StringIO.new(xample[:data]) }
        expect(Facter::Util::Ipa_domain.ipa_domain).to eq(xample[:expected])
      end
    }
  end

  context 'with just krb5.conf' do
    before :each do
        allow(File).to receive(:exist?).with('/etc/sssd/sssd.conf' ) { false }
        allow(File).to receive(:exist?).with('/etc/openldap/ldap.conf' ) { false }
    end
    it "should return nothing when there is an error" do
      expect(File).to receive(:exist?).with( '/etc/krb5.conf') { true }
      expect(File).to receive(:open).with('/etc/krb5.conf', 'r') { throw Error }
      expect(Facter::Util::Ipa_domain.ipa_domain).to eq(nil)
    end
    it "should return nothing when there is a no data" do
      expect(File).to receive(:exist?).with( '/etc/krb5.conf' ) { true }
      expect(File).to receive(:open).with('/etc/krb5.conf','r') { '' }
      expect(Facter::Util::Ipa_domain.ipa_domain).to eq(nil)
    end
    krb5_examples.each { |xample|
      it "should return #{xample[:desc]}" do
        expect(File).to receive(:exist?).with( '/etc/krb5.conf' ) { true }
        expect(File).to receive(:open).with('/etc/krb5.conf','r') { xample[:data] }
        expect(File).to receive(:open).with('/etc/krb5.conf','r') { xample[:data] }
        expect(Facter::Util::Ipa_domain.ipa_domain).to eq(xample[:expected])
      end
    }
  end
  context 'on an unsupported platform' do
    before :each do
      allow(File).to receive(:exist?).with('/etc/sssd/sssd.conf' ) { false }
      allow(File).to receive(:exist?).with('/etc/krb5.conf' ) { false }
      allow(File).to receive(:exist?).with('/etc/openldap/ldap.conf' ) { false }
    end
    it "should return nothing" do
      expect(Facter::Util::Ipa_domain.ipa_domain).to eq(nil)
    end
  end
end
