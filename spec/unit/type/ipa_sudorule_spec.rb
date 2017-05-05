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
#ipa_sudorule { 'puppet administration - client':
#  ensure              => 'present',
#  allow_commandgroups => ['puppet commands'],
#  anycommand          => 'false',
#  anyhost             => 'true',
#  anyrunasgroup       => 'false',
#  anyrunasuser        => 'false',
#  anyuser             => 'false',
#  options             => ['!authenicate'],
#  usergroups          => ['puppet_admins'],
#}

described_class = Puppet::Type.type(:ipa_sudorule)

describe described_class, 'type' do
  it_behaves_like 'has ensurable', described_class
  it_behaves_like 'has properties',  described_class,
   [ :description ]
  it_behaves_like 'has a name', described_class
  it_behaves_like 'has boolean properties',  described_class,
   [ :anycommand, :anyhost, :anyrunasgroup, :anyrunasuser, :anyuser ]
  it_behaves_like 'has array properties',  described_class,
   [ :allow_commandgroups, :options, :usergroups ]
end
