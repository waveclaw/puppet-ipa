# ipa::config::server::cleanup
#
#  Remove an IPA server configuration
#
################################################################################
#
# manifets/server/cleanup.pp
#
# Copyright 2015 Jeremiah Powell (waveclaw@waveclaw.net)
#
# See LICENSE for Licensing.
#
################################################################################
#
# == Class: ipa::config::server::cleanup
#
#  IPA server configuration leaves much garbage that a client will not need.
#  Remove it.
#
# === Parameters
#
#  This class takes no parameters.
#
class ipa::config::server::cleanup {
  #
  # TODO: remove the server parts of a configuration without harming client
  #
}
