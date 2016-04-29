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
      ssd_conf = File.open('/etc/sssd/sssd.conf','r') # for instrumentation
      ssd_conf.each_line {|line|
        if (line =~ /[^#]*ipa_domain\s*\=\s*(.+)/)
          domain = $1.chomp
        end
      }
      domain
    end

    def ldap_domain
      domain = nil
      ldap_conf =  File.open('/etc/openldap/ldap.conf','r')
      ldap_conf.each_line { |line|
         if (line =~ /^[^#]?BASE\s+(\S+)/)
           domain = $1
         end
        }
      if domain
        /\.?(\S+)/.match(domain.split(/[,]?dc\=/).join('.'))[1]
      end
    end

    def krb5_domain
      # krb5.conf is NOT an ini-format file :-{
      domain = nil
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
              /^[^#]?\s*default_domain\s*\=\s*(\S+)/ =~ line)
                domain = $1
          end
          #if (in_realms == true and /^[^#]?\s*\}/ =~ line)
          #  realm_found = false
          #  next
          #end
        }
      end
      domain
    end

    def ipa_domain
      value = nil
              #TODO: add an ipa-client attempt, too
      begin
        if File.exist? '/etc/sssd/sssd.conf'
          value = self.ssd_domain
        elsif (value == nil and File.exist? '/etc/openldap/ldap.conf')
          value = self.ldap_domain
        elsif (value == nil and File.exist? '/etc/krb5.conf')
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
  confine do
    File.exiss? '/etc/sssd/sssd.conf' or
    File.exist? '/etc/krb5.conf' or
    File.exist? '/etc/openldap/ldap.conf'
  end
  setcode { Facter::Util::Ipa_domain.ipa_domain }
end
