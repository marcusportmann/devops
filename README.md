# devops

## Overview

The **devops** project provides the capability to provision the various technologies that
make up the DevOps platform in an automated manner using Packer, Vagrant and Ansible.
Support is provided for the Virtualbox, VMware Desktop, VMware ESXi and Hyper-V
virtualisation platforms.

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
6. Install OpenJDK 11 by executing the following commands in a Terminal window:
   ```
   brew tap AdoptOpenJDK/openjdk
   brew cask install adoptopenjdk11
   ```
7. Install Apache Maven by executing the following command in a Terminal window:
   ```
   brew install maven
   ```
8. Install jenv by executing the following commands in a Terminal window:
   ```
   brew install jenv
   ```
9. Add the following lines to your .zshrc or .bash_profile file to enable jenv and restart your Terminal:
   ```
   export PATH="$HOME/.jenv/bin:$PATH"
   eval "$(jenv init -)"
   ```
10. Set OpenJDK 11 as the default java verison by executing the following commands in a Terminal window:
    ```
    jenv add /Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home
    jenv global 11.0
    ```
11. Install the maven plugin for jenv by executing the following command in a Terminal window:
    ```
    jenv enable-plugin maven
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
8. Download and install the VMware Open Virtualization Format Tool (ovftool) from:
   ```
   https://code.vmware.com/web/tool/4.3.0/ovf
   ```
9. Create a link to the ovftool binary in /usr/local/bin.
   ```
   ln -s /Applications/VMware\ OVF\ Tool/ovftool /usr/local/bin/ovftool
   ```
10. OPTIONAL: If required install the Vagrant VMware ESXi plugin.
    ```
    vagrant plugin install vagrant-vmware-esxi
    ```
11. Install Ansible by executing the following command in a Terminal window:
    ```
    brew install ansible
    ```
12. Install OpenJDK 11 by executing the following commands in a Terminal window:
    ```
    brew tap AdoptOpenJDK/openjdk
    brew cask install adoptopenjdk11
    ```
13. Install Apache Maven by executing the following command in a Terminal window:
    ```
    brew install maven
    ```
14. Install jenv by executing the following commands in a Terminal window:
    ```
    brew install jenv
    ```
15. Add the following lines to your .zshrc or .bash_profile file to enable jenv and restart your Terminal:
    ```
    export PATH="$HOME/.jenv/bin:$PATH"
    eval "$(jenv init -)"
    ```
16. Set OpenJDK 11 as the default java verison by executing the following commands in a Terminal window:
    ```
    jenv add /Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home
    jenv global 11.0
    ```
17. Install the maven plugin for jenv by executing the following command in a Terminal window:
    ```
    jenv enable-plugin maven
    ```


### Option 3: Install Packer, Vagrant, Hyper-V and Ansible on Windows 64-bit

1. Enable the Hyper-V Windows feature.

2. Create a new Virtual Switch for Hyper-V named "Vagrant Switch" by launching Windows PowerShell as an administrator and executing the following commands:
   ```
   New-VMSwitch -SwitchName "Vagrant Switch" -SwitchType Internal
   New-NetIPAddress -IPAddress 192.168.184.1 -PrefixLength 24 -InterfaceAlias "vEthernet (Vagrant Switch)"
   New-NetNat -Name VagrantSwitchNetwork -InternalIPInterfaceAddressPrefix 192.168.184.0/24
   ```

3. Download and install Git for 64-bit Windows from *https://git-scm.com/download/win*.

4. Download the Packer for 64-bit Windows archive from *https://packer.io/* and extact the packer binary somewhere on your path e.g. C:\DevOpsTools.

5. Download Vagrant for 64-bit Windows from *https://www.vagrantup.com/downloads.html* and install.

6. Launch the Git Bash console as an Administrator.


### Build OS Images

"Packer is an open source tool for creating identical machine images for multiple platforms
from a single source configuration. Packer is lightweight, runs on every major operating
system, and is highly performant, creating machine images for multiple platforms in parallel.
Packer does not replace configuration management like Chef or Puppet. In fact, when building
images, Packer is able to use tools like Chef or Puppet to install software onto the image."
-- Wikipedia

This project supports the creation of VirtualBox Vagrant boxes, VMware Vagrant boxes, and VMware OVA templates for the following operating systems:

- CentOS 7 (centos7)
- CentOS 8 (centos8)
- Ubuntu 18.04 (ubuntu1804)
- Ubuntu 20.04 (ubuntu2004)

Build the required templates by executing the *build-os-image.sh* script, under the *packer* directory, in a Terminal window:
```
./build-os-image.sh -p PROVIDER -o OPERATING_SYSTEM

