# ipa
#
#  Top-level and default interface to the IPA module classes and resources
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
# == Class: ipa
#
# Identity Policy Audit (IPA) - keberos, LDAP and RBAC services for Linux.
#
# === Parameters
#
# [*role*]
#  What kind of ipa install do.
#
#  Defaults to 'agent' and takes value of agent, client, server, master or
#  replica.
#
#  Note that server, master and replica will still have agents setup.
#
# [*enable*]
#   To manage the ipa configuration
#
#   Defaults to 'true' on supported OSes and false otherwise.
#
# [*domain*]
#   The keberos domain to use. Note the DNS domain is inferred from $::fqdn
#
# [*server*]
#   Name of the IPA server.  This is should be the CNAME or proxy or load
#   balancer virtual IP address when primary and replica are used.
#
# === Configuration Class
#
# [*ipa::config*]
#   Update this class with parameters for your installation.
#
#   This class can pull settings from hiera.
#
#   Generic defaults are in ipa::defaults if not provided in ipa::config.
#
#
class ipa(
  $role = hiera('ipa::role', $ipa::defaults::role),
  $enable = hiera('ipa::enable', $ipa::defaults::enable),
  $domain = hiera('ipa::domain', undef),
  $server = hiera('ipa::server', undef),
  $sssd_services = hiera('ipa::sssd::services', $ipa::defaults::sssd_services),
) inherits ipa::defaults {

  # validate parameters here
  if $enable == true {

    class { 'ipa::install': } ->
    class { 'ipa::config': } ~>
    class { 'ipa::service': } ->
    Class['ipa']

  }
}
