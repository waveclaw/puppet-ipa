Facter.add(:ipa_master) do
  #
  # this will either be nil or an fqdn
  #
  setcode do
     if File.exists? '/etc/sssd/sssd.conf'
       Facter::core.Execution.exec("awk /^ipa_server = / {print $3}")
     elsif File.exists? '/etc/openldap/ldap.conf'
       uri = Facter::core.Execution.exec("awk /^URI / {print $2}")
       if (uri =~ /ldap[s]?:\/\/(\S+)/)
         $1
     elsif File.exists? '/etc/krb5.conf' 
       # search for default_realm = X
       default_realm = Facter::core.Execution.exec("awk /^default_realm = / {print $3} | head -1")
       # search for master_kdc in default_realm in [realms]
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
          if (in_default and line =~ /.*master_kdc\s*=\s*(\S+)/)
            master_kdc = $1
        Rescue FileError => fe
        end # file open
        krbconf.close
        if master_kdc
         master_kdc
        end
       end # if default_realm
   end # which conifg
 end
end

