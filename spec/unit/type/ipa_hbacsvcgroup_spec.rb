#!/usr/bin/ruby -S rspec
#
#  Test the type interface of the ipa_hbacsvcgroup 'HABC Service Group' type.
#
#   Copyright 2016 JD Powell <waveclaw@hotmail.com>
#
#   See LICENSE for licensing.
#
require 'spec_helper'
require 'type_spec_tests'

# Example:
#ipa_hbacsvcgroup { 'remote unix access':
#  ensure      => 'present',
#  description => 'ssh / sudo / ftp',
#  members     => ['sshd', 'sudo'],
#}

described_class = Puppet::Type.type(:ipa_hbacsvcgroup)

describe described_class, 'type' do
  it_behaves_like 'has ensurable', described_class
  it_behaves_like 'has properties',  described_class,
   [ :description, :members ]
   it_behaves_like 'has array properties',  described_class,
    [ :members ]   
  it_behaves_like 'has a name', described_class
end