e.g. ./build.sh -p vmware_desktop -o ubuntu1804
```


## Configuration

The config.yaml file defines all the hosts that make up the DevOps platform and the
Ansible configuration that should be applied to these hosts.

The file is broken up into the following sections:

- Variables
- Profiles
- Hosts

### Profiles
The **profiles** section at the top of the **config.yaml** file defines collections of
hosts that should be provisioned together as a set. This allows a portion of the DevOps
platform to be deployed using commands similar to the following:

```
devops.sh -p <PROVIDER> <ACTION> <PROFILE>

e.g.

devops.sh -p vmware_desktop up etcd-minimal

devops.sh -p vmware_desktop provision etcd-minimal

devops.sh -p vmware_desktop destroy etcd-minimal
```

You can connect to a server using SSH with the username **cloud-user** and the password **cloud**. This user is able to **su** to the **root** user.

### Host Naming Convention

Hosts in the config.yaml file are named according to one of the following naming convention:

- **domain** - **environment**

   e.g. monitoring-dev.local where the *domain* is monitoring and the *environment* is dev (Development).

- **application** - **environment**

   e.g. prometheus-server-dev.local where the *application* is Prometheus Server and the *environment* is dev (Development).

   e.g. prometheus-alert-manager-dev.local where the *application* is Prometheus Alert Manager and the *environment* is dev (Development).

   e.g. grafana-dev.local where the *application* is Grafana and the *environment* is dev (Development).

- **platform** - **platform_instance** - **environment** -  **instance_id**

   e.g. confluent-digital-dev-01.local where the *platform* is confluent, the *platform_instance* is digital, the *environment* is dev (Development), and the *instance_id* is 01.

   e.g. confluent-analytics-prod-01.local where the *platform* is confluent, the *platform_instance* is analytics, the *environment* is prod (Production), and the *instance_id* is 01.

   e.g. confluent-event-bus-uat-01.local where the *platform* is confluent, the *platform_instance* is event-bus, the *environment* is uat (User Acceptance Testing), and the *instance_id* is 01.

- **platform** - **platform_component** - **platform_instance** - **environment** - **instance_id**

   e.g. confluent-zk-digital-dev-01.local where the *platform* is confluent, the *platform_component* is zk (ZooKeeper), the *platform_instance* is digital, the *environment* is dev (Development), and the *instance_id* is 01.

   e.g. confluent-ks-digital-dev-01.local where the *platform* is confluent, the *platform_component* is ks (Kafka Server), the *platform_instance* is digital, the *environment* is dev (Development), and the *instance_id* is 01.

   e.g. confluent-zks-digital-dev-01.local where the *platform* is confluent, the *platform_component* is zks (ZooKeeper and Kafka Server), the *platform_instance* is digital, the *environment* is dev (Development), and the *instance_id* is 01.

   e.g. k8s-m-analytics-test-01.local where the *platform* is k8s (Kubernetes), the *platform_component* is m (Master), the *platform_instance* is analytics, the *environment* is test (Test), and the *instance_id* is 01.

   e.g. confluent-mm-event-bus-prod-01.local where the *platform* is confluent, the *platform_component* is mm (MirrorMaker), the *platform_instance* is event-bus, the *environment* is prod (Production), and the *instance_id* is 01.

   e.g. confluent-sr-event-bus-prod-01.local where the *platform* is confluent, the *platform_component* is sr (Schema Registry), the *platform_instance* is event-bus, the *environment* is prod (Production), and the *instance_id* is 01.

**NOTE:** The following environment indicators are used:

- **dev** - Development
- **test** - Test
- **uat** - User Acceptance Testing
- **preprod** - Pre-Production
- **prod** - Production

   e.g. kafka-local-dev-mirrormaker-01.local where the *platform* is kafka, the *platform_instance* is local, the *environment* is dev (Development), the *platform_component* is mirrormaker, and the *instance_id* is 01.

### Cluster Naming Convention

Platform clusters in the config.yaml file, for example a particular Kafka cluster, are named according to the following naming convention:

**platform_instance**_**environment**

e.g. digital_dev, digital_prod, digital_dr, analytics_dev, analytics_uat_, event_bus_prod, etc.

The benefit of this approach is that clusters associated with different environments can
be referenced in the same file in order to connect them, e.g. production and DR clusters
where replication needs to be configured between these clusters.


## Confluent

The **devops** project provides a playbook and an associated set of roles that support the
deployment of Confluent clusters.


## Ports

The following ports are used by the components that form part of the DevOps stack:

<table>
  <tr>
    <th>Standard Port</th>
    <th>Kubernetes Port</th>
    <th>Service</th>
    <th>Protocol</th>
  </tr>
  <tr>
    <td>N/A</td>
    <td>30080</td>
    <td>Istio Ingress Gateway (HTTP)</td>
    <td>HTTP</td>
  </tr>
  <tr>
    <td>N/A</td>
    <td>30443</td>
    <td>Istio Ingress Gateway (HTTPS)</td>
    <td>HTTPS</td>
  </tr>
  <tr>
    <td>3000</td>
    <td>32500</td>
    <td>Grafana</td>
    <td>HTTP</td>
  </tr>
  <tr>
    <td></td>
    <td>32501</td>
    <td>Jaeger</td>
    <td>HTTP</td>
  </tr>
  <tr>
    <td>N/A</td>
    <td>32502</td>
    <td>Kiali</td>
    <td>HTTPS</td>
  </tr>
  <tr>
    <td>9090</td>
    <td>32503</td>
    <td>Prometheus Server</td>
    <td>HTTP</td>
  </tr>
  <tr>
    <td>9091</td>
    <td>32504</td>
    <td>Prometheus Alert Manager</td>
    <td>HTTP</td>
  </tr>
  <tr>
    <td></td>
    <td>32505</td>
    <td>Elasticsearch</td>
    <td>HTTP</td>
  </tr>
  <tr>
    <td></td>
    <td>32506</td>
    <td>Kibana</td>
    <td>HTTP</td>
  </tr>
  <tr>
    <td>N/A</td>
    <td>32520</td>
    <td>Longhorn UI</td>
    <td>HTTP</td>
  </tr>
  <tr>
    <td>N/A</td>
    <td>32521</td>
    <td>Postgres Operator UI</td>
    <td>HTTP</td>
  </tr>
</table>


## Users and Groups

The following users and groups are provisioned by the various Ansible scripts:

### Users

* General
  * cloud-user (300)
* Platform Services
  * cp-control-center (310)
  * cp-kafka (311)
  * cp-kafka-connect (312)
  * cp-kafka-rest (313)
  * cp-ksql (314)
  * cp-schema-registry (315)
  * cp-zookeeper (316)
  * burrow (318)
  * etcd (320)
  * kafka (330)
  * zookeeper (340)
* Logging and Monitoring
  * beats (405)
  * elasticsearch (410)
  * fluentd (415)
  * flume (420)
  * grafana (425)
  * graylog (430)
  * jaeger (435)
  * kiali (440)
  * kibana (445)
  * logstash (450)
  * prometheus (455)
* Kubernetes
  * k8s-admin (500)
* Other
  * vagrant (1000)

### Groups

* General
  * cloud-user (300)
* Platform Services
  * cp-control-center (310)
  * cp-kafka (311)
  * cp-kafka-connect (312)
  * cp-kafka-rest (313)
  * cp-ksql (314)
  * cp-schema-registry (315)
  * cp-zookeeper (316)
  * burrow (318)
  * etcd (320)
  * kafka (330)
  * zookeeper(340)
* Logging and Monitoring
  * beats (405)
  * elasticsearch (410)
  * fluentd (415)
  * flume (420)
  * grafana (425)
  * graylog (430)
  * jaeger (435)
  * kiali (440)
  * kibana (445)
  * logstash (450)
  * prometheus (455)
* Kubernetes
  * k8s-admin (500)
* Other
  * vagrant (1000)


## Troubleshooting

### Increasing the size of a VirtualBox virtual disk

1. Download the vmware-vdiskmanager utility archive from https://kb.vmware.com/s/article/1023856.

2. Extract the vmware-vdiskmanager utility archive and place the vmware-vdiskmanger on the path.

3. Navigate to the directory containing the VMDK file for the virtual disk, e.g.
   ~/VirtualBox VMs/devops_devopslocal_1581670889760_49077, and execute the following command:

   vmware-vdiskmanager -x <size> <virtual disk file>

   e.g.

   vmware-vdiskmanager -x 35GB ubuntu1804-disk001.vmdk



