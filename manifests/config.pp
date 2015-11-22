# == Class ipa::config
#
# Parent of the specialized configuations for client and server.
#
#  See the ipa::client and ipa::server classes for the details.
#
class ipa::config {
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
    ensure => file,
    mode   => '0600',
    source => template('ipa/sssd.conf.erb'),
  }
}
