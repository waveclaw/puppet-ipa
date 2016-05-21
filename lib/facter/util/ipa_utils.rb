#!/usr/bin/ruby
#
#  Basic utility functions for ipa facts.
#
#   Copyright 2016 Jeremiah Powell <waveclaw@wavelcaw.net>
#
#   See LICENSE for licensing.
#
require 'facter'
require 'uri'
require 'puppet/util/ipajson'

module Facter::Util::Ipa_utils
  @doc=<<EOF
    Miscellanious IPA Utilities
EOF
  class <<self
    # return a command string containing kinit intialized
    # @param [cmd] the command to run with kinit
    # @return [string] prepend a kinit line
    def prepare_kinit(cmd='/bin/true')
      fqdn = Facter.value(:fqdn)
      # no appologies about the following
      # see https://kb.iu.edu/d/aumh
      [
          '/usr/bin/kinit $(klist /etc/krb5.keytab | awk',
          "'/#{fqdn}/ {print $2}'",
          ') -k -t /etc/krb5.keytab',
          '&&',
          cmd
        ].join(' ')
    end

    # search a file for an expression
    # @param [expression] the regular expression to use
    # @param [file] name of the file to check
    # @return [string] some value or nil
    # @api private
    def search_file(expression = //, file='/etc/motd')
      value = nil
      return value if !(expression.is_a? Regexp)
      File.open(file,'r').each_line {|line|
        if (line =~ expression)
          value = $1.chomp
        end
      }
      value
    end

    # search the SSSD config file and return a value found there
    # @param [expression] the regular expression to use
    # @return [string] the value found
    def search_sssd_conf(expression = /.*hostname.*/)
        search_file(expression, file='/etc/sssd/sssd.conf')
    end

    # search the OpenLDAP config file and return a value found there
    # @param [expression] the regular expression to use
    # @return [string] the value found
    def search_ldap_conf(expression = /.*hostname.*/)
      search_file(expression, file='/etc/openldap/ldap.conf')
    end

    # crawl the keberos configuration for the default realm's master
    # @return [string] the keberos master as the ipa server
    # @api private
    def search_krb5_conf(expression = /.*something.*/)
      # krb5.conf is NOT an ini-format file :-{
      value = nil
      return value if !(expression.is_a? Regexp)
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
              line =~ expression)
                value = $1.chomp
          end
          #if (in_realms == true and /^[^#]?\s*\}/ =~ line)
          #  realm_found = false
          #  next
          #end
        }
      end
      value
    end

    # call the JSON API directly
    # @param [ipa_master] which IPA server to ask
    # @param [fqdn] The name of the principal (hostname) to check
    # @return [boolean] did I return a valid registration?
    # @api private
    def ipa_api(
      ipa_master='localhost',
      fqdn='ipa.auto.local',
      query='', query_opts='')
      # uses the directy json API.  This does require the gssapi gem
      # http://adam.younglogic.com/2010/07/talking-to-freeipa-json-web-api-via-curl/
      # and login credentials if required
      registration = nil
      server = IPA.new(ipa_master)
      server.create_robot
      server.post(query, query_opts)
    end
  end
end
