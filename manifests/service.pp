# ipa::service
#
#  Ensure the correct services are in the correct state for IPA server or client
#
################################################################################
#
# manifests/service.pp
#
# Copyright 2015 Jeremiah Powell (waveclaw@waveclaw.net)
#
# See LICENSE for Licensing.
#
################################################################################
#
# == Class ipa::service
#
# This class is meant to be called from ipa
# It ensure all the services are running
#
# === Parameters
#
# [*services*]
#   List of services to run
#
#
class ipa::service(
  $role = hiera('ipa::role', $::ipa::role),
  $services = hiera('ipa::services', undef),
) inherits ipa::defaults {
  case $role {
      'master','replica', 'primary', 'server', 'secondary': {
        # should include client services, too!
        $service_list = $services ? {
          undef   => $ipa::defaults::server_services,
          default => $services,
        }
      }
      default: {
        $service_list = $services ? {
          undef   => $ipa::defaults::client_services,
          default => $services,
        }
      }
  }

  service { [ $service_list ]:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
