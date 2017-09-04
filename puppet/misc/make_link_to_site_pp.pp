$directories = [
  '/etc/puppetlabs/code/environments',
  '/etc/puppetlabs/code/environments/production',
  '/etc/puppetlabs/code/environments/production/manifests',
]

file { $directories :
  ensure => directory,
}

file { '/etc/puppetlabs/code/environments/production/manifests/site.pp':
  ensure => link,
  target => '/tmp/puppet/manifests/site.pp',
}
