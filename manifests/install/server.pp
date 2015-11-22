# ipa::install::server
#
# placeholder for the server install subclasses
#
################################################################################
#
# manifests/install/server.pp
#
# Copyright 2015 Jeremiah Powell (waveclaw@waveclaw.net)
#
# See LICENSE for Licensing.
#
################################################################################
#
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
  $server = $::ipa::server,
) inherits ipa::defaults {

  # TODO: always do the server role
}
