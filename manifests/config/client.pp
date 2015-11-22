# ipa::config::client
#
#  Placeholder for the client configuration subclasses
#
################################################################################
#
# manifests/config/client.pp
#
# Copyright 2015 Jeremiah Powell (waveclaw@waveclaw.net)
#
# See LICENSE for Licensing.
#
################################################################################
#
# == Class: config::client
#
#  Configure the client part of an IPA domain
#
# === Parameters
#
#  [*domain*]
#    Domain to join.  Currently only support one.
#
#  [*server*]
#    Server for the single domain in use. For clusters use the cluster name or
#    IP address.
#
#
class ipa::config::client(
  $domain = undef,
  $server = undef,
  ) {
  #
  # TODO: Abstract the config of the client past install
  #  ipa_config
  # TODO: use the ipa_host interface?  Certainly use the others
  #
  # ipa_group
  # ipa_hbacrule
  # ipa_hbacsvcgroup
  # ipa_hbacsvc
  # ipa_hostgroup
  # ipa_host
  # ipa_resolver_flush
  # ipa_sudocmdgroup
  # ipa_sudocmd
  # ipa_sudorule
  # ipa_user
  File {
    mode   => '0644',
    owner  => 0,
    group  => 0,
  }
  file { '/etc/ipa':
    ensure => directory,
    mode   => '0755',
  } -> File['/etc/ipa/ca.pem', '/etc/ipa/ca.crt', '/etc/ipa/ipa.crt']
  file { '/etc/ipa/ca.pem':
    ensure  => file,
    content => file(hiera('ipa::cert::pem::source', 'ipa/ipa.pem')),
  }
  file { ['/etc/ipa/ca.crt', '/etc/ipa/ipa.crt']:
    ensure  => file,
    content => file(hiera('ipa::cert::der::source', 'ipa/ipa.der')),
  }
  file { '/var/log/krb5':
    ensure => directory,
    mode   => '0755',
  } ->
  file {'/etc/krb5.conf':
    ensure  => file,
    content => template('ipa/krb5.conf.erb'),
  }
  file {'/etc/sssd':
    ensure => directory,
    mode   => '0755',
  } ->
  file {'/etc/sssd/sssd.conf':
    ensure  => file,
    mode    => '0600',
    content => template('ipa/sssd.conf.erb'),
  }
}
