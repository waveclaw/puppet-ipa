#!/usr/bin/ruby -S rspec
#
#  Test the rhsm_available_repos fact
#
#   Copyright 2016 WaveClaw <waveclaw@hotmail.com>
#
#   See LICENSE for licensing.
#

require 'spec_helper'
require 'facter/rhsm_available_repos'


describe Facter::Util::Rhsm_available_repos, :type => :puppet_function do
  context 'with just sssd.conf' do
    before :each do
      allow(File).to receive(:exist?).with(
      '/etc/sssd/sssd.conf' ) { true }
    end
    it "should return nothing when there is an error" do
      expect(Facter::Util::Resolution).to receive(:exec).with(
        '/usr/sbin/subscription-manager repos') { throw Error }
      expect(Facter::Util::Ipa_master.ipa_master).to eq(nil)
    end
  end
  context 'on an unsupported platform' do
    before :each do
      allow(File).to receive(:exist?).with(
      '/etc/sssd/sssd.conf' ) { false }
      allow(File).to receive(:exist?).with(
      '/etc/sssd/krb5.conf' ) { false }
      allow(File).to receive(:exist?).with(
      '/etc/openldap/ldap.conf' ) { false }
    end
    it "should return nothing" do
      expect(Facter::Util::Ipa_master.ipa_master).to eq(nil)
    end
  end
end
