Facter.add(:ipa_domain) do
  #
  # this will either be nil or an LDAP base path
  #
  setcode do
     if File.exists? '/etc/sssd/sssd.conf'
       domain = Facter::core.Execution.exec("awk /^ipa_domain = / {print $3}")
       if domain
         ( ['dc='] << domain.split('.') ).flatten!.join('dc=')
       end
     elsif File.exists? '/etc/openldap/ldap.conf'
       Facter::core.Execution.exec("awk /^BASE / {print $2}")
     elsif File.exists? '/etc/krb5.conf' 
       # search for default_realm = X
       default_realm = Facter::core.Execution.exec("awk /^default_realm = / {print $3} | head -1")
       # search for default_domain in default_realm in [realms]
       # using a brute-force stateful scanner
       if default_realm
        begin
         File.open('/etc/krb5.conf','r') do |line|
           if line =~ /\[realms\].*/
             realms = true
          if (realms and line =~ /\s*}\s*/)
             realms = false
          if (realms and line =~ /#{default_realm}\s*=\s*{.*/)
             in_default = true
          if (in_default and line =~ /.*default_domain\s*=\s*(\S+)/)
            domain = $1
        Rescue FileError => fe
        end # file open
        krbconf.close
        if domain
         ( ['dc='] << domain.split('.') ).flatten!.join('dc=')
        end
       end # if default_realm
   end # which conifg
 end
end

