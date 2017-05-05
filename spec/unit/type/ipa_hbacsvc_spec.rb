#!/usr/bin/ruby -S rspec
#
#  Test the type interface of the ipa_hdbacvc 'HBAC Service' type.
#
#   Copyright 2016 JD Powell <waveclaw@hotmail.com>
#
#   See LICENSE for licensing.
#
require 'spec_helper'
require 'type_spec_tests'

# Example:
#ipa_hbacsvc { 'sudo':
#  ensure      => 'present',
#  description => 'sudo',
#}

described_class = Puppet::Type.type(:ipa_hbacsvc)

describe described_class, 'type' do
  it_behaves_like 'has ensurable', described_class
  it_behaves_like 'has properties',  described_class,
   [ :description ]
  it_behaves_like 'has a name', described_class
end
