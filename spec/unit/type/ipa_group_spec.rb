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
# ipa_group { 'editors':
#  ensure      => 'present',
#  description => 'Limited admins who can edit other users',
#  gid         => '800200002',
#  nonposix    => 'false',
# }

described_class = Puppet::Type.type(:ipa_group)

describe described_class, 'type' do
  it_behaves_like 'has ensurable', described_class
  it_behaves_like 'has properties',  described_class,
   [ :gid, :description, :nonposix ]
  it_behaves_like 'has a name', described_class
  it_behaves_like 'has boolean properties',  described_class,
   [ :nonposix ]
end
