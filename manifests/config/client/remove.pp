# == Class: ipa::client::remove
#
# IPA - Control client de-installation
#
# === Parameters
# 
# [*TBD*]
#  Example Parameter
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
class ipa::config::client::remove (
  $host = hiera('ipa::config::host', $ipa::defaults::host),
) inherits ipa::defaults {

  # ipa_cache_flush { "flushcache-${host}": }
  # ipa_client_installer { $host: ensure => absent, }
  # ipa_client_register { $host: ensure  => absent, }
  #
  # Ipa_client_register[$host] ->
  # Ipa_client_installer[$host] ->
  # Ipa_cache_flush["flushcache-${host}"]

}
