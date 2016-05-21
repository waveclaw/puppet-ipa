#!/usr/bin/ruby -S rspec
#
#  Test the ipa_client_registered fact
#
#   Copyright 2016 WaveClaw <waveclaw@hotmail.com>
#
#   See LICENSE for licensing.
#

require 'spec_helper'
require 'stringio'
require 'facter/util/ipa_utils'

describe Facter::Util::Ipa_utils, :type => :puppet_function do

  context 'for prepare_kinit' do
   base = "/usr/bin/kinit $(klist /etc/krb5.keytab | awk '/example.com/ {print $2}' ) -k -t /etc/krb5.keytab && "
   it 'should assemble a command from a null string' do
     expect(Facter).to receive(:value) { 'example.com' }
     expect(Facter::Util::Ipa_utils.prepare_kinit(cmd='')).to eq(base)
   end
   it 'should assemple a command from a string' do
     expect(Facter).to receive(:value) { 'example.com' }
     expect(Facter::Util::Ipa_utils.prepare_kinit(cmd='this')).to eq(base + 'this')
   end
   it 'should unpack objects with to_s to string value' do
     expect(Facter).to receive(:value) { 'example.com' }
     expect(Facter::Util::Ipa_utils.prepare_kinit(cmd=['array','of','strings'])).to eq(base + 'array of strings')
   end
  end

  context 'for search_file' do
    it  'should reject non-regex options' do
      expect(Facter::Util::Ipa_utils.search_file('foo','/etc/openldap/ldap.conf')).to eq(nil)
    end
    it  'should search the expected file' do
      expect(File).to receive(:open).with('/something','r') { 'foo' }
      expect(Facter::Util::Ipa_utils.search_file(/f(oo)/,'/something')).to eq('oo')
    end
    it  'should throw errors' do
      expect(File).to receive(:open).with('/something','r') { throw Error }
      expect { Facter::Util::Ipa_utils.search_file(/f(oo)/,'/something') }.to raise_error(NameError, /.*/)
    end

  end

  context 'for search_sssd_conf' do
    it 'should call the expected helper function' do
      expect(Facter::Util::Ipa_utils).to receive(:search_file).with('foo','/etc/sssd/sssd.conf') { 'bar' }
      expect(Facter::Util::Ipa_utils.search_sssd_conf('foo')).to eq('bar')
    end

  end

  context 'for search_ldap.conf' do
    it 'should call the expected helper function' do
      expect(Facter::Util::Ipa_utils).to receive(:search_file).with('foo','/etc/openldap/ldap.conf') { 'bar' }
      expect(Facter::Util::Ipa_utils.search_ldap_conf('foo')).to eq('bar')
    end
  end

  context 'for search_krb5_conf' do
    it 'should reject non regex options' do
      expect(Facter::Util::Ipa_utils.search_krb5_conf('foo')).to eq(nil)
    end
    it 'should try to open /etc/krb5.conf' do
      expect(File).to receive(:open).with('/etc/krb5.conf','r')
      expect{ Facter::Util::Ipa_utils.search_krb5_conf(/foo/) }.to raise_error(NoMethodError, "undefined method `[]' for nil:NilClass")
    end
    it 'should try to read a default_realm' do
      expect(File).to receive(:open).with('/etc/krb5.conf','r') { "default_realm=foo\n[realms]" }
      expect(File).to receive(:open).with('/etc/krb5.conf','r') { '' }
      expect(Facter::Util::Ipa_utils.search_krb5_conf(/foo/)).to eq(nil)
    end
    it 'should try to return the target' do
      target= "[realms]\ndefault_realm=foo\nfoo={\nthing=bar\n"
      expect(File).to receive(:open).with('/etc/krb5.conf','r') { target }
      expect(File).to receive(:open).with('/etc/krb5.conf','r') { StringIO.new(target) }
      expect(Facter::Util::Ipa_utils.search_krb5_conf(/thing=(.*)/)).to eq('bar')
    end
  end

  context 'for ipa_api' do
      let(:fake_class) { Class.new }
      def prep_bot
        fake_IPA = double("IPA")
        stub_const("IPA", fake_class)
        expect(IPA).to receive(:new) { fake_IPA }
        expect(fake_IPA).to receive(:create_robot)
        fake_IPA
      end
      it "should throw an error when there is an error" do
        fake_IPA = prep_bot
        expect(fake_IPA).to receive(:post) { throw Error }
        expect{ Facter::Util::Ipa_utils.ipa_api }.to raise_error(NameError, /.*/)
      end
      it "should return result" do
        fake_IPA = prep_bot
        query_opts = 'something'
        expect(fake_IPA).to receive(:post).with('host_find',query_opts) { 'foo' }
        expect(Facter::Util::Ipa_utils.ipa_api(
          ipa_master='bar', fqdn='foo.example.com', 'host_find', query_opts)).to eq('foo')
      end
    end

end
