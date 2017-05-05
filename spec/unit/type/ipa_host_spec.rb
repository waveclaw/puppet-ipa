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
#ipa_host { 'ipa.auto.local':
#  ensure           => 'present',
#  description      => 'Primary IPA server',
#  locality         => 'Timbuktu',
#  location         => 'datahall 1 rack 2',
#  managedby        => "ipa.$::domain",
# operating_system => "$::operatingsystem $::operatingsystemrelease",
#  platform         => $::architecture,
#}
described_class = Puppet::Type.type(:ipa_host)

describe described_class, 'type' do
  it_behaves_like 'has ensurable', described_class
  it_behaves_like 'has parameters', described_class, [ :ip_address ]
  it_behaves_like 'has properties',  described_class,
   [ :locality, :description, :operating_system, :platform ]
  it_behaves_like 'has a name', described_class
  it_behaves_like 'has array properties',  described_class,
   [ :managedby, :hostgroups ]
end
