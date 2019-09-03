# firewall config
class fireball::firewall {
  class { 'firewall': }
  Firewall {
    before  => Class['fireball::firewall::post'],
    require => Class['fireball::firewall::pre'],
  }
  class { ['fireball::firewall::pre', 'fireball::firewall::post']: }
# # related
# -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
#
# # lo
# -A INPUT -i lo -j ACCEPT
#
# # icmp
# -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
#
# # drop invalid packets
# -A INPUT -m conntrack --ctstate INVALID -j DROP
# COMMIT
}
