# firewall config
class fireball::firewall::post {
  firewallchain { 'INPUT:filter:IPv4':
    ensure => present,
    policy => drop,
    before => undef,
  }
  firewallchain { 'OUTPUT:filter:IPv4':
    ensure => present,
    policy => accept,
    before => undef,
  }
  firewallchain { 'INPUT:filter:IPv6':
    ensure => present,
    policy => drop,
    before => undef,
  }
  firewallchain { 'OUTPUT:filter:IPv6':
    ensure => present,
    policy => accept,
    before => undef,
  }
}
