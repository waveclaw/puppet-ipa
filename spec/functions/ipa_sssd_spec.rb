#!/usr/bin/ruby -S rspec
#
#  Test the ipa_sssd fact
#
#   Copyright 2016 WaveClaw <waveclaw@hotmail.com>
#
#   See LICENSE for licensing.
#

require 'spec_helper'
require 'facter/ipa_sssd'

describe 'ipa_sssd', :type => :puppet_function do
  context 'For IPA SSSD Facts' do
    before :each do
      Facter.clear
    end
    it "should return false when SSSD is not installed" do
      expect(File).to receive(:exist?).with('/usr/sbin/sssd') { false }
      expect(File).to_not receive(:exist?).with('/etc/sssd/sssd.conf')
      expect(Facter::Util::Ipa_utils).to_not receive(:search_sssd_conf)
      expect(Facter.value(:ipa_sssd)).to eq(nil)
    end
    it "should return false when SSSD is installed but not configured" do
      expect(File).to receive(:exist?).with('/usr/sbin/sssd') { true }
      expect(File).to receive(:exist?).with('/etc/sssd/sssd.conf') { false }
      expect(Facter::Util::Ipa_utils).to_not receive(:search_sssd_conf)
      expect(Facter.value(:ipa_sssd)).to eq(nil)
    end
    it "should return false when SSSD is missing the domain" do
      expect(File).to receive(:exist?).with('/usr/sbin/sssd') { true }
      expect(File).to receive(:exist?).with('/etc/sssd/sssd.conf') { true }
      expect(Facter::Util::Ipa_utils).to receive(:search_sssd_conf) { nil }
      expect(Facter.value(:ipa_sssd)).to eq(false)
    end
    it "should return true when SSSD is installed" do
      expect(File).to receive(:exist?).with('/usr/sbin/sssd') { true }
      expect(File).to receive(:exist?).with('/etc/sssd/sssd.conf') { true }
      expect(Facter::Util::Ipa_utils).to receive(:search_sssd_conf) { true }
      expect(Facter.value(:ipa_sssd)).to eq(true)
    end
    it "should return nil when there is an error" do
        expect(File).to receive(:exist?).with('/usr/sbin/sssd') { true }
        expect(File).to receive(:exist?).with('/etc/sssd/sssd.conf') { true }
        expect(Facter::Util::Ipa_utils).to receive(:search_sssd_conf) { throw Error }
        expect(Facter).to receive(:debug)
        expect(Facter).to receive(:debug)
        expect(Facter.value(:ipa_sssd)).to eq(nil)
    end
  end
end
