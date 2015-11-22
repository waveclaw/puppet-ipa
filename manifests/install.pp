# ipa::install
#
#  Install packages for IPA and require repositories for said packages
#
################################################################################
#
# manifests/install.pp
#
# Copyright 2015 Jeremiah Powell (waveclaw@waveclaw.net)
#
# See LICENSE for Licensing.
#
################################################################################
#
# == Class ipa::install
#
class ipa::install(
  $role = $::ipa::role,
  $packages = hiera('ipa::packages', undef),
) inherits ipa::defaults {
  # install the server on server builds
  case $role {
    'master','replica', 'server', 'primary', 'secondary': {
      $package_list = $packages ? {
          undef   => $ipa::defaults::server_packages,
          default => $packages,
      }
      class { 'ipa::install::server': }
      Package[$package_list] ->
        Class['ipa::install::server'] ->
        Class['ipa::install::client']
    }
    default: {
      $package_list = $packages ? {
        undef   => $ipa::defaults::client_packages,
        default => $packages,
      }
    }
  }

  include ipa::install::repo

  package { [ $package_list ] :
    ensure => present,
  }
  Class['ipa::install::repo'] -> Package[$package_list]

  # always install the client
  class { 'ipa::install::client': }

}
