#!/usr/bin/ruby
#
#  Report the IPA Domain available to this system
#  This will be empty if the registration is bad.
#
#   Copyright 2016 Jeremiah Powell <waveclaw@wavelcaw.net>
#
#   See LICENSE for licensing.
#
require 'facter'
require 'facter/utils/ipa_utils'

module Facter::Util::Ipa_master
  @doc=<<EOF
    The IPA Master server.  This is the LDAP Primary.
EOF
  class << self
    # SSSD configuration should contain the ipa server name
    # @return [string] the name of the ipa server used by SSSD
    # @api private
    def sssd
      Facter::Util::Ipa_utils.search_sssd_conf(/ipa_server\s*=\s*(.+)/)
    end

    # guess the server based on the ldap URI
    # @return [string] the FQDN of the URI entry
    # @api private
    def ldap
      master = Facter::Utils::Ipa_utils.search_ldap_conf(/^URI\s+(\S+)/)
      if master.nil?
        nil
      else
       master.split(':')[1].split('/')[2]
     end
    end

    # crawl the keberos configuration for the default realm's master
    # @return [string] the keberos master as the ipa server
    # @api private
    def krb5
      Facter::Util::Ipa_utils.search_krb5_conf(
        /^[^#]?\s*(?:master_)?kdc\s*\=\s*(\S+):/)
    end

    # Get the domain from ipa-client or ipa tools
    # @return [string] the domain name
    # @api private
    def ipatools
      command = Facter::Utils::Ipa_utils.prepare_kinit(
        "/usr/bin/ipa server-find --all | awk -F: '/Server name/ {print $NF}'")
      found = Facter::Util:Resolution.exec(command)
      if found.is_a? Array
        found[0]
      else
        found
      end
    end

    def ipa_master
      master = nil
      begin
        if File.exist? '/etc/sssd/sssd.conf'
          master = self.sssd
        end
        if (master.nil? and File.exist? '/etc/openldap/ldap.conf')
          master = self.ldap
        end
        if (master.nil? and File.exist? '/etc/krb5.conf')
          master = self.krb5
        end
        if (master.nil? and File.exist? '/usr/bin/ipa')
          master = self.ipatools
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
