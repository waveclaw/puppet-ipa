#!/usr/bin/ruby -S rspec
#
#  Test the type interface of theipa_group type.
#
#   Copyright 2016 JD Powell <waveclaw@hotmail.com>
#
#   See LICENSE for licensing.
#
require 'spec_helper'
require 'type_spec_tests'

# Example:
# ipa_hbacrule { 'puppet admins - client':
#   ensure        => 'present',
#   anyhost       => 'true',
#   anyservice    => 'false',
#   anyuser       => 'false',
#   servicegroups => ['remote unix access'],
#   usergroups    => ['puppet_admins'],
# }

described_class = Puppet::Type.type(:ipa_group)

describe described_class, 'type' do
  it_behaves_like 'has ensurable', described_class
  it_behaves_like 'has properties',  described_class,
   [ :hosts, :hostgroups, :services, :servicegorups, :users, :usergroups ]
  it_behaves_like 'has a name', described_class
  it_behaves_like 'has boolean properties',  described_class,
   [ :anyhost, :anyuser, :anyservice ]
end
