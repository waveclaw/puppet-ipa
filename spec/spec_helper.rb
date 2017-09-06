# First line of spec/spec_helper.rb
begin
require 'codeclimate-test-reporter'
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  CodeClimate::TestReporter::Formatter ]
SimpleCov.start do
  add_filter '/spec/'
  # Exclude bundled Gems in `/.vendor/`
  add_filter '/.vendor/'
end
rescue LoadError => e
 puts e.to_s
end

require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

default_facts = {
  puppetversion: Puppet.version,
  facterversion: Facter.version,
}

base_dir = File.dirname(File.expand_path(__FILE__))

default_facts_path = File.expand_path(File.join(base_dir, 'default_facts.yml'))
default_module_facts_path = File.expand_path(File.join(base_dir, 'default_module_facts.yml'))
hiera_path =  File.expand_path(File.join(base_dir, 'fixtures/hiera/hiera.yaml'))

if File.exist?(default_facts_path) && File.readable?(default_facts_path)
  default_facts.merge!(YAML.safe_load(File.read(default_facts_path)))
end

if File.exist?(default_module_facts_path) && File.readable?(default_module_facts_path)
  default_facts.merge!(YAML.safe_load(File.read(default_module_facts_path)))
end
if File.exist?(hiera_path) && File.readable?(hiera_path)
  hiera_config = hiera_path
else
  hiera_config = ''
end

RSpec.configure do |c|
  c.default_facts = default_facts
  c.hiera_config = hiera_config
  c.mock_with :rspec
  # straight from the example in the github repo readme.md for rspec-puppet
  c.default_trusted_facts = {
    'pp_uuid'                 => 'ED803750-E3C7-44F5-BB08-41A04433FE2E',
    '1.3.6.1.4.1.34380.1.2.1' => 'ssl-termination'
  }
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end
