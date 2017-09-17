#!/bin/bash

if [ ! -d /vagrant ]
then
  echo "This script should be used from the razor-server Virtual Machine"
  exit 1
fi

mkdir -p lib/ruby/facter
cp /vagrant/puppet/modules/site/lib/facter/* lib/ruby/facter
zip -r /etc/puppetlabs/razor-server/mk-extension.zip lib/

