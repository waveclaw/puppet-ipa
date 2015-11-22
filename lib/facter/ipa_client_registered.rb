Facter.add(:ipa_client_registered) do
  #
  # this will either be nil or a UTC String
  #
  setcode do
    if Facter.respond_to? :ipa_master and Facter.respond_to? :ipa_domain
     ipa_master = Facter.value(:ipa_master)
     ipa_domain = Facter.value(:ipa_domain)
     host = Facter.value(:host)
     domain = Facter.value(:domain)
     if host and domain
       fqdn = [host.domain].join('.')
     end
     if File.exists? '/etc/krb5.keytab' and File.exists? '/usr/bin/k5start' and File.exists? '/usr/bin/ldapsearch' and fqdn
       Facter::core::Execution.exec("/usr/bin/k5start -u host/#{fqdn} -f /etc/krb5.keytab -- /usr/bin/ldapsearch -Y GSSAPI -H ldap://#{ipa_master} -b #{ipa_domain} fqdn=#{fqdn} | awk '/^krbLastPwdChange/ { print $2}'")
     end
   end
  end
end

