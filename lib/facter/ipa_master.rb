#!/usr/bin/ruby
#
#  Report the IPA Domain available to this system
#  This will be empty if the registration is bad.
#
#   Copyright 2016 Jeremiah Powell <waveclaw@wavelcaw.net>
#
#   See LICENSE for licensing.
#
module Facter::Util::Ipa_master
  @doc=<<EOF
    The IPA Master server.  This is the LDAP Primary.
EOF
  class << self

    def sssd_master
      master = nil
      ssd_conf = File.open('/etc/sssd/sssd.conf','r') # for instrumentation
      ssd_conf.each_line {|line|
        if (line =~ /ipa_server\s*=\s*(.+)/)
          master = $1.chomp
        end
      }
      master
    end

    def ldap_master
      master = nil
      ldap_conf = File.open('/etc/openldap/ldap.conf','r') # for instrumentation
      ldap_conf.each_line { |line|
        if (line =~ /^URI\s+(\S+)/)
          master = $1.split(':')[1].split('/')[2]  # not my finest hack
        end
      }
      master
    end

    def krb5_master
      master = nil
      default_realm = Facter::Util::Resolution.exec(
        "awk '/^default_realm.*=.*/ {print $NF}' /etc/krb5.conf | head -1")
      # search for master_kdc in default_realm in [realms]
      # using a brute-force stateful scanner
      if default_realm
       begin # file error very likely due to close bugs
        File.open('/etc/krb5.conf','r') { |line|
          realms = true if line =~ /\[realms\].*/
          realms = false if (realms and line =~ /\s*}\s*/)
          in_default = true if (realms and line =~ /#{default_realm}\s*=\s*\{.*/)
          if (in_default and line =~ /.*master_kdc\s*=\s*(\S+)/)
             master = $1
           end
         }
       Rescue FileError => fe
       end
      end
      master
    end

    def ipa_master
      master = nil
      begin
        #TODO: add an ipa-client attempt, too
        if File.exist? '/etc/sssd/sssd.conf'
          master = self.sssd_master
        elsif (master == nil and File.exist? '/etc/openldap/ldap.conf')
          master = self.ldap_master
        elsif (master == nil and File.exist? '/etc/krb5.conf')
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
    File.exist? '/etc/sssd/sssd.conf' or
    File.exist? '/etc/krb5.conf' or
    File.exist? '/etc/openldap/ldap.conf'
  end
  setcode { Facter::Util::Ipa_master.ipa_master }
end
