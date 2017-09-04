class network::bridge_dhcp_off {
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
  file_line { 'eth1 BOOTPROTO=none':
    path    => '/etc/sysconfig/network-scripts/ifcfg-eth1',
    line    => 'BOOTPROTO="no"',
    match   => 'BOOTPROTO',
    require => File['ifcfg-eth1'],
    notify  => Service['network'],
  }
  file_line { 'eth1 ONBOOT=no':
    path    => '/etc/sysconfig/network-scripts/ifcfg-eth1',
    line    => 'ONBOOT="no"',
    match   => 'ONBOOT',
    require => File['ifcfg-eth1'],
    notify  => Service['network'],
  }
  service {'network':
    subscribe => File['ifcfg-eth1'],
  }
}