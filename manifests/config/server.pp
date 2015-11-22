# ipa::config::server
#
#  Placeholder for the server configuration subclasses
#
################################################################################
#
# manifests/config/server.pp
#
# Copyright 2015 Jeremiah Powell (waveclaw@waveclaw.net)
#
# See LICENSE for Licensing.
#
################################################################################
#
# == Class: config::server
#
#  Full desc config::server
#
# === Parameters
#
#  [*role*]
#    Specific role for this server:
#      * standalone 'server',
#      * 'secondary' or 'replica'
#      * a 'primary' or 'master'
#
#  [*domain*]
#    Domain to join.  Currently only support one.
#
#  [*server*]
#    Server for the single domain in use. For clusters use the cluster name or
#    IP address
#
class ipa::config::server(
  $role   = undef,
  $domain = undef,
  $server = undef,
  ) {
    case $role {
      'master', 'primary': {
          class { 'ipa::config::server::primary': }
        }
        'replica', 'secondary': {
          class { 'ipa::config::server::replica': }
        }
        'server': {
          #
          # TODO: single-server only configuration
          #
        }
        default: { }
    }
    #
    # TODO: common server configuration here
    #
}
