# devops

## Overview

The **devops** project provides the capability to provision the various technologies that make up the DevOps platform in an automated manner using Packer, Vagrant and Ansible. Support is provided for the Virtualbox and VMware virtualisation platforms.

## Setup

### Option 1: Install Packer, Vagrant, VirtualBox and Ansible on MacOS

1. Install Homebrew by executing the following command in a Terminal window:
	```
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	```
2. Install Packer by executing the following command in a Terminal window:
	```
	brew install packer
	```
3. Install HashiCorp Vagrant by executing the following command in a Terminal window:
	```
	brew cask install vagrant
	```
4. Download and install VirtualBox from https://virtualbox.org.

5. Configure the VirtualBox Host-Only Ethernet Adapter as follows:

  ```
  Adapter:
    IPv4 Address: 192.168.184.1
    IPv4 Network Mask: 255.255.255.0

  DHCP Server:
    Enable Server: True
    Server Address: 192.168.184.100
    Server Mask: 255.255.255.0
    Lower Address Bound: 192.168.184.101
    Upper Address Bound: 192.168.184.254
 ```
6. Install Ansible by executing the following command in a Terminal window:
	```
	brew install ansible
	```


### Option 2: Install Packer, Vagrant, VMware Fusion and Ansible on MacOS

1. Install Homebrew by executing the following command in a Terminal window:
	```
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	```
2. Install Packer by executing the following command in a Terminal window:
	```
	brew install packer
	```
3. Install HashiCorp Vagrant by executing the following command in a Terminal window:
	```
	brew cask install vagrant
	```
4. Install VMware Fusion Pro.
5. Download and install the Vagrant VMware Utility for your MacOS from *https://www.vagrantup.com/vmware/downloads.html*.
6. Install the Vagrant VMware provider plugin by executing the following command in a Terminal window:
	```
	vagrant plugin install vagrant-vmware-desktop
	```
7. Install the license for the Vagrant VMware provider plugin by executing the following command in a Terminal window:
	```
	vagrant plugin license vagrant-vmware-desktop ~/Downloads/license.lic
	```
8. Install Ansible by executing the following command in a Terminal window:
	```
	brew install ansible
	```


### Build OS Images

"Packer is an open source tool for creating identical machine images for multiple platforms
from a single source configuration. Packer is lightweight, runs on every major operating
system, and is highly performant, creating machine images for multiple platforms in parallel.
Packer does not replace configuration management like Chef or Puppet. In fact, when building
images, Packer is able to use tools like Chef or Puppet to install software onto the image."
-- Wikipedia

This project supports the creation of VirtualBox Vagrant boxes, VMware Vagrant boxes, VMware OVF templates and VMware OVA templates for the following operating systems:

- CentOS 7.7 (centos77)
- CentOS 8.0 (centos80)
- Ubuntu 18.04 (ubuntu1804)

Build the required templates by executing the *build-os-image.sh* script, under the *packer* directory, in a Terminal window:
```
./build-os-image.sh -p PROVIDER -o OPERATING_SYSTEM

e.g. ./build.sh -p vmware_desktop -o ubuntu1804
```


## Configuration

The config.yml file defines all the hosts that make up the DevOps platform and the
Ansible configuration that should be applied to these hosts. The **profiles** section
at the top of the **config.yml** file defines collections of hosts that should be
provisioned as a related unit. This allows a portion of the DevOps platform to be
deployed using commands similar to the following:

```
vagrant --profile=<PROFILE NAME> --provider=<PROVIDER NAME> --no-parallel up

or

vagrant --profile=<PROFILE NAME> --provider=<PROVIDER NAME> --force destroy

e.g.

vagrant --profile=k8s_minimal --provider=virtualbox --no-parallel up

vagrant --profile=k8s_minimal --provider=vmware_fusion --no-parallel up

or

vagrant --profile=k8s_minimal --provider=vmware_fusion destroy --force
```

You can connect to a server using SSH with the username **cloud-user** and the password **cloud**. This user is able to **su** to the **root** user.

## Users and Groups

### Users

* etcd (301)
* prometheus (302)
* grafana (303)
* k8s-admin (310)


### Groups

* etcd (301)
* prometheus (302)
* grafana (303)
* k8s-admin (310)




