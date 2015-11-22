# == Class ipa::defaults
#
# This class is meant to be called from ipa
# It sets variables according to platform
#
class ipa::defaults {
  case $::osfamily {
    'Debian': {
      $client_packages = [ 'sssd', 'kstart', 'krb5-config',
        'krb5-user', 'libpam-krb5' ]
      $client_services = [ 'sssd', ]
      $master_packages = undef
      $master_services = undef
      $enable = true
    }
    'RedHat', 'Amazon': {
      $client_packages = [ 'sssd', 'ipa-client', 'kstart' ]
      $client_services = [ 'sssd', ]
      $master_packages = [ 'sssd', 'freeipa-server', 'ipa-client' ]
      $master_services = [ 'ipa-dnskeysyncd', 'sssd',
        'ipa-ods-exporter', 'ipa', 'ipa_memcached', ]
      $enable = true
    }
    'Suse': {
      $client_packages = [ 'sssd', 'kstart' ]
      $client_services = [ 'sssd', ]
      $master_packages = undef
      $master_services = undef
      $enable = true
    }
    default: {
      $notice = join(["Operating System ${::operatingsystem} is not supported",
        'by the Puppet DSL part of the IPA module.'],' ')
      notify { $notice: }
      $client_packages = undef
      $client_services = undef
      $master_packages = undef
      $master_services = undef
      $enable = false
    }
  }
}
