#!/usr/bin/ruby
#
# Does this system have the expected IPA keberos files?
#
#   Copyright 2016 Jeremiah Powell <waveclaw@wavelcaw.net>
#
#   See LICENSE for licensing.
#
require 'facter'

# required module to run the rspec test
module Facter::Util::Ipa_keberos
  @doc=<<EOF
    The IPA registration fact 'is keberos 5 installed or not?'

    This does not mean that IPA is being used trough keberos just that it is
    possible to use a local system keytab to obtain tickets for a keberos
    session that may or may not be served by an IPA server.
EOF
  class << self
    def ipa_keberos
      begin
        if (File.exist? '/etc/krb5.conf' and
            File.exist? '/etc/krb5.keytab' and
            File.exist? '/usr/bin/kinit')
          true
        else
          false  # to be able to get this is why a simple confine isn't used
        end
      rescue Exception => e
        Facter.debug("#{e.backtrace[0]}: #{$!}.")
        nil
      end
    end
  end
end

Facter.add(:ipa_keberos) do
  setcode { Facter::Util::Ipa_keberos.ipa_keberos }
end
