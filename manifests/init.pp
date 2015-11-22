# == Class: ipa
#
# Identity Policy Audit (IPA) - keberos, LDAP and RBAC services for Linux.
#
# === Parameters
#
# [*role*]
#  What kind of ipa install do.
#
#  Defaults to 'agent' and takes value of agent, master or replica.
#
#  Note that master and replicas will have agent configured and setup.
#
# [*enable*]
#   To manage the ipa configuration
#
#   Defaults to 'true' on supported OSes and false otherwise.
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
class ipa (
  $role = hiera('ipa::role', $ipa::defaults::role),
  $enable = hiera('ipa::enable', $ipa::defaults::enable),
  $domain = hiera('ipa::domain', undef),
  $master = hiera('ipa::master', undef),
) inherits ipa::defaults {

  # validate parameters here
  if $enable == true {

    class { 'ipa::install': role => $role, } ->
    class { 'ipa::config': } ~>
    class { 'ipa::service': role => $role, } ->
    Class['ipa']

  }
}
