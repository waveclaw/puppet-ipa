#!/usr/bin/ruby
#
# Does this appear to be an openldap client?
#
#   Copyright 2016 Jeremiah Powell <waveclaw@wavelcaw.net>
#
#   See LICENSE for licensing.
#
require 'facter'

# required module to run the rspec test
module Facter::Util::Ipa_ldap
  @doc=<<EOF
    The IPA registration fact 'is ldap installed or not?'

    This does not mean that IPA is being used through ldap just that it is
    possible to search in some LDAP directory which just might be an IPA server.
EOF
  class << self
    def ipa_ldap
      begin
       if (File.exist?('/etc/openldap/ldap.conf') and
        File.exist?('/usr/bin/ldapsearch'))
        true
       else
        false # to be able to get this is why a simple confine isn't used
       end
      rescue Exception => e
        Facter.debug("#{e.backtrace[0]}: #{$!}.")
        nil
      end
    end
  end
end

Facter.add(:ipa_ldap) do
  setcode { Facter::Util::Ipa_ldap.ipa_ldap }
end
