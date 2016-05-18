#!/usr/bin/ruby
#
#  Report the IPA Domain available to this system
#  This will be empty if the registration is bad.
#
#   Copyright 2016 Jeremiah Powell <waveclaw@waveclaw.net>
#
#   See LICENSE for licensing.
#
require 'facter'
require 'facter/util/ipa_utils'

module Facter::Util::Ipa_domain
  @doc=<<EOF
    The IPA Domain fact
EOF
  class << self
    # check the SSSD configuration for a domain
    # @return [string] the IPA domain
    # @api private
    def sssd
      Facter::Util::Ipa_utils.search_sssd_conf(/[^#]*ipa_domain\s*\=\s*(.+)/)
    end

    # check OpenLDAP for a domain setting
    # @return [string] the LDAP BASE setting in DNS format
    # @api private
    def ldap
        domain = Facter::Utils::Ipa_utils.search_ldap_conf(/^[^#]?BASE\s+(\S+)/)
      if domain.nil?
        nil
      else
        /\.?(\S+)/.match(domain.split(/[,]?dc\=/).join('.'))[1]
      end
    end

    # Read the keberos configuration for a default realm
    # @return [string] the default KDC realm in DNS format
    # @api private
    def krb5
          Facter::Util::Ipa_utils.search_krb5_conf(
            /^[^#]?\s*default_domain\s*\=\s*(\S+)/)
    end

    # Get the domain from ipa-client or ipa tools
    # @return [string] the domain name
    # @api private
    def ipatools
      command = Facter::Utils::Ipa_utils.prepare_kinit(
      '/usr/bin/ipa host-show $(hostname).$(domainname) ' +
      "|awk -F@ '/Principal name:/ {print $NF}'")
      Facter::Util:Resolution.exec(command)
    end

    # what is the IPA domainname
    # @return [string] the domain
    def ipa_domain
      value = nil
      begin
        if File.exist? '/etc/sssd/sssd.conf'
          value = self.sssd
        end
        if (value.nil? and File.exist? '/etc/openldap/ldap.conf')
          value = self.ldap
        end
        if (value.nil? and File.exist? '/etc/krb5.conf')
          value = self.krb5
        end
        if (value.nil? and File.exist '/usr/sbin/ipa')
          value = self.ipatools
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
    File.exist? '/etc/sssd/sssd.conf' or
    File.exist? '/etc/krb5.conf' or
    File.exist? '/etc/openldap/ldap.conf'
  end
  setcode { Facter::Util::Ipa_domain.ipa_domain }
end
