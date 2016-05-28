#!/usr/bin/ruby -S rspec
#
#  Test the type interface of theipa_group type.
#
#   Copyright 2016 JD Powell <waveclaw@hotmail.com>
#
#   See LICENSE for licensing.
#
require 'spec_helper'

# Example:
# ipa_group { 'editors':
#  ensure      => 'present',
#  description => 'Limited admins who can edit other users',
#  gid         => '800200002',
#  nonposix    => 'false',
# }

described_class = Puppet::Type.type(:ipa_group)

describe described_class, 'type' do

  it "should be ensurable" do
    expect(described_class.attrtype(:ensure)).to eq(:property)
  end

  [ :gid, :description, :nonposix ].each { |params|
      context "for #{params}" do
        it "should be of type property" do
          expect(described_class.attrtype(params)).to eq(:property)
        end
        it "should be of class Property" do
          expect(described_class.attrclass(params).ancestors).
            to include(Puppet::Property)
        end
        it "should have documentation" do
          expect(described_class.attrclass(params).doc.strip).
            not_to be_empty
        end
      end
      }


  context "for name" do
    namevar = :name
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
      testvalue =  '/foo/bar/y.conf'
      @resource = described_class.new(namevar => testvalue)
      expect(@resource[namevar]).to eq(testvalue)
      expect(@resource[:name]).to eq(testvalue)
    end
  end

  [ :nonposix ].each { |boolean_property|
    context "for #{boolean_property}" do
      it "should be a property" do
        expect(described_class.attrtype(boolean_property)).to eq(:property)
        expect(described_class.attrclass(boolean_property).ancestors).
          to include(Puppet::Property)
      end
# this test is only for types dependant on puppet-boolean
#      it "should have boolean class" do
#        expect(described_class.attrclass(boolean_property).ancestors).
#          to include(Puppet::Property::Boolean)
#      end
      it "should have documentation" do
        expect(described_class.attrclass(boolean_property).doc.strip).
          not_to be_empty
      end
      it 'should accept boolean values' do
        @resource = described_class.new(
         :name => '/foo/x.conf', boolean_property => true)
        expect(@resource[boolean_property]).to eq(:true)
        @resource = described_class.new(
         :name => '/foo/x.conf', boolean_property => false)
        expect(@resource[boolean_property]).to eq(:false)
      end
      it 'should reject non-boolean values' do
        expect{ described_class.new(
         :name => '/foo/x.conf', boolean_property => 'bad date')}.to raise_error(
          Puppet::ResourceError, /.*/)
      end
    end
  }
end
