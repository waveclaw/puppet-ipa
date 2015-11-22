# == Class: config::server::remove
#
#  Remove the server's configuration
#
# === Parameters
#
# [*role*]
#   Role for the server.  Defaults to primary.
#
class config::server::remove (
  $role = 'primary',
) {}
