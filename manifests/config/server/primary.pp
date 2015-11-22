# ipa::config::server::primary
#
# Export the replication data
#
################################################################################
#
# manifests/config/server/primary.pp
#
# Copyright 2015 Jeremiah Powell (waveclaw@waveclaw.net)
#
# See LICENSE for Licensing.
#
################################################################################
#
# == Class: ipa:config::server::primary
#
#  A primary server must export a replication configuration to setup replicas
#  or federated copies in a clustered environment
#
# === Parameters
#
#  This class takes no parameters
#
class ipa::config::server::primary {
  #
  # TODO: trigger export of the replication packet
  #
}
