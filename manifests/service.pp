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
  $role = hiera('ipa::role', 'client'),
  $services = hiera('ipa::service::services', undef),
) inherits ipa::defaults {

  if $services {
    $service_list = $services
  } else {
    case $role {
      'master','replica': {
        $service_list = $ipa::defaults::master_services ? {
           undef   => $ipa::defaults::client_services,
           default => $ipa::defaults::master_services,
        }
      }
      default: {
        $service_list = $ipa::defaults::client_services
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
