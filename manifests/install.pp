# == Class ipa::install
#
class ipa::install(
  $role = 'client',
  $packages = hiera('ipa::install::packages', undef),
) inherits ipa::defaults {

  if $packages {
    $package_list = $packages
  } else {
    case $role {
      'master','replica': {
        $package_list = $ipa::defaults::master_packages ? {
          undef   => $ipa::defaults::client_packages,
          default => $ipa::defaults::master_packages,
        }
        class { 'ipa::install::server': host => $::fqdn, role => $role, }
      }
      default: {
        $package_list = $ipa::defaults::client_packages
      }
    }
  }

  include ipa::install::repo

  package { [ $package_list ] :
    ensure => present,
  }
  Class['ipa::install::repo'] -> Package[$package_list]

  # always install the client
  class { 'ipa::install::client': host => $::fqdn, }
  Package[$package_list] -> Class['ipa::install::client']

  # Properly order client, master and packages if on a master or replica
  if defined('Class[ipa::install::server]') {
    Class['ipa::install::server'] ->
    Class['ipa::install::client']
    Package[$package_list] -> Class['ipa::install::server']
  }

}
