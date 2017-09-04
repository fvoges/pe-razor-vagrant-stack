class network::bridge_dhcp_on {
  file { 'ifcfg-eth1':
    ensure => 'file',
    path   => '/etc/sysconfig/network-scripts/ifcfg-eth1',
  }
  file_line { 'eth1 PEERDNS=no':
    path    => '/etc/sysconfig/network-scripts/ifcfg-eth1',
    line    => 'PEERDNS="no"',
    match   => 'PEERDNS',
    require => File['ifcfg-eth1'],
    notify  => Service['network'],
  }
  file_line { 'eth1 BOOTPROTO=dhcp':
    path    => '/etc/sysconfig/network-scripts/ifcfg-eth1',
    line    => 'BOOTPROTO="dhcp"',
    match   => 'BOOTPROTO',
    require => File['ifcfg-eth1'],
    notify  => Service['network'],
  }
  file_line { 'eth1 ONBOOT=yes':
    path    => '/etc/sysconfig/network-scripts/ifcfg-eth1',
    line    => 'ONBOOT="yes"',
    match   => 'ONBOOT',
    require => File['ifcfg-eth1'],
    notify  => Service['network'],
  }
  service {'network': }

  package { ['dbus', 'avahi',]:
    ensure => 'present',
  }
  service {'messagebus':
    ensure => 'running',
    enable => true,
  }
  service {'avahi-daemon':
    ensure  => 'running',
    enable  => true,
    require => Service['messagebus'],
  }
}