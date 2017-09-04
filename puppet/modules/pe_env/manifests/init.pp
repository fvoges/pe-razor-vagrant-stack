class pe_env {
  file { '/etc/profile.d/pe.sh' :
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "PATH=/opt/puppetlabs/bin:/opt/puppetlabs/puppet/bin:\${PATH}\n",
  }
}
