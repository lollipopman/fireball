# site.pp
resources { 'firewall':
  purge => true,
}

resources { 'firewallchain':
  purge => true,
}

node default {
  include fireball
}
