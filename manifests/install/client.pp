# == Class: ipa::client::install
#
# IPA - Control client installation
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
class ipa::install::client (
  $reinstall = false,
  $host = hiera('ipa::config::host', $ipa::defaults::host),
) inherits ipa::defaults {
  #if ($reinstall or $::ipa_client_registered == '') {
  # ipa_resolver_flush { "flushcache-${host}": cache => all, }
  # ipa_client_installer { $host: }
  # ipa_client_register { $host: }
  #
  # Ipa_cache_flush["flushcache-${host}"] ->
  # Ipa_client_installer[$host] ->
  # Ipa_client_register[$host]
  #}

}
