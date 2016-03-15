#!/usr/bin/ruby -S rspec
#
#  Test the rhsm_available_repos fact
#
#   Copyright 2016 WaveClaw <waveclaw@hotmail.com>
#
#   See LICENSE for licensing.
#

require 'spec_helper'
require 'facter/ipa_master'

ssd_examples = [
  {
    :desc     => 'nothing when there is no data',
    :data     => '',
    :expected => nil
  },
  {
    :desc     => 'the whole list when there is a list of data',
    :data     => 'ipa_server = _srv_, ipa.example.com',
    :expected => '_srv_, ipa.example.com'
  },
  {
    :desc     => 'the whole list when there is a different list of data',
    :data     => '
garbage
ipa_server=ipa.example.com,_srv_
some=moretrash
',
    :expected => 'ipa.example.com,_srv_'
  },
  {
    :desc     => 'the whole list when there is an IP address in a list of data',
    :data     => 'ipa_server =  1.2.3.4, freeipa',
    :expected => '1.2.3.4, freeipa'
  },

  {
    :desc     => 'the whole list when there is an IP address',
    :data     => 'ipa_server =  1.2.3.4',
    :expected => '1.2.3.4'
  },

  {
    :desc     => 'the whole list when there is an alpha numeric host',
    :data     => 'ipa_server =  freeipa0001',
    :expected => 'freeipa0001'
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
    :desc     => 'an ldap portless URI',
    :data     => '
ipa_server =  1.2.3.4, freeipa
URI	ldap://ldap.example.com
stuff',
    :expected => 'ldap.example.com'
  },
  {
    :desc     => 'an ldap URI with port',
    :data     => 'URI	ldap://ldap.example.com:389',
    :expected => 'ldap.example.com'
  },
  {
    :desc     => 'an ldaps portless URI',
    :data     => 'URI	ldaps://ldap.example.com',
    :expected => 'ldap.example.com'
  },
  {
    :desc     => 'an ldaps URI with port',
    :data     => 'URI	ldaps://ldap.example.com:636',
    :expected => 'ldap.example.com'
  },
  {
    :desc     => 'an ldap URI with numerical host',
    :data     => 'URI	ldap://1.2.3.4',
    :expected => '1.2.3.4'
  },
  {
    :desc     => 'an ldap URI with numerical host with port',
    :data     => 'URI	ldap://1.2.3.4:389',
    :expected => '1.2.3.4'
  }
]

krb5_examples = [
  {
    :desc     => 'the kdc for a master example',
    :realm    => 'EXAMPLE.COM',
    :data     => '
default_realm = EXAMPLE.COM

[realms]
EXAMPLE.COM = {
  master_kdc = ipa.example.com:88
}',
    :expected => 'ipa.example.com'
  },
  {
    :desc     => 'the kdc for a simple example',
    :realm    => 'EXAMPLE.COM',
    :data     => '
default_realm = EXAMPLE.COM

[realms]
EXAMPLE.COM = {
  kdc = ipa.example.com:1234
}',
    :expected => 'ipa.example.com'
  },
  {
    :desc     => 'nothing for a commented example',
    :realm    => 'EXAMPLE.COM',
    :data     => '
default_realm = EXAMPLE.COM

#[realms]
#EXAMPLE.COM = {
#  kdc = ipa.example.com:1234
#}',
    :expected => nil
  }
]

describe Facter::Util::Ipa_master, :type => :puppet_function do
  context 'with just sssd.conf' do
    before :each do
      allow(File).to receive(:exist?).with(
      '/etc/sssd/sssd.conf' ) { true }
      allow(File).to receive(:exist?).with(
      '/etc/krb5.conf' ) { false }
      allow(File).to receive(:exist?).with(
      '/etc/openldap/ldap.conf' ) { false }

    end
    it "should return nothing when there is an error" do
      expect(File).to receive(:open).with(
        '/etc/sssd/sssd.conf','r') { throw Error }
      expect(Facter::Util::Ipa_master.ipa_master).to eq(nil)
    end
    ssd_examples.each {|xample|
      it "should return #{xample[:desc]}" do
        expect(File).to receive(:open).with(
          '/etc/sssd/sssd.conf','r') { StringIO.new(xample[:data]) }
        expect(Facter::Util::Ipa_master.ipa_master).to eq(xample[:expected])
      end
    }
  end
  context 'with just ldap.conf' do
    before :each do
      allow(File).to receive(:exist?).with('/etc/sssd/sssd.conf' ) { false }
    end
    it "should return nothing when there is an error" do
      expect(File).to receive(:exist?).with('/etc/openldap/ldap.conf' ) { true }
      expect(File).to receive(:open).with(
        '/etc/openldap/ldap.conf','r') { throw Error }
      expect(Facter::Util::Ipa_master.ipa_master).to eq(nil)
    end
    ldap_examples.each {|xample|
      it "should return a master for #{xample[:desc]}" do
        expect(File).to receive(:exist?).with('/etc/openldap/ldap.conf' ) { true }
        expect(File).to receive(:open).with(
          '/etc/openldap/ldap.conf','r') { StringIO.new(xample[:data]) }
        expect(Facter::Util::Ipa_master.ipa_master).to eq(xample[:expected])
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
      expect(Facter::Util::Ipa_master.ipa_master).to eq(nil)
    end
    it "should return nothing when there is a no data" do
      expect(File).to receive(:exist?).with( '/etc/krb5.conf' ) { true }
      expect(File).to receive(:open).with('/etc/krb5.conf','r') { '' }
      expect(Facter::Util::Ipa_master.ipa_master).to eq(nil)
    end
    krb5_examples.each { |xample|
      it "should return #{xample[:desc]}" do
        expect(File).to receive(:exist?).with( '/etc/krb5.conf' ) { true }
        expect(File).to receive(:open).with('/etc/krb5.conf','r') { xample[:data] }
        expect(File).to receive(:open).with('/etc/krb5.conf','r') { xample[:data] }
        expect(Facter::Util::Ipa_master.ipa_master).to eq(xample[:expected])
      end
    }
  end
  context 'on an unsupported platform' do
    before :each do
      allow(File).to receive(:exist?).with(
      '/etc/sssd/sssd.conf' ) { false }
      allow(File).to receive(:exist?).with(
      '/etc/krb5.conf' ) { false }
      allow(File).to receive(:exist?).with(
      '/etc/openldap/ldap.conf' ) { false }
    end
    it "should return nothing" do
      expect(Facter::Util::Ipa_master.ipa_master).to eq(nil)
    end
  end
end
