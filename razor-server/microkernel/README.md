# Razor Microkernel Extensions

This directory contains a custom fact and a shell script to package
it as a microkernel extension for Razor

To use it, login to the `razor-server` virtual machine and run the script:

```sh
razor-server $ /vagrant/microkernel/mkzip.sh
```

The script will create a Zip file in `/etc/puppetlabs/razor-server/mk-extension.zip`
with the contents of the `lib` directory.


