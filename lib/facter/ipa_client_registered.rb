#!/usr/bin/ruby
#
#  Is this system registered?
#
#   Copyright 2016 Pat Riehecky <riehecky@fnal.gov>
#
#   See LICENSE for licensing.
#
require 'facter'

module Facter::Util::Ipa_client_registered
  @doc=<<EOF
    The IPA registration fact 'is this client registered or not?'
EOF
  class << self
    def ipa_client(fqdn='ipa.auto.local')
      # there has to be some kind of a proper ipa client library
      # for ruby
      record = nil
      # principal = `klist /etc/krb5.keytab | awk '/$fqdn/ {print $2}'``
      # kinit $principal -k -t /etc/krb5.keytab
      # ipa host-show $(hostname).$(domainname)
      fqdn = Facter.value(:fqdn)
      begin
        record = Facter::Util::Resolution.exec([
          "/usr/bin/kinit",
          "$(klist /etc/krb5.keytab | awk '/#{fqdn}/ {print $2}')",
          "-k -t /etc/krb5.keytab &&",
          "/usr/bin/ipa host-show $(hostname).$(domainname)"
        ].join(' '))
      rescue Exception => e
        Facter.debug("#{e.backtrace[0]}: #{$!}.")
      end
      record.nil?
    end

    def ipa_query(ipa_master='localhost', fqdn='ipa.auto.local')
      # uses the directy json API.  This does require the gssapi gem
      # http://adam.younglogic.com/2010/07/talking-to-freeipa-json-web-api-via-curl/
      # and login credentials if required
      require 'uri'
      require 'puppet/util/ipajson'
      registered = nil
      begin
        server = IPA.new(ipa_master)
        server.create_robot
        host = server.post('host_find',[[fqdn],{}])
        registered = true if (fqdn == host['result']['result'][0]['fqdn'][0])
      rescue Exception => e
           Facter.debug("#{e.backtrace[0]}: #{$!}.")
      end
      registered
    end

    def k5start_registration(ipa_master, ipa_domain, fqdn)
      registered = nil
      begin
           # evil little shell one-liner
           registered = Facter::Util::Resolution.exec(
           ["/usr/bin/k5start -u host/#{fqdn}",
            '-f /etc/krb5.keytab -- /usr/bin/ldapsearch -Y GSSAPI',
            "-H ldap://#{ipa_master} -b #{ipa_domain} fqdn=#{fqdn}",
            "| awk '/^krbLastPwdChange/ { print $2}'"].join(' '))
      rescue Exception => e
           Facter.debug("#{e.backtrace[0]}: #{$!}.")
      end
       registered != nil
    end

    def ldaps_registration(ipa_master, ipa_domain, fqdn)
      # assumes your domain went from dc=x,dc=y,dc=z to x.y.z in the fact
      domain = ipa_domain.downcase.split(/\./).join(',dc=')
      registered = nil
      begin
        registered = Facter::Util::Resolution.exec(
         "/usr/bin/ldapsearch -x -b dc=#{domain} -h #{ipa_master} \
         fqdn=#{fqdn},cn=computers,cn=accounts,dc=#{domain}")
      rescue Exception => e
           Facter.debug("#{e.backtrace[0]}: #{$!}.")
      end
       registered != nil
    end

    def getent_registration
      # now we are just guessing - if there are no unique directory users
      # this will still be unknown
      entities = []
      passwd = []
      begin
       entities = (Facter::Util::Resolution.exec(
        '/usr/bin/getent passwd')).split(/\n/).sort!
       passwd = File.readlines('/etc/passwd')
       passwd.each {|l| l.chomp! }
       passwd.sort!
     rescue Exception => e
          Facter.debug("#{e.backtrace[0]}: #{$!}.")
     end
     if entities != passwd and entities.count != 0
       true
     else
       nil
     end
    end

    def ipa_client_registered
      # absolute minimal requirement
      return false unless File.exist?('/etc/ipa/ca.crt')
      registered = nil # unknown
      ipa_master = Facter.value(:ipa_master)
      ipa_domain = Facter.value(:ipa_domain)
      fqdn = Facter.value(:fqdn)
      if (File.exist? '/usr/sbin/ipa')
         registered = ipa_client(fqdn)
      end
      if (registered !=true)
        registered = ipa_query(ipa_master, fqdn)
      end
      if (registered != true and File.exist?('/usr/bin/k5start') and
           File.exist?('/usr/bin/ldapsearch'))
        registered = k5start_registration(ipa_master, ipa_domain, fqdn)
      end
      if (registered != true and File.exist? '/usr/bin/ldapsearch')
        registered = ldaps_registration(ipa_master, ipa_domain, fqdn)
      end
      if (registered != true and File.exist? '/usr/bin/getent')
        registered = getent_registration
      end
      registered
    end

  end
end

Facter.add(:ipa_client_registered) do
  confine { File.exist?('/etc/krb5.keytab') }
  confine { File.exist?('/etc/ipa/ca.pem') }
  setcode { Facter::Util::Ipa_client_registered.ipa_client_registered }
end
