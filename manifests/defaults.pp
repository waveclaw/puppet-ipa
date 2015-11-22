# ipa::defaults
#
#  Default parameters, aka params.pp, for the IPA configuration
#
################################################################################
#
# manifests/defaults.pp
#
# Copyright 2015 Jeremiah Powell (waveclaw@waveclaw.net)
#
# See LICENSE for Licensing.
#
################################################################################
#
# == Class ipa::defaults
#
# This class is meant to be called from ipa
# It sets variables according to platform
#
class ipa::defaults {
  $_minimal_sssd_services = ['nss', 'pam']
  $role = 'client'
  case $::osfamily {
    'Debian': {
      $client_packages = [ 'sssd', 'kstart', 'krb5-config',
        'krb5-user', 'libpam-krb5' ]
      $client_services = [ 'sssd', ]
      $server_packages = $client_packages # server platform unsupported
      $server_services = $client_services # server platform unsupported
      $enable = true
      $sssd_services = $_minimal_sssd_services
    }
    'RedHat', 'Amazon': {
      $client_packages = [ 'sssd', 'ipa-client', 'kstart' ]
      $client_services = [ 'sssd', ]
      $server_packages = [ 'sssd', 'freeipa-server', 'ipa-client' ]
      $server_services = [ 'ipa-dnskeysyncd', 'sssd',
        'ipa-ods-exporter', 'ipa', 'ipa_memcached', ]
      $enable = true
      $sssd_services = ['nss', 'sudo', 'pam', 'ssh']
    }
    'Suse': {
      $client_packages = [ 'sssd', 'kstart' ]
      $client_services = [ 'sssd', ]
      $server_packages = $client_packages # server platform unsupported
      $server_services = $client_services # server platform unsupported
      $enable = true
      $sssd_services = $_minimal_sssd_services
    }
    default: {
      $notice = join(["Operating System ${::operatingsystem} is not supported",
        'by the Puppet DSL part of the IPA module.'],' ')
      notify { $notice: }
      $client_packages = undef
      $client_services = undef
      $server_packages = undef
      $server_services = undef
      $enable = false
      $sssd_services = undef
    }
  }
}
