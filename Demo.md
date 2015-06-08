# Simple Razor demo

This demo shows how to use soimple tags to provision 3 different node types:
 - Load Balancer
 - Web server
 - MySQL server

The first two types are used to create a load balanced website.

The demo also shows how to set how many nodes of each type are required and how to set the hostnames base of the node role.

## Preparation

Follow the instructions from [README.md](README.md) to bring up the three main servers.

### Install custom task
SSH to the `razor-server` and install the custom task:

```shell
vagrant ssh razor server
sudo su -
cp -r /vagrant/tasks/6 /opt/puppet/share/razor-server/tasks/centos/
```

### Prepare nodes

These are the nodes to be provisioned using Razor. You need at least 4 VMs for this demo.

 1. Import the the sample OVA template from the `example_pxe_boot_vm` directory into VirtualBox.
 1. Rename the VM to `Razor-Template-Large`.
 1. Change the memory size to 850MB.
 1. Change the OS type to "Other Linux (64-bit)".
 1. Make a clone of `Razor-Template-Large` and name it `Razor-Template-Small`
 1. Change the memory size to 768MB (CentOS 6 install will fail with less than this).
 1. __Optional__ - Add a second network interface and set it to bridge mode.
     - If using the bridge interface, uncomment the lines `include network::bridge_dhcp_off` and `include network::bridge_dhcp_on` in `site.pp`.

Create nodes using the templates. This step requires the `VBoxManage` command line tool.

The following commands will create 6 nodes (3 small and 3 large).

```shell
# This is the default location in Mac OS X. Update if necessary
VBOX_VM_DIR="~/VirtualBox VMs"

for n in {1..3}
do
  # Clone VM and register it with VirtualBox
  VBoxManage clonevm Razor-Template-Small --mode machine --name Razor-Small-${n}
  VBoxManage registervm "${VBOX_VM_DIR}"/Razor-Small-${n}/Razor-Small-${n}.vbox

  # Clone VM and register it with VirtualBox
  VBoxManage clonevm Razor-Template-Large --mode machine --name Razor-Large-${n}
  VBoxManage registervm "${VBOX_VM_DIR}"/Razor-Large-${n}/Razor-Large-${n}.vbox
done
```

###  Start nodes

Start all nodes.

```shell
for n in {1..3}
do
  VBoxManage startvm Razor-Small-${n}
  sleep 30
  VBoxManage startvm Razor-Large-${n}
  sleep 30
done
```

They should boot using the razor agent (you should see a Linux login).

## Using Razor

### Brokers

Create a new broker named `pe` to install Puppet Enterprise using the the Puppet Master server `puppet-master`.

```shell
razor create-broker --name pe --broker-type puppet-pe --configuration server=puppet-master
```

### Tags

Create a few tags to apply to nodes based on fact values.

```shell
# This tag will be applied to the "small" nodes (768MB ram)
razor create-tag --name small --rule '["<", ["num", ["fact", "memorysize_mb"]], 800]'
# This tag will be applied to the "large" nodes (850MB ram)
razor create-tag --name large --rule '[">=", ["num", ["fact", "memorysize_mb"]], 800]'
# This tag will be applied to nodes with 1 CPU
razor create-tag --name 1cpu --rule '["=", ["num", ["fact", "processorcount"]], 1]'
# This tag will be applied to nodes with 2 CPUs
razor create-tag --name 2cpu --rule '["=", ["num", ["fact", "processorcount"]], 2]'
# This tag will be applied to nodes that are virtual machines
razor create-tag --name virtual --rule '["=",  ["fact", "is_virtual"], true]'
```

### Add a repo

Create a OS repo to provision the servers:

```shell
razor create-repo --name=centos-6.6 --task centos/6 --iso-url http://mirror.centos.org/centos/6.6/isos/x86_64/CentOS-6.6-x86_64-minimal.iso
```

You can't donwload the OS ISO from [mirror.centos.org](mirror.centos.org). Open [http://mirror.centos.org/centos/6.6/isos/x86_64/CentOS-6.6-x86_64-minimal.iso](http://mirror.centos.org/centos/6.6/isos/x86_64/CentOS-6.6-x86_64-minimal.iso) in your browser, pick a mirror and replace the URL above with your selected mirror.

The repo creation will take some time - it has to download the ISO and then extract the contents to the local disk. You can monitor the progress with the command `watch razor commands`. Once the command finished, you can move to the next step.

### Create policies

Policies are the rules used by Razor to decide what to do with the available nodes.

#### Web servers

This rule will use upto 2 nodes tagged with the tag `small` and `1cpu`, provision with CentOS, name them `awesomeweb${id}` (e.g., `node17` would be named `awesomeweb17`).

```shell
razor create-policy --name awesome-web --repo centos-6.6 --broker pe --tag '[ "small", "1cpu" ]' --enabled --hostname 'awesomeweb${id}' --root-password secret --max-count 2 --task centos/6/custom --node-metadata role=awesome-web --node-metadata group=awesomesite
```

#### Load balancer

This rule will use 1 node tagged with the tag `small` and `2cpu`, provision with CentOS, name it `awesomesite` (e.g., `node17` would be named `awesomesite`).

```shell
razor create-policy --name awesome-lb --repo centos-6.6 --broker pe --tag '[ "small", "2cpu" ]' --enabled --hostname 'awesomesite' --root-password secret --max-count 1 --task centos/6/custom --node-metadata role=awesome-lb --node-metadata group=awesomesite
```

#### MySQL DB server

This rule will use 1 node tagged with the tag `large` and `2cpu`, provision with CentOS, name it `mysqldb${id}` (e.g., `node17` would be named `mysqldb17`).

```shell
razor create-policy --name mysqldb --repo centos-6.6 --broker pe --tag '[ "large", "2cpu" ]' --enabled --hostname 'mysqldb${id}' --root-password secret --max-count 1 --task centos/6/custom --node-metadata role=mysqldb --node-metadata group=db
```



## Off-line use

This demo requires internet access. There are some bits and pieces to allow to use local files for most of the tasks except installing the Forge Modules.

Instructions to use this off-line is out of scope. Sorry, you're on your own.

