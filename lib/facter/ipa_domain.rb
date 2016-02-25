#!/usr/bin/ruby
#
#  Report the IPA Domain available to this system
#  This will be empty if the registration is bad.
#
#   Copyright 2016 Jeremiah Powell <waveclaw@waveclaw.net>
#
#   See LICENSE for licensing.
#
module Facter::Util::Ipa_domain
  @doc=<<EOF
    The IPA Domain fact
EOF
  class << self
    def ssd_domain
      domain = nil
      domain = Facter::core.Execution.exec(
          "awk '/^ipa_domain.*=.*/ {print $NF}' /etc/sssd/sssd.conf")
      if domain
        ( ['dc='] << domain.split('.') ).flatten!.join('dc=')
      end
      domain
    end
    def ldap_domain
      domain = nil
      domain = Facter::core.Execution.exec(
          "awk '/^BASE / {print $2}' /etc/openldap/ldap.conf")
    end
    def krb5_domain
      domain = nil
      default_realm = Facter::core.Execution.exec(
        "awk '/^default_realm = / {print $3}' /etc/krb5.conf | head -1")
      # search for default_domain in default_realm in [realms]
      # using a brute-force stateful scanner
      if default_realm
        begin
          File.open('/etc/krb5.conf','r') { |line|
            realms = true if line =~ /\[realms\].*/
            realms = false if (realms and line =~ /\s*}\s*/)
            in_default = true if (realms and line =~ /#{default_realm}\s*=\s*{.*/)
            if (in_default and line =~ /.*default_domain\s*=\s*(\S+)/)
                 domain = $1
            end
          }
        rescue FileError => fe
        end # file open
        if domain
          ( ['dc='] << domain.split('.') ).flatten!.join('dc=')
        end
        domain
      end
    end # which conifg

    def ipa_domain
      value = nil
              #TODO: add an ipa-client attempt, too
      begin
        if File.exists? '/etc/sssd/sssd.conf'
          value = self.ssd_domain
        elsif (value == nil and File.exists? '/etc/openldap/ldap.conf')
          value = self.ldap_domain
        elsif (value == nil and File.exists? '/etc/krb5.conf')
          value = self.krb5_domain
        else
          value = nil
        end
      rescue Exception => e
        Facter.debug("#{e.backtrace[0]}: #{$!}.")
      end
      value
    end
  end
end

Facter.add(:ipa_domain) do
    setcode { Facter::Util::Ipa_domain.ipa_domain }
end
