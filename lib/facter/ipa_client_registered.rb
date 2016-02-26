#!/usr/bin/ruby
#
#  Report the IPA Domain available to this system
#  This will be empty if the registration is bad.
#
#   Copyright 2016 Pat Riehecky <riehecky@fnal.gov>
#
#   See LICENSE for licensing.
#
#import Facter::Util::IPA_domain
#import Facter::Utils::IPA_master

module Facter::Util::Ipa_domain
  @doc=<<EOF
    The IPA Domain fact
EOF
  class << self
    def ipa_client_registered
      registation = nil
      #
      # this will either be nil or a UTC String
      #
      if Facter.respond_to? :ipa_master and Facter.respond_to? :ipa_domain
       ipa_master = Facter.value(:ipa_master)
       ipa_domain = Facter.value(:ipa_domain)
     end
     host = Facter.value(:host)
     domain = Facter.value(:domain)
      if host and domain
        fqdn = [host.domain].join('.')
      else
        fqdn = host
      end
      if (File.exists? '/etc/krb5.keytab' and
         File.exists? '/usr/bin/k5start' and
         File.exists? '/usr/bin/ldapsearch' and
         fqdn != nil)
         begin
           # evil little shell one-liner
           registation = Facter::core::Execution.exec("/usr/bin/k5start \
 -u host/#{fqdn} -f /etc/krb5.keytab -- /usr/bin/ldapsearch -Y GSSAPI \
 -H ldap://#{ipa_master} -b #{ipa_domain} fqdn=#{fqdn} |\
 awk '/^krbLastPwdChange/ { print $2}'")
         rescue Exception => e
           Facter.debug("#{e.backtrace[0]}: #{$!}.")
         end
       end
       registation == nil
    end

  end
end


Facter.add(:ipa_client_registered) do
  confine do
    File.exists? '/etc/krb5.keytab' and
    File.exists? '/usr/bin/k5start' and
    File.exists? '/usr/bin/ldapsearch' 
  end
  setcode { Facter::Util::Ipa_client_registered.ipa_client_registered }
end
