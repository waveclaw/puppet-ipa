#!/usr/bin/ruby -S rspec
#
#  Test the type interface of the ipa_group type.
#
#   Copyright 2016 JD Powell <waveclaw@hotmail.com>
#
#   See LICENSE for licensing.
#
require 'spec_helper'
require 'type_spec_tests'

# Example:
#  ipa_sudocmdgroup { 'puppet commands':
#      ensure      => 'present',
#      description => 'Stuff for puppet',
#      members     => ['/etc/init.d/puppet', '/usr/bin/pupet'],
#   }

described_class = Puppet::Type.type(:ipa_sudocmdgroup)

describe described_class, 'type' do
  it_behaves_like 'has ensurable', described_class
  it_behaves_like 'has properties',  described_class,
   [ :description ]
  it_behaves_like 'has a name', described_class
  it_behaves_like 'has array properties',  described_class,
   [ :members ]
end
