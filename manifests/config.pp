# ipa::config
#
#  Master class for configuration of IPA clients and servers.
#
################################################################################
#
# manifsts/foo.pp
#
# Copyright 2015 Jeremiah Powell (waveclaw@waveclaw.net)
#
# See LICENSE for Licensing.
#
################################################################################
#
# == Class ipa::config
#
# Parent of the specialized configuations for client and server.
#
#  See the ipa::client and ipa::server classes for the details.
#
class ipa::config(
  $role = hiera('ipa::role', $::ipa::role),
  $domain = hiera('ipa::domain', $::ipa::domain),
  $server = hiera('ipa::server', $::ipa::server),
  ) {
  case $role {
      'server', 'master', 'primary', 'replica' : {
        class { 'ipa::config::server':
          role   => $::ipa::config::role,
          domain => $::ipa::config::domain,
          server => $::ipa::config::server,
        }
      }
      default: { }
  }
  class { 'ipa::config::client':
    domain => $::ipa::config::domain,
    server => $::ipa::config::server,
  }
}
