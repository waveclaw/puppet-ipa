#!/usr/bin/ruby -S rspec
#
#  Test the ipa_keberos fact
#
#   Copyright 2016 WaveClaw <waveclaw@hotmail.com>
#
#   See LICENSE for licensing.
#

require 'spec_helper'
require 'facter/ipa_keberos'

describe Facter::Util::Ipa_keberos, :type => :puppet_function do
  context 'various cases' do
    before :each do
      Facter.clear
    end
    it "should return true when openldap is installed" do
      expect(File).to receive(:exist?).with('/etc/krb5.conf') { true }
      expect(File).to receive(:exist?).with('/etc/krb5.keytab') { true }
      expect(File).to receive(:exist?).with('/usr/bin/kinit') { true }
      expect(Facter::Util::Ipa_keberos.ipa_keberos).to eq(true)
    end
    it "should return false if only the config file is present" do
      expect(File).to receive(:exist?).with('/etc/krb5.conf') { true }
      expect(File).to receive(:exist?).with('/etc/krb5.keytab') { false }
      expect(File).to_not receive(:exist?).with('/usr/bin/kinit')
      expect(Facter::Util::Ipa_keberos.ipa_keberos).to eq(false)
    end
    it "should return false when openldap is configured but not installed" do
      expect(File).to receive(:exist?).with('/etc/krb5.conf') { false }
      expect(File).to_not receive(:exist?).with('/etc/krb5.keytab')
      expect(Facter::Util::Ipa_keberos.ipa_keberos).to eq(false)
    end
    it "should return nil when there is an error" do
      expect(File).to receive(:exist?).with('/etc/krb5.conf') { throw Error }
      expect(Facter.value(:ipa_keberos)).to eq(nil)
    end
  end
end
