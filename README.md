# devops

## Overview

The **devops** project provides the capability to provision the various technologies that make up the DevOps platform in an automated manner using Packer, Vagrant and Ansible. Support is provided for the Virtualbox, VMware and Hyper-V virtualisation platforms.

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

5. Install Ansible by executing the following command in a Terminal window:
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


### Option 3: Install Packer, Vagrant,Hyper-V and Ansible on Windows 64-bit

1. Enable the Hyper-V Windows feature.

2. Create a new Virtual Switch for Hyper-V named "Vagrant Switch" by launching Windows PowerShell as an administrator and executing the following commands:
```
New-VMSwitch –SwitchName "Vagrant Switch" –SwitchType Internal
New-NetIPAddress –IPAddress 192.168.184.1 -PrefixLength 24 -InterfaceAlias "vEthernet (Vagrant Switch)"
New-NetNat –Name VagrantSwitchNetwork –InternalIPInterfaceAddressPrefix 192.168.184.0/24
```

3. Download and install Git for 64-bit Windows from *https://git-scm.com/download/win*.

4. Download the Packer for 64-bit Windows archive from *https://packer.io/* and extact the packer binary somewhere on your path e.g. C:\DevOpsTools.

5. Download Vagrant for 64-bit Windows from *https://www.vagrantup.com/downloads.html* and install.

6. Launch the Git Bash console as an Administrator.

6. 




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

e.g. ./build.sh -p vmware -o ubuntu1804
```


## Configuration

The config.yml file defines all the hosts that make up the DevOps platform and the
Ansible configuration that should be applied to these hosts. The **profiles** section
at the top of the **config.yml** file defines collections of hosts that should be
provisioned as a related unit. This allows a portion of the DevOps platform to be
deployed using commands similar to the following:

```
devops.sh -p <PROVIDER> <ACTION> <PROFILE>

e.g.

devops.sh -p vmware up etcd

devops.sh -p vmware provision etcd

devops.sh -p vmware destroy etcd
```

You can connect to a server using SSH with the username **cloud-user** and the password **cloud**. This user is able to **su** to the **root** user.

## Users and Groups

The following users and groups are provisioned by the various Ansible scripts:

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


## Troubleshooting

### Increasing the size of a VirtualBox virtual disk

1. Download the vmware-vdiskmanager utility archive from https://kb.vmware.com/s/article/1023856.

2. Extract the vmware-vdiskmanager utility archive and place the vmware-vdiskmanger on the path.

3. Navigate to the directory containing the VMDK file for the virtual disk, e.g. 
   ~/VirtualBox VMs/devops_devopslocal_1581670889760_49077, and execute the following command:
   
   vmware-vdiskmanager -x <size> <virtual disk file>
   
   e.g. 
   
   vmware-vdiskmanager -x 35GB ubuntu1804-disk001.vmdk 
  
   

