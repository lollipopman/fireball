# TODO
# - [x] dmrc
# - [x] i3configs
#   - [x] i3status.conf
# - [x] tmux
# - [x] vim
# - [x] add ~/bin to path
# - [x] manage .config/pulse/default.pa, to add connection switching
# - [x] groups
#   - [x] lpadmin for cups
#   - [x] dialout for cu
#   - [x] sudo for sudo
# - [x] create a systemd config for xss-lock
# - [x] Add work CAs to Chrome & Firefox
#   - [x] certutil -d sql:$HOME/.pki/nssdb -A -n 'DEN1-SSLCA-001-CA' -i
#   /usr/local/share/ca-certificates/DEN1-SSLCA-001-CA.crt -t TCP,TCP,TCP
# - [x] replace vim_dotfiles's activate script
# - [x] vimrc_local
# - [x] firewall
#   - [x] switch to iptables via update-alternatives
#   - [x] add iptables-persistent pkg
#   - [x] put files in /etc/iptables/*
# - [x] dropbox
#   - [x] apt repo
#   - [x] create a systemd config for dropbox personal & work, grab from arch?
#   - [x] symlinks
#   - [ ] switch to puppetlabs supported firewall module
#
# Low priority
# - [ ] replace 'xbacklight' with acpilight?
# - [ ] powertop --auto-tune
# - [ ] cups config

