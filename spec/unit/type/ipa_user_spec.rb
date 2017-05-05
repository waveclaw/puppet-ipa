#!/usr/bin/ruby -S rspec
#
#Test the type interface of the ipa_group type.
#
# Copyright 2016 JD Powell <waveclaw@hotmail.com>
#
# See LICENSE for licensing.
#
require 'spec_helper'
require 'type_spec_tests'

# Example:
#ipa_user { 'john':
#ensure=> 'present',
#first_name=> 'John',
#last_name => 'Wibble',
#full_name => "$first_name $last_name"
#uid => '800200001',
#gecos => "usr_$name_$uid",
#home_directory=> "/home/$name",
#login_shell => '/bin/bash',
#ssh_public_keys => 'ssh-rsa AAAAB3NzaC1yc2EA ... e5JmsDLkkA5e+XOzWzi01IVTkYXNdpTv john@auto.local',
#telephone_numbers => ['12345678'],
#usergroups=> ['admins', 'puppet_admins'],
#}

described_class = Puppet::Type.type(:ipa_user)

describe described_class, 'type' do
it_behaves_like 'has ensurable', described_class
it_behaves_like 'has properties',described_class,
 [ :title,:first_name,:last_name,:full_name, :display_name, :initials,
   :gecos, :uid, :gid, :login_shell, :home_directory, :mail, :street_address,
   :city, :state,:zip, :org_unit, :manager, :car_license ]
it_behaves_like 'has array properties',described_class,
 [ :ssh_public_keys, :usergroups, :telephone_numbers, :pager_numbers,
 :mobile_numbers, :fax_numbers ]
# it_behaves_like 'has a name', described_class
  context "for user" do
    namevar = :user
    it "should be a parameter" do
      expect(described_class.attrtype(namevar)).to eq(:param)
    end
    it "should have documentation" do
      expect(described_class.attrclass(namevar).doc.strip).
        not_to be_empty
    end    
    it "should be the namevar" do
      expect(described_class.key_attributes).to eq([namevar])
    end
    it "should return a name equal to this parameter" do
      testvalue =  'foo'
      @resource = described_class.new(namevar => testvalue)
      expect(@resource[namevar]).to eq(testvalue)
      expect(@resource[:name]).to eq(testvalue)
    end
  end
end
