# TODO
# - [x] dmrc
# - [x] i3configs
#   - [ ] i3status.conf
# - [x] tmux
# - [x] vim
# - [ ] add ~/bin to path
# - [ ] replace 'xbacklight' with acpilight?
# - [ ] manage .config/pulse/default.pa, to add connection switching
# - [ ] create a systemd config for xss-lock
# - [ ] add me to the sudoers group
# - [ ] powertop --auto-tune
# - [ ] cups config
#   - [ ] lounge, dnssd://CHI-1-8-C700-X7845._ipps._tcp.local/?uuid=a623df28-e371-11e6-8421-9c934e55356b
# - [ ] groups
#   - [ ] ldapadmin, cups
#   - [ ] dialout, cu
# - [ ] dropbox
#   - [ ] create a systemd config for dropbox personal & work
# - [ ] Add work CAs to Chrome & Firefox
#   - [ ] certutil -d sql:$HOME/.pki/nssdb -A -n 'DEN1-SSLCA-001-CA' -i /usr/local/share/ca-certificates/DEN1-SSLCA-001-CA.crt -t TCP,TCP,TCP

class fireball {

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
      'dstat',
      'ethtool',
      'exuberant-ctags',
      'firefox',
      'firmware-linux',
      'firmware-linux-nonfree',
      'fonts-noto',
      'gawk',
      'git',
      'google-chrome-stable',
      'i3',
      'ipcalc',
      'jq',
      'keepassx',
      'lightdm',
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
    ensure => latest,
    require => File['/etc/apt/sources.list.d'],
  }

  file { '/etc/apt/sources.list.d':
    ensure => directory,
    source => 'puppet:///modules/fireball/sources.list.d',
    recurse => true,
    purge => true,
    owner => 'root',
    group => 'root',
    notify => Exec['apt-get-update'],
  }

  exec { 'apt-get-update':
    command => 'apt-get update',
    path => ['/bin', '/usr/bin'],
    refreshonly => true,
  }

  package {
    [
      'nano',
      'mawk',
      'netcat-traditional',
    ]:
    ensure => purged,
  }

  package { 'vim-gtk':
    ensure => latest,
  }

  package { 'vim-tiny':
    ensure => purged,
    require => Package['vim-gtk'],
  }

  # Terminal escape code recorder
  package { 'trachet':
    ensure => latest,
    provider => 'pip'
  }

  file { '/home/hathaway/.fonts':
    ensure => directory,
    owner => 'hathaway',
    group => 'hathaway',
  }

  vcsrepo { '/home/hathaway/.fonts/source-code-pro':
    source => 'https://github.com/adobe-fonts/source-code-pro.git',
    revision => release,
    ensure => present,
    provider => git,
    group => 'hathaway',
    owner => 'hathaway',
    user => 'hathaway',
    notify => Exec['fc-cache'],
  }

  exec { 'fc-cache':
    path => ['/bin', '/usr/bin'],
    command => 'fc-cache',
    refreshonly => true,
  }

  # Set i3 as default xsession
  file { '/home/hathaway/.dmrc':
    ensure => file,
    source => 'puppet:///modules/fireball/dmrc',
    owner => 'hathaway',
    group => 'hathaway',
    mode  => '0444',
  }

  file { '/home/hathaway/.config':
    ensure => directory,
    owner => 'hathaway',
    group => 'hathaway',
    mode  => '0755',
  }

  file { '/home/hathaway/.config/i3':
    ensure => directory,
    owner => 'hathaway',
    group => 'hathaway',
    mode  => '0755',
  }

  file { '/home/hathaway/.config/i3/config':
    ensure => file,
    source => 'puppet:///modules/fireball/i3/config',
    owner => 'hathaway',
    group => 'hathaway',
    mode  => '0444',
  }

  file { '/home/hathaway/.tmux.conf':
    ensure => file,
    source => 'puppet:///modules/fireball/tmux.conf',
    owner => 'hathaway',
    group => 'hathaway',
    mode  => '0444',
  }

  # Xresources, xterm & yeahconsole
  file { '/home/hathaway/.Xresources':
    ensure => file,
    source => 'puppet:///modules/fireball/Xresources',
    owner => 'hathaway',
    group => 'hathaway',
    mode  => '0444',
    notify => Exec['load-xresources'],
  }

  # Xresources, xterm & yeahconsole
  file { '/home/hathaway/.Xresources.d':
    ensure => directory,
    source => 'puppet:///modules/fireball/Xresources.d',
    recurse => true,
    purge => true,
    owner => 'hathaway',
    group => 'hathaway',
    mode  => '0755',
    notify => Exec['load-xresources'],
  }

  exec { 'load-xresources':
    command => 'xrdb -load /home/hathaway/.Xresources',
    path => ['/bin', '/usr/bin'],
    refreshonly => true,
  }

  # vim configs
  vcsrepo { '/home/hathaway/.vim':
    source => 'https://github.com/braintreeps/vim_dotfiles.git',
    revision => master,
    ensure => present,
    provider => git,
    group => 'hathaway',
    owner => 'hathaway',
    user => 'hathaway',
  }

  # X11 startup script
  # - Meta key mappings, e.g. Windows Key to Ctrl
  file { '/home/hathaway/.xsessionrc':
    ensure => file,
    source => 'puppet:///modules/fireball/xsessionrc',
    owner => 'hathaway',
    group => 'hathaway',
    mode  => '0444',
  }
}
