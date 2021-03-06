#!/usr/bin/ruby
#
#  Is this system registered?
#
#   Copyright 2016 Pat Riehecky <riehecky@fnal.gov>
#
#   See LICENSE for licensing.
#
require 'facter'
require 'facter/util/ipa_utils'

module Facter::Util::Ipa_client_registered
  @doc=<<EOF
    The IPA registration fact 'is this client registered or not?'
EOF
  class << self
    # check for a host record with local IPA tools and the local keytab
    # @param [fqdn] The name of the principal (hostname) to check
    # @return [boolean] did I get a record from IPA?
    # @api private
    def ipa_client(fqdn='ipa.auto.local')
      # there has to be some kind of a proper ipa client library
      # for ruby
      record = nil
      command = Facter::Util::Ipa_utils.prepare_kinit(
        "/usr/bin/ipa host-show $(hostname).$(domainname)")
      record = Facter::Util::Resolution.exec(command)
      !record.nil?
    end

    # call the JSON API directly and ask for my registration
    # @param [ipa_master] which IPA server to ask
    # @param [fqdn] The name of the principal (hostname) to check
    # @return [boolean] did I return a valid registration?
    # @api private
    def ipa_query(ipa_master='localhost', fqdn='ipa.auto.local')
      host = Facter::Util::Ipa_utils.ipa_api(
        ipa_master, fqdn, 'host_find', [[fqdn],{}])
      if host.nil?
        nil
      elsif fqdn == host['result']['result'][0]['fqdn'][0]
        true
      else
        false
      end
    end

    # test for a password change date with basic keberos and raw LDAP tools
    # @param [ipa_master] which master to ask
    # @param [ipa_domain] the domain for k5start
    # @param [fqdn] name of the principal (host) for the query
    # @return [boolean] was a password change date recovered?
    # @api private
    def k5start_registration(
     ipa_master='localhost',
     ipa_domain='EXAMPLE.COM',
     fqdn='ipa.auto.local')
      lastpasschange = nil
      # evil little shell one-liner
      lastpasschange = Facter::Util::Resolution.exec(
       ["/usr/bin/k5start -u host/#{fqdn}",
        '-f /etc/krb5.keytab -- /usr/bin/ldapsearch -Y GSSAPI',
        "-H ldap://#{ipa_master} -b #{ipa_domain} fqdn=#{fqdn}",
        "| awk '/^krbLastPwdChange/ { print $2}'"].join(' '))
       !lastpasschange.nil?
    end

    # search for the computer record in LDAP
    # @param [ipa_master] which master to ask
    # @param [ipa_domain] the domain for k5start
    # @param [fqdn] name of the principal (host) for the query
    # @return [boolean] was a registration returned?
    # @api private
    def ldaps_registration(
     ipa_master='localhost',
     ipa_domain='EXAMPLE.COM',
     fqdn='ipa.auto.local')
     registered = nil
      # assumes your domain went from dc=x,dc=y,dc=z to x.y.z in the fact
      domain = ipa_domain.downcase.split(/\./).join(',dc=')
      cmd = "/usr/bin/ldapsearch -x -b dc=#{domain} -h ldap://#{ipa_master} " +
      "fqdn=#{fqdn},cn=computers,cn=accounts,dc=#{domain}"
      registered = Facter::Util::Resolution.exec(cmd)
      !registered.nil?
    end

    # check getentity API on the system for non-local users
    # @return [boolean] was there something found not in the local user db?
    # @api private
    def getent_registration
      # now we are just guessing - if there are no unique directory users
      # this will still be unknown
      entities = []
      passwd = []
      entities = (Facter::Util::Resolution.exec(
        '/usr/bin/getent passwd')).split(/\n/).sort!
      passwd = File.readlines('/etc/passwd').split(/\n/).sort!
      passwd.each {|l| l.chomp! }
     if entities != passwd and entities.count != 0
       true
     else
       nil
     end
    end

    # is this client registered to and IPA server?
    # @return [boolean] is this client registered?
    def ipa_client_registered
      # absolute minimal requirement
      registered = nil # unknown
      ipa_master = Facter.value(:ipa_master)
      ipa_domain = Facter.value(:ipa_domain)
      fqdn = Facter.value(:fqdn)
      begin
        registered = ipa_query(ipa_master, fqdn)
        if (registered !=true and File.exist? '/usr/bin/ipa')
           registered = ipa_client(fqdn)
        end
        if (registered != true and File.exist?('/usr/bin/ldapsearch'))
          if File.exist?('/usr/bin/k5start')
            registered = k5start_registration(ipa_master, ipa_domain, fqdn)
          end
          if registered != true
            registered = ldaps_registration(ipa_master, ipa_domain, fqdn)
          end
        end
        if (registered != true and File.exist? '/usr/bin/getent')
          registered = getent_registration
        end
      rescue Exception => e
           Facter.debug("#{e.backtrace[0]}: #{$!}.")
      end
      registered
    end

  end
end

Facter.add(:ipa_client_registered) do
  confine { File.exist?('/etc/krb5.keytab') }
  confine { File.exist?('/etc/ipa/ca.crt') }
  setcode { Facter::Util::Ipa_client_registered.ipa_client_registered }
end
