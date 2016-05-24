#!/usr/bin/ruby -S rspec
#
#  Test the ipa_ldap fact
#
#   Copyright 2016 WaveClaw <waveclaw@hotmail.com>
#
#   See LICENSE for licensing.
#

require 'spec_helper'
require 'facter/ipa_ldap'

describe Facter::Util::Ipa_ldap, :type => :puppet_function do
  context 'various cases' do
    before :each do
      Facter.clear
    end
    it "should return true when openldap is installed" do
      expect(File).to receive(:exist?).with('/etc/openldap/ldap.conf') { true }
      expect(File).to receive(:exist?).with('/usr/bin/ldapsearch') { true }
      expect(Facter::Util::Ipa_ldap.ipa_ldap).to eq(true)
    end
    it "should return false if only the config file is present" do
      expect(File).to receive(:exist?).with('/etc/openldap/ldap.conf') { true }
      expect(File).to receive(:exist?).with('/usr/bin/ldapsearch') { false }
      expect(Facter::Util::Ipa_ldap.ipa_ldap).to eq(false)
    end
    it "should return false when openldap is configured but not installed" do
      expect(File).to receive(:exist?).with('/etc/openldap/ldap.conf') { false }
      expect(File).to_not receive(:exist?).with('/usr/bin/ldapsearch')
      expect(Facter::Util::Ipa_ldap.ipa_ldap).to eq(false)
    end
    it "should return nil when there is an error" do
        expect(File).to receive(:exist?).with('/etc/openldap/ldap.conf') { throw Error }
        expect(Facter.value(:ipa_ldap)).to eq(nil)
    end
  end
end
