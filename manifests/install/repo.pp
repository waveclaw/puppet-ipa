# ipa::install::repo
#
#  Abstract a repository structure for various platforms
#
################################################################################
#
# manifsts/foo.pp
#
# Copyright 2015 Jeremiah Powell (waveclaw@waveclaw.net)
#
# See LICENSE for Licensing.
#
################################################################################
#
# == Class: ipa::install::yumrepo
#
# Identity Policy Audit (IPA) repository provided by Mosek.
#
# === Parameters
#
# [*none*]
#  This class just wraps the repository resource
#
class ipa::install::repo {
  case $::osfamily {
    'RedHat' : {
      yumrepo { 'mkosek-freeipa':
        ensure              => 'present',
        baseurl             => join([ 'http:', '',
          'copr-be.cloud.fedoraproject.org', 'results', 'mkosek', 'freeipa',
          "epel-${::operatingsystemmajrelease}-\$basearch/",], '/'),
        descr               => 'Copr repo for freeipa owned by mkosek',
        enabled             => '1',
        gpgcheck            => '0',
        skip_if_unavailable => 'true',
      }
    }
    'Suse': {
      # in the offical repositories
      #  Example based on darin/zypprepo 1.0.2
      # case $operatingsystem {
      # 'OpenSuSE' : {
      # zypprepo { "openSUSE_$::lsbdistrelease}":
      #    baseurl      => join([ 'http:', '',
      #      'download.opensuse.org', 'distribution', $::lsbdistrelease,
      #      'repo', 'oss', 'suse', ], '/'),
      #    enabled      => 1,
      #    autorefresh  => 1,
      #    name         => 'openSUSE_12.1',
      #    gpgcheck     => 0,
      #    priority     => 98,
      #    keeppackages => 1,
      #    type         => 'rpm-md',
      #  }
      # }
      # 'SLES' : {
      #  Requires a subbscription from SUSE, GMBH.
      # }
      # }
      #
    }
    'Debian': {
      # in the official repositories
      #  Examples based on Puppet Labs apt::source
      #include apt
      #case $operatingsystem {
      #  'Ubuntu': {
      #    apt::source { "canonical_archive_${::lsbdistcodename}":
      #      location => "http://archive.canonical.com/ubuntu/",
      #      release => $::lsbdistcodename,
      #      repos => 'main restricted universe',
      #      include_src => false
      #    }
      #  }
      #  default: {
      #    apt::source { "debian_project_${::lsbdistcodename}":
      #      location => 'http://http.debian.net/debian',
      #      release => $::lsbdistcodename,
      #      repos => 'main contrib non-free',
      #      include_src => false, }
      #    apt::source { "debian_updates_${::lsbdistcodename}":
      #      location => 'http://http.debian.net/debian',
      #      release => "${::lsbdistcodename}-updates",
      #      repos => 'main contrib non-free',
      #      include_src => false, }
      #    apt::source { "debian_security_${::lsbdistcodename}":
      #      location => 'http://security.debian.org',
      #      release => "${::lsbdistcodename}/updates",
      #      repos => 'main contrib non-free',
      #      include_src => false, }
      #  }
      }
    default: {
      warn("Do not know what location to obtain packages for ${::osfamily}.")
    }
  }
}
