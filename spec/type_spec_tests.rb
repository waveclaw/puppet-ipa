#!/usr/bin/ruby -S rspec
#
#  Test the type interface of a native type.
#
#   Copyright 2016 JD Powell <waveclaw@hotmail.com>
#
#   See LICENSE for licensing.

shared_examples_for 'has ensurable' do |described_class|
  it "should be ensurable" do
    expect(described_class.attrtype(:ensure)).to eq(:property)
  end
end

shared_examples_for 'has parameters' do |described_class, params|
  params.each { |param|
      context "for #{param}" do
        it "should be of type parameter" do
          expect(described_class.attrtype(param)).to eq(:param)
        end
        it "should be of class Property" do
          expect(described_class.attrclass(param).ancestors).
            to include(Puppet::Parameter)
        end
        it "should have documentation" do
          expect(described_class.attrclass(param).doc.strip).
            not_to be_empty
        end
      end
  }
end


shared_examples_for 'has properties' do |described_class, props|
  props.each { |prop|
      context "for #{prop}" do
        it "should be of type property" do
          expect(described_class.attrtype(prop)).to eq(:property)
        end
        it "should be of class Property" do
          expect(described_class.attrclass(prop).ancestors).
            to include(Puppet::Property)
        end
        it "should have documentation" do
          expect(described_class.attrclass(prop).doc.strip).
            not_to be_empty
        end
      end
  }
end

shared_examples_for 'has a name' do |described_class|
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
end

shared_examples_for 'has boolean properties' do |described_class, props|
  props.each { |boolean_property|
    context "#{boolean_property}" do
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

shared_examples_for 'has array properties' do |described_class, props|
  props.each { |prop|
      context "for #{prop}" do
        it "should be of type property" do
          expect(described_class.attrtype(prop)).to eq(:property)
        end
        it "should be of class Property" do
          expect(described_class.attrclass(prop).ancestors).
            to include(Puppet::Property)
        end
        it "should have documentation" do
          expect(described_class.attrclass(prop).doc.strip).
            not_to be_empty
        end
        it "should accept and return an array" do
          testvalue = ['a', 'b', 'c']
          @resource = described_class.new(
           :name => 'foo', prop => testvalue)
          expect(@resource[prop]).to eq(testvalue)
        end
      end
  }
end
