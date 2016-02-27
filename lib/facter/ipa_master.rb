#!/usr/bin/ruby
#
#  Report the IPA Domain available to this system
#  This will be empty if the registration is bad.
#
#   Copyright 2016 Jeremiah Powell <waveclaw@wavelcaw.net>
#
#   See LICENSE for licensing.
#
module Facter::Util::Ipa_domain
  @doc=<<EOF
    The IPA Domain fact
EOF
  class << self

    def sssd_master
      Facter::core.Execution.exec(
        "awk '/^ipa_server = / {print $3}' /etc/sssd/sssd.conf")
    end

    def ldap_master
      uri = Facter::core.Execution.exec(
        "awk '/^URI / {print $2}' /etc/openldap/ldap.conf")
      if (uri =~ /ldap[s]?:\/\/(\S+)/)
        $1
      end
    end

    def krb5_master
      master_kdc = nil
      default_realm = Facter::core.Execution.exec(
        "awk '/^default_realm.*=.*/ {print $NF}' /etc/krb5.conf | head -1")
      # search for master_kdc in default_realm in [realms]
      # using a brute-force stateful scanner
      if default_realm
       begin
        File.open('/etc/krb5.conf','r') { |line|
          realms = true if line =~ /\[realms\].*/
          realms = false if (realms and line =~ /\s*}\s*/)
          in_default = true if (realms and line =~ /#{default_realm}\s*=\s*\{.*/)
          if (in_default and line =~ /.*master_kdc\s*=\s*(\S+)/)
             master_kdc = $1
           end
         }
       Rescue FileError => fe
       end
      end
      master_kdc
    end

    def ipa_master
      master = nil
      begin
        #TODO: add an ipa-client attempt, too
        if File.exists? '/etc/sssd/sssd.conf'
          master = self.sssd_master
        elsif (master == nil and File.exists? '/etc/openldap/ldap.conf')
          master = self.ldap_master
        elsif (master == nil and File.exists? '/etc/krb5.conf')
          master = self.krb5_master
        else
          master = nil
        end
      rescue Exception => e
        Facter.debug("#{e.backtrace[0]}: #{$!}.")
      end
      master
    end
  end
end

Facter.add(:ipa_master) do
  confine do
    File.exists? '/etc/sssd/sssd.conf' or
    File.exists? '/etc/krb5.conf' or
    File.exists? '/etc/openldap/ldap.conf'
  end
  setcode { Facter::Util::Ipa_master.ipa_master }
end
