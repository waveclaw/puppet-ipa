# == Class: ipa::install::server
#
# IPA - Control server installation
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
class ipa::install::server (
  $host,
  $role,
) inherits ipa::defaults {}
