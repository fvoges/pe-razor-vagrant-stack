
## site.pp ##

Package {
  allow_virtual => false,
}

# This file (/etc/puppetlabs/puppet/manifests/site.pp) is the main entry point
# used when an agent connects to a master and asks for an updated configuration.
#
# Global objects like filebuckets and resource defaults should go in this file,
# as should the default node definition. (The default node can be omitted
# if you use the console and don't define any other nodes in site.pp. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.)

## Active Configurations ##

# PRIMARY FILEBUCKET
# This configures puppet agent and puppet inspect to back up file contents when
# they run. The Puppet Enterprise console needs this to display file contents
# and differences.

# Define filebucket 'main':
filebucket { 'main':
  server => 'puppet-master',
  path   => false,
}

# Make filebucket 'main' the default backup location for all File resources:
File { backup => 'main' }

# DEFAULT NODE
# Node definitions in this file are merged with node data from the console. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.

# The default node definition matches any node lacking a more specific node
# definition. If there are no other nodes in this file, classes declared here
# will be included in every node's catalog, *in addition* to any classes
# specified in the console for that node.

node default {
  # This is where you can declare classes for all nodes.
  # Example:
  #   class { 'my_class': }
}

node 'dhcp-server' {
  class { '::ntp':
    tinker  => true,
    servers => [ 'puppet-master iburst', ],
  }
  include ::razor_dnsmasq
  include ::razor_ipv4_forward
  include ::pe_env
}

node 'puppet-master' {
  class { '::ntp':
    tinker  => true,
    servers => [ 'pool.ntp.org iburst', ],
  }
  include ::pe_env
}

node 'razor-server' {
  class { '::ntp':
    tinker  => true,
    servers => [ 'puppet-master iburst', ],
  }
  include ::pe_env
  class { '::pe_razor':
#    pe_tarball_base_url => 'file:///opt/vagrant-common/repos/pe-packages',
#    microkernel_url     => "file:///opt/vagrant-common/repos/pe-packages/${::pe_version}/puppet-enterprise-razor-microkernel-${::pe_version}.tar",
  }
  include ::razor_client
  class { '::apache':
    default_vhost => false,
  }
  apache::vhost { $fqdn:
    docroot        => '/opt/vagrant-common',
    port           => '80',
    manage_docroot => false,
    docroot_owner  => 'vagrant',
    docroot_group  => 'vagrant',
  }
}

node /^awesomeweb\d+/ {
  class { '::ntp':
    tinker  => true,
    servers => [ 'puppet-master iburst', ],
  }
  #include ::network::bridge_dhcp_off

  class { '::apache':
    default_vhost => false,
  }
  apache::vhost { $fqdn:
    docroot        => '/opt/www',
    port           => '80',
    manage_docroot => true,
  }
  file { '/opt/www/index.html':
    ensure  => file,
    content => "<html>\n<head>\n<title>Awesome Web Site</title>\n</head>\n<body>\n<h1>This is ${::fqdn}</h1>\n</body>\n</html>\n",
  }
  file { '/opt/www/index.txt':
    ensure  => file,
    content => "This is ${::fqdn}\n",
  }
  @@haproxy::balancermember { $::fqdn:
    listening_service => 'awesomesite00',
    ports             => '80',
    server_names      => $::hostname,
    ipaddresses       => $::ipaddress,
    options           => 'check',
  }
}

node 'awesomesite' {
  class { '::ntp':
    tinker  => true,
    servers => [ 'puppet-master iburst', ],
  }
  #include ::network::bridge_dhcp_on

  include ::haproxy
  haproxy::listen { 'awesomesite00':
    ipaddress => '0.0.0.0',
    ports     => '80',
    mode      => 'http',
    options   => {
      'option'  => [
        'tcplog',
        #'ssl-hello-chk',
        ],
      'balance' => 'roundrobin',
    },
  }

  haproxy::listen { 'stats':
    ipaddress => '0.0.0.0',
    ports     => '9090',
    options   => {
      'mode'  => 'http',
      'stats' => [
        'uri /',
      ],
    },
  }
}

node /^mysqldb\d+/ {
  class { '::ntp':
    tinker  => true,
    servers => [ 'puppet-master iburst', ],
  }
  class { '::mysql::server':
  }
}
