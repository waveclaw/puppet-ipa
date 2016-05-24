#!/usr/bin/ruby
#
# Does System Security Services Daemon appear to be available?
#
#   Copyright 2016 Jeremiah Powell <waveclaw@wavelcaw.net>
#
#   See LICENSE for licensing.
#
require 'facter'
require 'facter/util/ipa_utils'

Facter.add(:ipa_sssd) do
  @doc=<<EOF
     Is there an ipa_domain defined for SSSD?

EOF
  confine { File.exist?('/usr/sbin/sssd') }
  confine { File.exist?('/etc/sssd/sssd.conf') }
  setcode {
    begin
     value = Facter::Util::Ipa_utils.search_sssd_conf(/[^#]*ipa_domain\s*\=\s*(.+)/)
     !(value.nil?)
   rescue Exception => e
     Facter.debug("#{e.backtrace[0]}: #{$!}.")
     nil
   end
   }
end