class fireball(
  $user = $facts['user'],
  $home = "/home/${user}",
) {
  package {
    [
      'acpi',
      'alsa-utils',
      'apt-file',
      'csvtool',
      'cu',
      'curl',
      'devscripts',
      'dict',
      'dict-devil',
      'dict-gcide',
      'dict-jargon',
      'dict-moby-thesaurus',
      'dictd',
      'dnsutils',
      'docker-ce',
      'dropbox',
      'dstat',
      'ethtool',
      'universal-ctags',
      'firefox',
      'firmware-linux',
      'firmware-linux-nonfree',
      'fonts-noto',
      'gawk',
      'nomacs', # gui image editor
      'git',
      'google-chrome-stable',
      'i3',
      'ipcalc',
      'irqbalance',
      'irqtop',
      'jq',
      'keepassx',
      'lightdm',
      'libnss3-tools', # certutil
      'lsof',
      'moreutils',
      'msmtp',
      'mtr-tiny',
      'ncdu',
      'ncurses-doc',
      'net-tools',
      'netcat-openbsd',
      'nmap',
      'openssh-client',
      'orpie',
      'pandoc',
      'pavucontrol',
      'powertop',
      'pulseaudio',
      'python-pip',
      'pv',
      'rfkill',
      'scrot',
      'socat',
      'ssmtp',
      'strace',
      'suckless-tools',
      'sysstat',
      'tcpdump',
      'tmux',
      'tree',
      'ttf-ancient-fonts',
      'unclutter',
      'vlc',
      'wireshark',
      'xautolock',
      'xclip',
      'xorg',
      'xss-lock',
      'xterm',
      'xtermcontrol',
      'yeahconsole',
    ]:
    ensure  => latest,
    require => [
      File['/etc/apt/sources.list'],
      File['/etc/apt/sources.list.d'],
    ],
  }

  package {
    [
      puppet-agent,
      puppet-lint,
      puppet6-release,
    ]:
    ensure  => latest,
    require => [
      File['/etc/apt/sources.list'],
      File['/etc/apt/sources.list.d'],
    ],
  }

  file { '/etc/apt/sources.list':
    ensure => file,
    source => 'puppet:///modules/fireball/sources.list',
    owner  => 'root',
    group  => 'root',
    mode   => '0664',
  }

  file { '/etc/apt/sources.list.d':
    ensure  => directory,
    source  => 'puppet:///modules/fireball/sources.list.d',
    recurse => true,
    purge   => true,
    owner   => 'root',
    group   => 'root',
    notify  => Exec['apt-get-update'],
  }

  exec { 'apt-get-update':
    command     => 'apt-get update',
    path        => ['/bin', '/usr/bin'],
    refreshonly => true,
  }

  package {
    [
      'firefox-esr',
      'mawk',
      'nano',
      'netcat-traditional',
    ]:
    ensure => purged,
  }

  # vim

  package { 'vim-gtk':
    ensure => latest,
  }

  package { 'vim-tiny':
    ensure  => purged,
    require => Package['vim-gtk'],
  }

  vcsrepo { "${home}/.vim":
    ensure   => present,
    revision => master,
    source   => 'https://github.com/braintreeps/vim_dotfiles.git',
    provider => git,
    group    => $user,
    owner    => $user,
    user     => $user,
  }

  file { "${home}/.vimrc":
    ensure => link,
    target => "${home}/.vim/vimrc",
    owner  => $user,
    group  => $user,
  }

  file { "${home}/.vimrc_local":
    ensure => file,
    source => 'puppet:///modules/fireball/vimrc_local',
    owner  => $user,
    group  => $user,
    mode   => '0664',
  }

  # Terminal escape code recorder
  package { 'trachet':
    ensure   => latest,
    provider => 'pip'
  }

  file { "${home}/.fonts":
    ensure => directory,
    owner  => $user,
    group  => $user,
  }

  vcsrepo { "${home}/.fonts/source-code-pro":
    ensure   => present,
    revision => release,
    source   => 'https://github.com/adobe-fonts/source-code-pro.git',
    provider => git,
    group    => $user,
    owner    => $user,
    user     => $user,
    notify   => Exec['fc-cache'],
  }

  exec { 'fc-cache':
    path        => ['/bin', '/usr/bin'],
    command     => 'fc-cache',
    refreshonly => true,
  }

  file { "${home}/.config":
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0700',
  }

  file { "${home}/.config/pulse":
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0700',
  }

  # Set i3 as default xsession
  file { "${home}/.config/pulse/default.pa":
    ensure => file,
    source => 'puppet:///modules/fireball/pulseaudio/default.pa',
    owner  => $user,
    group  => $user,
    mode   => '0664',
  }

  # Set i3 as default xsession
  file { "${home}/.dmrc":
    ensure => file,
    source => 'puppet:///modules/fireball/dmrc',
    owner  => $user,
    group  => $user,
    mode   => '0664',
  }

  file { "${home}/.i3":
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0755',
  }

  $model = $facts['dmi']['product']['name']

  if $model == 'MacBookPro11,1' {
    $mod = 'Mod4'
  } else {
    $mod = 'Mod1'
  }

  file { "${home}/.i3/config":
    ensure  => file,
    content => epp('fireball/i3/config.epp', { 'mod' => $mod }),
    owner   => $user,
    group   => $user,
    mode    => '0664',
  }

  # i3status bar
  file { "${home}/.i3status.conf":
    ensure => file,
    source => 'puppet:///modules/fireball/i3status.conf',
    owner  => $user,
    group  => $user,
    mode   => '0664',
  }

  file { "${home}/.tmux.conf":
    ensure => file,
    source => 'puppet:///modules/fireball/tmux.conf',
    owner  => $user,
    group  => $user,
    mode   => '0664',
  }

  # Xresources, xterm & yeahconsole
  file { "${home}/.Xresources":
    ensure => file,
    source => 'puppet:///modules/fireball/Xresources',
    owner  => $user,
    group  => $user,
    mode   => '0664',
    notify => Exec['load-xresources'],
  }

  # Xresources, xterm & yeahconsole
  file { "${home}/.Xresources.d":
    ensure  => directory,
    source  => 'puppet:///modules/fireball/Xresources.d',
    recurse => true,
    purge   => true,
    owner   => $user,
    group   => $user,
    mode    => '0664',
    notify  => Exec['load-xresources'],
  }

  exec { 'load-xresources':
    command     => "xrdb -load ${home}/.Xresources",
    path        => ['/bin', '/usr/bin'],
    refreshonly => true,
  }


  if $model != 'MacBookPro11,1' {
    # X11 startup script
    # - Meta key mappings, e.g. Windows Key to Ctrl
    file { "${home}/.xsessionrc":
      ensure => file,
      source => 'puppet:///modules/fireball/xsessionrc',
      owner  => $user,
      group  => $user,
      mode   => '0664',
    }
  }

  # bashrc
  file { "${home}/.bashrc":
    ensure => file,
    source => 'puppet:///modules/fireball/bashrc',
    owner  => $user,
    group  => $user,
    mode   => '0664',
  }

  user { $user:
    groups => [
                'dialout', # cu
                'cdrom',
                'floppy',
                'sudo',
                'audio',
                'dip',
                'shadow',
                'video',
                'plugdev',
                'staff',
                'netdev',
                'lpadmin', # cups
                'docker',
              ]
  }

  file { "${home}/.config/systemd":
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0775',
  }

  file { "${home}/.config/systemd/user":
    ensure  => directory,
    source  => 'puppet:///modules/fireball/systemd/user',
    recurse => true,
    purge   => true,
    owner   => $user,
    group   => $user,
    mode    => '0664',
  }

  file { "${home}/.config/systemd/user/default.target.wants":
    ensure  => directory,
    recurse => true,
    purge   => true,
    owner   => $user,
    group   => $user,
    mode    => '0775',
  }

  file { "${home}/.config/systemd/user/default.target.wants/dropbox@personal.service":
    ensure => link,
    target => "${home}/.config/systemd/user/dropbox@.service",
    owner  => $user,
    group  => $user,
  }

  file { "${home}/.config/systemd/user/default.target.wants/dropbox@work.service":
    ensure => link,
    target => "${home}/.config/systemd/user/dropbox@.service",
    owner  => $user,
    group  => $user,
  }

  file { "${home}/.config/systemd/user/default.target.wants/xss-lock.service":
    ensure => link,
    target => "${home}/.config/systemd/user/xss-lock.service",
    owner  => $user,
    group  => $user,
  }

  # CA Certs

  file { '/usr/local/share/ca-certificates/DEN1-SSLCA-001-CA.crt':
    ensure => file,
    source => 'puppet:///modules/fireball/CAs/DEN1-SSLCA-001-CA.crt',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  $certutil_cmd = @("EOF"/L)
    certutil -d sql:${home}/.pki/nssdb -A -n 'DEN1-SSLCA-001-CA' \
    -i /usr/local/share/ca-certificates/DEN1-SSLCA-001-CA.crt \
    -t TCP,TCP,TCP
    | EOF

  exec { 'nssdb-den1':
    command => $certutil_cmd,
    path    => ['/bin', '/usr/bin'],
    unless  => "certutil -d sql:${home}/.pki/nssdb -L | grep -q DEN1-SSLCA-001-CA",
    require => File['/usr/local/share/ca-certificates/DEN1-SSLCA-001-CA.crt'],
  }

  # iptables

  package { 'iptables':
    ensure => latest,
    notify => Exec['update-alternatives-iptables'],
  }

  package { 'iptables-persistent':
    ensure => latest,
  }

  file { '/etc/iptables':
    ensure  => directory,
    source  => 'puppet:///modules/fireball/iptables',
    recurse => true,
    purge   => true,
    owner   => 'root',
    group   => 'root',
  }

  exec { 'update-alternatives-iptables':
    command     => 'update-alternatives --set iptables /usr/sbin/iptables-legacy',
    path        => ['/bin', '/usr/bin'],
    refreshonly => true,
  }

  # bin files
  vcsrepo { "${home}/bin":
    ensure   => present,
    revision => master,
    source   => 'https://github.com/lollipopman/bin.git',
    provider => git,
    group    => $user,
    owner    => $user,
    user     => $user,
  }

  # dropbox
  $pdropbox = [
    'audio',
    'books',
    'docs',
    'hacks',
    'images',
    'notes',
    'pdocs',
    'pimages',
    'pnotes',
    'winapps',
  ]

  $pdropbox.each |String $dir| {
    file { "${home}/${dir}":
      ensure => link,
      target => "${home}/dropboxes/personal/Dropbox/${dir}",
      owner  => $user,
      group  => $user,
    }
  }

}
