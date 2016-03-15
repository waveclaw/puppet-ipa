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
      # krb5.conf is NOT an ini-format file :-{
      master = nil
      default_realm = nil
      # I know, I'll user regular expiressions! (https://xkcd.com/208/)
      default_realm = /\=\s*(\S+)/.match(
          File.open('/etc/krb5.conf','r') { |f|
            f.each_line.detect {
             |line| /default_realm\s*\=/.match(line)
            }
          }
        )[1]
      if default_realm
        # use a brute-force stateful scanner to search for (master_)kdc in
        # default_realm blocks in [realms] sections
        in_realms = false
        realm_found = false
        File.open('/etc/krb5.conf','r').each_line { |line|
          if (/^[^#]?\s*\[realms\]/ =~ line)
            in_realms = true
            next
          end
          if (in_realms == true and
            /^[^#]?\s*(#{default_realm})\s*\=\s*\{/i =~ line)
            realm_found = true
            next
          end
            if (in_realms == true and realm_found == true and
              /^[^#]?\s*(?:master_)?kdc\s*\=\s*(\S+):/ =~ line)
                master = $1
          end
          #if (in_realms == true and /^[^#]?\s*\}/ =~ line)
          #  realm_found = false
          #  next
          #end
        }
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
