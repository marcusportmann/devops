# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'
require 'yaml'
require 'getoptlong'
require 'ipaddr'

def generate_guest_info_meta_data(hostname, fqdn, ip, gateway, dns_server, dns_search)
ubuntu_boot_cloud_config = """
instance-id: #{fqdn}
local-hostname: #{hostname}
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - #{ip}
      gateway4: #{gateway}
      nameservers:
        search: [#{dns_search}]
        addresses: [#{dns_server}]
"""
end

def generate_hosts_file(provider, profile, hosts)
  hosts_file = """127.0.0.1 localhost
::1 localhost
"""

  profile['hosts'].each do |host_name|

    if hosts.include?(host_name)

      host = hosts[host_name]

      if ((!host[provider]['fqdn'].nil?) && (!host[provider]['fqdn'].empty?) && (!host[provider]['domain'].nil?) && (!host[provider]['domain'].empty?) && (!host[provider]['ip'].nil?) && (!host[provider]['ip'].empty?))

        host_fqdn = host[provider]['fqdn']
        host_domain = host[provider]['domain']
        host_ip = host[provider]['ip']
        host_hostname = host_fqdn.slice(0..(host_fqdn.index(".%s" % host_domain)-1))

        if !(host_ip.index "/").nil?
          host_ip = host_ip[0, (host_ip.index "/")]
        end

        hosts_file += "%-15.15s" % host_ip
        hosts_file += ' '
        hosts_file += host_hostname
        hosts_file += ' '
        hosts_file += host_fqdn

        hosts_file += "\n"

      end

    end

  end
  
  hosts_file
end

def cidr_to_ip_network_netmask(cidr)
  # TODO: Add validation for CIDR

  cidr = cidr.strip

  # Split the IP address and network mask
  ip,prefix = cidr.split('/')
  
  # Split the IP address into an array of integer octets
  ip_octets_i = ip.split(".").map { |s| s.to_i }  
  
  # Get the 32-bit unsigned integer representation of the IP address
  ip_u32 = (ip_octets_i[0]<< 24) + (ip_octets_i[1]<< 16) + (ip_octets_i[2]<< 8) + (ip_octets_i[3])
  
  mask =  (2**32-1) ^ ((2**32-1) >> prefix.to_i)

  netmask_octets_i = []
  netmask_octets_s = []
  3.downto(0) do |x|
    octet = (mask >> 8*x) & 0xFF 
    netmask_octets_i.push(octet)
    netmask_octets_s.push(octet.to_s)
  end
  
  # Get the 32-bit unsigned integer representation of the netmask
  netmask_u32 = (netmask_octets_i[0]<< 24) + (netmask_octets_i[1]<< 16) + (netmask_octets_i[2]<< 8) + (netmask_octets_i[3])
  
  # Get the 32-bit unsigned integer representation of the network
  network_u32 = ip_u32 & netmask_u32
  
  network = [network_u32].pack("N").unpack("C4").join(".")
  
  return ip, network, netmask_octets_s.join('.')
end

if ARGV.length > 2 and ARGV[0] == 'box' and ARGV[1] == 'remove'
  abort
end

$profile_name = ''
$provider = ''

Vagrant.require_version '>= 2.2.0'

VAGRANTFILE_API_VERSION = '2'
VAGRANT_DEFAULT_PROVIDER = 'virtualbox'
VAGRANT_VALID_PROVIDERS = ['hyperv', 'vmware_desktop', 'vmware_esxi', 'virtualbox']

if not ENV['VAGRANT_PROVIDER'].nil?
  $provider = ENV['VAGRANT_PROVIDER']
end

ARGV.each_with_index do |argument, index|
  if argument and argument.include? '--provider' and argument.include? '=' and (argument.split('=')[0] == '--provider')
    $provider = argument.split('=')[1]
    
    if !VAGRANT_VALID_PROVIDERS.include?($provider)
      raise "The vagrant provider specified by the command-line argument --provider (%s) is not valid" % $provider
    end

    if not ENV['VAGRANT_PROVIDER'].nil?
      if not ENV['VAGRANT_PROVIDER'] == $provider
        raise "The vagrant provider specified by the command-line argument --provider (%s) does not match the provider specified using the VAGRANT_PROVIDER environment variable (%s)" % [$provider, ENV['VAGRANT_PROVIDER']]
      end
    end
  end

  if argument and argument.include? '--profile' and argument.include? '=' and (argument.split('=')[0] == "--profile")
    $profile_name = argument.split('=')[1]
  end
end

if ($provider.nil? || $provider.empty?)
  puts "Using the Vagrant default provider: %s" %  VAGRANT_DEFAULT_PROVIDER
  $provider = VAGRANT_DEFAULT_PROVIDER
else
  puts "Using the Vagrant provider: %s" % $provider
end

CONFIG_FILE = 'config.yaml'
CONFIG_FILE_PATH = File.join(File.dirname(__FILE__), CONFIG_FILE)

if File.exist?(CONFIG_FILE_PATH)
  puts "Using the configuration file: %s" % CONFIG_FILE_PATH
else
  raise "Failed to find the configuration file (%s)" % CONFIG_FILE_PATH
end

$config_file = YAML.load_file(CONFIG_FILE_PATH)
$hosts_config = $config_file['hosts']

$hosts = Hash.new

$hosts_config.each do |host_config|
  $hosts[host_config['name']] = host_config
end

if ($profile_name.nil? || $profile_name.empty?)
  raise "Please specify the name of a profile defined in the config.yml file using the --profile=PROFILE_NAME command-line argument"
end

$profiles = $config_file['profiles']

$profile = nil

$profiles.each do |profile|
  if profile['name'] == $profile_name
    $profile = profile
  end
end

if !$profile
  raise "Failed to find the profile %s in the config.yaml file" % $profile_name
else
  puts "Executing with profile: %s" % $profile_name
end

# ------------------------------------------------------------------------------------
# Build the Ansible groups using the enabled hosts
# ------------------------------------------------------------------------------------
$ansible_groups = Hash.new

$profile['hosts'].each do |host_name|

  host = $hosts[host_name]

  if !host
    raise "Failed to find the host (%s) for the profile (%s)" % [host_name, $profile_name]
  else
    if (!host['ansible_groups'].nil? && !host['ansible_groups'].empty?)

    host['ansible_groups'].split(/\s*,\s*/).each do |ansible_group|

      if !$ansible_groups[ansible_group]
      $ansible_groups[ansible_group] = []
      end

      $ansible_groups[ansible_group] += [host_name]
    end

  end
  end
end

puts "ansible_groups: %s" % $ansible_groups

# ------------------------------------------------------------------------------------
# Build the Ansible variables
# ------------------------------------------------------------------------------------
$ansible_vars = Hash.new

# Add the variables in the config.yml file to the Ansible variables
variables = $config_file['variables']

variables.each do |variable|

  if variable['values'].length == 1
  $ansible_vars[variable['name']] = variable['values'][0]
  end

  if variable['values'].length > 1
  $ansible_vars[variable['name']] = []

  variable['values'].each do |value|
    $ansible_vars[variable['name']] += [value]
  end
  end
end

puts "ansible_vars: %s" % $ansible_vars

# ------------------------------------------------------------------------------------
# Write the Ansible inventory file
# ------------------------------------------------------------------------------------
INVENTORY_FILE = '.vagrant/provisioners/ansible/inventory/custom_ansible_inventory'
INVENTORY_FILE_PATH = File.join(File.dirname(__FILE__), INVENTORY_FILE)

puts "Writing the Ansible inventory file: %s" % INVENTORY_FILE_PATH

FileUtils.mkdir_p '.vagrant/provisioners/ansible/inventory'

File.open(INVENTORY_FILE_PATH, 'w') { |file|

  $profile['hosts'].each do |host_name|

    if $hosts.include?(host_name)

      host = $hosts[host_name]

      file.puts "%s ansible_host=%s\n" % [host_name, host[$provider]['ip'].split('/').first]

    end
  end

  file.puts "\n"

  $ansible_groups.each do |ansible_group_name, ansible_group_members|

    file.puts "[%s]\n" % ansible_group_name

    for ansible_group_member in ansible_group_members do
      file.puts "%s\n" % ansible_group_member
    end

    file.puts "\n"
  end
}

# ------------------------------------------------------------------------------------
# Override the VagrantPlugins::ProviderVirtualBox::Action::SetName method
#
# NOTE: This "hack" is required as it is the only way to determine the location of the
#       VirtualBox VM, which is necessary to ensure that the data disk for the VM is
#       created in the same location and removed automatcally along with the VM.
# ------------------------------------------------------------------------------------
class VagrantPlugins::ProviderVirtualBox::Action::SetName
  alias_method :original_call, :call
  def call(env)
    machine = env[:machine]
    driver = machine.provider.driver
    uuid = driver.instance_eval { @uuid }
    ui = env[:ui]

    # Find out folder of VM
    vm_folder = ''
    vm_info = driver.execute('showvminfo', uuid, '--machinereadable')
        
    lines = vm_info.split("\n")
    lines.each do |line|
      if line.start_with?('CfgFile')
        vm_folder = line.split('=')[1].gsub('"','')
        vm_folder = File.expand_path('..', vm_folder)
        ui.info "VM Folder is: #{vm_folder}"
      end
    end

    if $hosts.include?("%s" % machine.name)

      host = $hosts["%s" % machine.name]

      if host[$provider]['data_disk']

        disk_file = vm_folder + '/data-disk002.vmdk'

        ui.info 'Adding disk to VM'
        if File.exist?(disk_file)
          ui.info 'Disk already exists'
        else
          ui.info 'Creating new disk'
          driver.execute('createmedium', 'disk', '--filename', disk_file, '--size', "#{host[$provider]['data_disk']}", '--format', 'VMDK')
          ui.info 'Attaching disk to VM'
          driver.execute('storageattach', uuid, '--storagectl', 'IDE Controller', '--port', '1', '--device', '0', '--type', 'hdd', '--medium', disk_file)
        end

      end

    end

    original_call(env)
  end
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # ------------------------------------------------------------------------------------
  # Virtualbox Configuration
  # ------------------------------------------------------------------------------------
  if $provider == "virtualbox"

    puts "Using the virtualbox Vagrant provider..."

    config.vm.provider 'virtualbox' do |virtualbox|
      virtualbox.gui = false
    end

    $profile['hosts'].each do |host_name|

      if $hosts.include?(host_name)

        host = $hosts[host_name]
        
        # Determine the hostname for the host
        host_hostname = host[$provider]['fqdn']
        if (!host[$provider]['domain'].nil? && !host[$provider]['domain'].empty?) 
          if host[$provider]['fqdn'].include? (".%s" % host[$provider]['domain'])
            host_hostname = host[$provider]['fqdn'].slice(0..(host[$provider]['fqdn'].index(".%s" % host[$provider]['domain'])-1))
          else
            raise "The domain (%s) could not be found in the fqdn for the host (%s)" % [host[$provider]['domain'], host[$provider]['fqdn']]
          end
        else
          raise "No domain specified for host (%s)" % host[$provider]['fqdn']
        end                    

        config.vm.define host_name do |host_config|
          # NOTE: These boxes must have been added to Vagrant before executing this project.
          if host['type'] == 'centos7'
            host_config.vm.box = 'devops/centos7'
          end
          if host['type'] == 'centos8'
            host_config.vm.box = 'devops/centos8'
          end          
          if host['type'] == 'ubuntu1804'
            host_config.vm.box = 'devops/ubuntu1804'
          end
          if host['type'] == 'ubuntu2004'
            host_config.vm.box = 'devops/ubuntu2004'
          end
          
          host_config.vm.synced_folder '.', '/vagrant', disabled: true
        
          # Set the hostname for the VM
          host_config.vm.hostname = host_hostname
          
          # Determine the IP, network and netmask for the VM
          ip, network, netmask = cidr_to_ip_network_netmask(host[$provider]['ip'])

          # Configure the network for the VM
          host_config.vm.network 'private_network', ip: ip, netmask: netmask
          
          host_config.vm.provider :virtualbox do |virtualbox|
            virtualbox.customize ['modifyvm', :id, '--memory', host[$provider]['memory'], '--cpus', host[$provider]['cpus'], '--cableconnected1', 'on', '--cableconnected2', 'on']
          end
          
          # Ensure that the /etc/rc.local file exists
          host_config.vm.provision 'shell', inline: "if [ ! -f /etc/rc.local ]; then echo -e '#!/bin/sh -e' > /etc/rc.local && chmod 0755 /etc/rc.local; fi"

          # Add the routes for the additional networks to the private network interface and persist them in /etc/rc.local
          if host[$provider]['private_networks']
            host[$provider]['private_networks'].split(/\s*,\s*/).each do |private_network|
              static_route_command = "ip route replace %s dev eth1 src %s" % [private_network, host[$provider]['ip']]
                            
              host_config.vm.provision 'shell', inline: static_route_command
              host_config.vm.provision 'shell', inline: "static_route_command_check=`cat /etc/rc.local | grep '#{ static_route_command }' | wc -l`; if [ $static_route_command_check == '0' ]; then echo -e '\n#{ static_route_command }' >> /etc/rc.local; fi"                
            end
          end

          # Initialize the LVM configuration for the data disk if required
          if host[$provider]['data_disk']
            host_config.vm.provision 'shell', inline: "data_vg_check=`vgdisplay | grep 'VG Name' | grep 'data' | wc -l`; if [ $data_vg_check == '0' ]; then parted -s /dev/sdb mklabel msdos && parted -s /dev/sdb unit mib mkpart primary 1 100% && parted -s /dev/sdb set 1 lvm on && pvcreate /dev/sdb1 && vgcreate data /dev/sdb1; fi"
          end

          # Write out the /etc/hosts file
          host_config.vm.provision 'shell', inline: "sudo cat << EOF > /etc/hosts\n%s\nEOF" %  generate_hosts_file($provider, $profile, $hosts)

          host_config.vm.provision 'ansible' do |ansible|
            ansible.playbook = host['ansible_playbook']
            ansible.groups = $ansible_groups
            ansible.extra_vars = $ansible_vars
            # ansible.verbose = "vvv"
          end
          
        end

      end
    end
  end

  # ------------------------------------------------------------------------------------
  # VMware Desktop Configuration
  # ------------------------------------------------------------------------------------
  if $provider == 'vmware_desktop'

    puts "Using the vmware_desktop Vagrant provider..."

    config.vm.provider 'vmware_desktop' do |vmware_desktop|
      vmware_desktop.gui = true
    end

    $profile['hosts'].each do |host_name|

      if $hosts.include?(host_name)

        host = $hosts[host_name]
        
        # Determine the hostname for the host
        host_hostname = nil
        if (!host[$provider]['domain'].nil? && !host[$provider]['domain'].empty?) 
          if host[$provider]['fqdn'].include? (".%s" % host[$provider]['domain'])
            host_hostname = host[$provider]['fqdn'].slice(0..(host[$provider]['fqdn'].index(".%s" % host[$provider]['domain'])-1))
          else
            raise "The domain (%s) could not be found in the fqdn for the host (%s)" % [host[$provider]['domain'], host[$provider]['fqdn']]
          end
        else
          raise "No domain specified for host (%s)" % host[$provider]['fqdn']
        end                    
        
        config.vm.define host_name do |host_config|
          # Create the data disk if required and associate it with the VM
          if host[$provider]['data_disk']
            host_config.trigger.before :up do |trigger|
              trigger.ruby do |env,machine|              
                vdiskmanager = ""

                if Vagrant::Util::Platform.darwin?
                  vdiskmanager = '/Applications/VMware\ Fusion.app/Contents/Library/vmware-vdiskmanager'
                elsif Vagrant::Util::Platform.windows?
                  raise 'The location of the vmware-vdiskmanager application has not been set.'
                elsif Vagrant::Util::Platform.linux?
                  raise 'The location of the vmware-vdiskmanager application has not been set.'
                else
                  raise 'The location of the vmware-vdiskmanager application has not been set.'
                end

                vm_folder = ".vagrant/machines/#{ host_name }/vmware_desktop"
            
                if !File.exists?(vm_folder)
                  FileUtils.mkdir_p vm_folder
                end
            
                disk_file = vm_folder + '/data-disk002.vmdk'

                unless File.exists?( disk_file )
                  puts "Creating the VM data disk: %s" % disk_file    
                  puts "Using the command: #{vdiskmanager} -c -s #{ host[$provider]['data_disk'] }MB -a lsilogic -t 0 #{disk_file}"
                  `#{vdiskmanager} -c -s #{ host[$provider]['data_disk'] }MB -a lsilogic -t 0 #{disk_file}`
                end
              end
            end
          end
          
          # NOTE: These boxes must have been added to Vagrant before executing this project.
          if host['type'] == 'centos7'
            host_config.vm.box = 'devops/centos7'
          end
          if host['type'] == 'centos8'
            host_config.vm.box = 'devops/centos8'
          end          
          if host['type'] == 'ubuntu1804'
            host_config.vm.box = 'devops/ubuntu1804'
          end
          if host['type'] == 'ubuntu2004'
            host_config.vm.box = 'devops/ubuntu2004'
          end
          
          host_config.vm.synced_folder '.', '/vagrant', disabled: true
        
          host_config.vm.provider :vmware_desktop do |vmware_desktop|
            # Create the data disk if required and associate it with the VM
            if host[$provider]['data_disk']
              vmware_desktop.vmx['scsi0:1.filename'] = '../data-disk002.vmdk'
              vmware_desktop.vmx['scsi0:1.present']  = 'TRUE'
              vmware_desktop.vmx['scsi0:1.redo']     = ''
            end

            # Perform the VMware Fusion specific initialisation
            vmware_desktop.gui = true
            vmware_desktop.vmx['numvcpus'] = host[$provider]['cpus']
            vmware_desktop.vmx['memsize'] = host[$provider]['memory']
            vmware_desktop.vmx['ethernet0.connectionType'] = 'nat'
            vmware_desktop.vmx['ethernet0.virtualDev'] = 'vmxnet3'
            vmware_desktop.vmx['ethernet0.vnet'] = 'vmnet8'
            vmware_desktop.vmx['guestinfo.metadata.encoding'] = 'base64'
            vmware_desktop.vmx['guestinfo.metadata'] = Base64.encode64(generate_guest_info_meta_data(host_hostname, host[$provider]['fqdn'], host[$provider]['ip'], host[$provider]['gateway'], host[$provider]['dns_server'], host[$provider]['domain'])).gsub(/\n/, '')
          end
          
          # Initialize the LVM configuration for the data disk if required
          if host[$provider]['data_disk']
            host_config.vm.provision 'shell', inline: "data_vg_check=`vgdisplay | grep 'VG Name' | grep 'data' | wc -l`; if [ $data_vg_check == '0' ]; then parted -s /dev/sdb mklabel msdos && parted -s /dev/sdb unit mib mkpart primary 1 100% && parted -s /dev/sdb set 1 lvm on && pvcreate /dev/sdb1 && vgcreate data /dev/sdb1; fi"
          end

          # Write out the /etc/hosts file
          host_config.vm.provision 'shell', inline: "sudo cat << EOF > /etc/hosts\n%s\nEOF" %  generate_hosts_file($provider, $profile, $hosts)

          host_config.vm.provision 'ansible' do |ansible|
            ansible.playbook = host['ansible_playbook']
            ansible.groups = $ansible_groups
            ansible.extra_vars = $ansible_vars
            # ansible.verbose = "vvv"
          end
          
        end
      end
    end
  end
  
  # ------------------------------------------------------------------------------------
  # Hyper-V Configuration
  # ------------------------------------------------------------------------------------
  if $provider == "hyperv"

    puts "Using the hyperv Vagrant provider..."

    $profile['hosts'].each do |host_fqdn|

      if $hosts.include?(host_name)

        host = $hosts[host_name]

        # Determine the hostname for the host
        host_hostname = nil
        if (!host[$provider]['domain'].nil? && !host[$provider]['domain'].empty?) 
          if host[$provider]['fqdn'].include? (".%s" % host[$provider]['domain'])
            host_hostname = host[$provider]['fqdn'].slice(0..(host[$provider]['fqdn'].index(".%s" % host[$provider]['domain'])-1))
          else
            raise "The domain (%s) could not be found in the fqdn for the host (%s)" % [host[$provider]['domain'], host[$provider]['fqdn']]
          end
        else
          raise "No domain specified for host (%s)" % host[$provider]['fqdn']
        end                    

        config.vm.define host_name do |host_config|
          # NOTE: These boxes must have been added to Vagrant before executing this project.
          if host['type'] == 'centos7'
            host_config.vm.box = 'devops/centos7'
          end
          if host['type'] == 'centos8'
            host_config.vm.box = 'devops/centos8'
          end                   
          if host['type'] == 'ubuntu1804'
            host_config.vm.box = 'devops/ubuntu1804'
          end
          if host['type'] == 'ubuntu2004'
            host_config.vm.box = 'devops/ubuntu2004'
          end

          host_config.vm.synced_folder '.', '/vagrant', disabled: true
                      
          host_config.vm.network 'private_network', bridge: 'Vagrant Switch'                
                
          host_config.trigger.after :up do |trigger|
            trigger.info = 'Configuring the VM network...'
            trigger.run_remote = {inline: "/usr/bin/configure-network --interface eth0 --ip #{host[$provider]['ip']} --hostname #{host_hostname} --gateway #{host[$provider]['gateway']} --dnsservers #{host[$provider]['dns_server']} --dnssearch #{host[$provider]['domain']}"}
          end
       
          host_config.vm.provider :hyperv do |hyperv|
            hyperv.cpus = host[$provider]['cpus']
            hyperv.memory = host[$provider]['memory']
            hyperv.maxmemory = host[$provider]['memory']
            hyperv.vmname = hostname
          end
          
          # Ensure that the /etc/rc.local file exists
          #host_config.vm.provision 'shell', inline: "if [ ! -f /etc/rc.local ]; then echo -e '#!/bin/sh -e' > /etc/rc.local && chmod 0755 /etc/rc.local; fi"

          # Add the routes for the additional networks to the private network interface and persist them in /etc/rc.local
          #if host['private_networks']
          # host['private_networks'].split(/\s*,\s*/).each do |private_network|
          #   static_route_command = "ip route replace %s dev eth1 src %s" % [private_network, host['ip']]
          #                 
          #   host_config.vm.provision 'shell', inline: static_route_command
          #   host_config.vm.provision 'shell', inline: "static_route_command_check=`cat /etc/rc.local | grep '#{ static_route_command }' | wc -l`; if [ $static_route_command_check == '0' ]; then echo -e '\n#{ static_route_command }' >> /etc/rc.local; fi"                
          # end
          #end

          # Initialize the LVM configuration for the data disk if required
          #if host['data_disk']
          #  host_config.vm.provision 'shell', inline: "data_vg_check=`vgdisplay | grep 'VG Name' | grep 'data' | wc -l`; if [ $data_vg_check == '0' ]; then parted -s /dev/sdb mklabel msdos && parted -s /dev/sdb unit mib mkpart primary 1 100% && parted -s /dev/sdb set 1 lvm on && pvcreate /dev/sdb1 && vgcreate data /dev/sdb1; fi"
          #end

          # Write out the /etc/hosts file
          host_config.vm.provision 'shell', inline: "sudo cat << EOF > /etc/hosts\n%s\nEOF" %  generate_hosts_file($provider, $profile, $hosts)

          host_config.vm.provision 'ansible' do |ansible|
            ansible.playbook = host['ansible_playbook']
            ansible.groups = $ansible_groups
            ansible.extra_vars = $ansible_vars
          end
        end
      end
    end
  end 
  
  # ------------------------------------------------------------------------------------
  # ESXi Configuration
  # ------------------------------------------------------------------------------------
  if $provider == 'vmware_esxi'

    puts "Using the vmware_esxi Vagrant provider..."

    $profile['hosts'].each do |host_name|

      if $hosts.include?(host_name)

        host = $hosts[host_name]

        # Determine the hostname for the host
        host_hostname = nil
        if (!host[$provider]['domain'].nil? && !host[$provider]['domain'].empty?) 
          if host[$provider]['fqdn'].include? (".%s" % host[$provider]['domain'])
            host_hostname = host[$provider]['fqdn'].slice(0..(host[$provider]['fqdn'].index(".%s" % host[$provider]['domain'])-1))
          else
            raise "The domain (%s) could not be found in the fqdn for the host (%s)" % [host[$provider]['domain'], host[$provider]['fqdn']]
          end
        else
          raise "No domain specified for host (%s)" % host[$provider]['fqdn']
        end                    

        config.vm.define host_name do |host_config|
          # NOTE: These boxes must have been added to Vagrant before executing this project.
          if host['type'] == 'centos7'
            host_config.vm.box = 'devops/centos7'
          end
          if host['type'] == 'centos8'
            host_config.vm.box = 'devops/centos8'
          end          
          if host['type'] == 'ubuntu1804'
            host_config.vm.box = 'devops/ubuntu1804'
          end
          if host['type'] == 'ubuntu2004'
            host_config.vm.box = 'devops/ubuntu2004'
          end
                
          host_config.vm.provider :vmware_esxi do |vmware_esxi|
            vmware_esxi.esxi_hostname = 'esxi'
            vmware_esxi.esxi_username = 'root'
            vmware_esxi.esxi_password = 'Password1'
            
            #  OPTIONAL.  Resource Pool
            #     Vagrant will NOT create a Resource pool it for you.
            #vmware_esxi.esxi_resource_pool = '/Vagrant'

            
            #  Optional. Specify a VM to clone instead of uploading a box.
            #    Vagrant can use any stopped VM as the source 'box'.   The VM must be
            #    registered, stopped and must have the vagrant insecure ssh key installed.
            #    If the VM is stored in a resource pool, it must be specified.
            #    See wiki: https://github.com/josenk/vagrant-vmware-esxi/wiki/How-to-clone_from_vm
            #vmware_esxi.clone_from_vm = 'ubuntu1804'     

            # Create the data disk if required and associate it with the VM
            if host[$provider]['data_disk']
              data_disk_size = host[$provider]['data_disk'] / 1024

              # { size: 30, datastore: 'datastore1' }
              vmware_esxi.guest_storage = [ data_disk_size ]
            end

            #  OPTIONAL.  Guest VM name to use.
            vmware_esxi.guest_name = host_name
            
            #  OPTIONAL.  When automatically naming VMs, use this prefix.
            #vmware_esxi.guest_name_prefix = 'V-'
            
            #  OPTIONAL.  Set the guest username login.  The default is 'vagrant'.
            vmware_esxi.guest_username = 'cloud-user'
            
            vmware_esxi.guest_numvcpus = host[$provider]['cpus']
            vmware_esxi.guest_memsize = host[$provider]['memory']
            vmware_esxi.guest_nic_type = 'vmxnet3'
            vmware_esxi.guest_disk_type = 'thin'
            
            #  RISKY. guest_guestos
            #    https://github.com/josenk/vagrant-vmware-esxi/ESXi_guest_guestos_types.md
            #vmware_esxi.guest_guestos = 'centos-64'
    
            vmware_esxi.guest_custom_vmx_settings = [['guestinfo.metadata.encoding','base64'], ['guestinfo.metadata', Base64.encode64(generate_guest_info_meta_data(host_hostname, host[$provider]['fqdn'], host[$provider]['ip'], host[$provider]['gateway'], host[$provider]['dns_server'], host[$provider]['domain'])).gsub(/\n/, '')]]
          end
          
          # Initialize the LVM configuration for the data disk if required
          if host[$provider]['data_disk']
            host_config.vm.provision 'shell', inline: "data_vg_check=`vgdisplay | grep 'VG Name' | grep 'data' | wc -l`; if [ $data_vg_check == '0' ]; then parted -s /dev/sdb mklabel msdos && parted -s /dev/sdb unit mib mkpart primary 1 100% && parted -s /dev/sdb set 1 lvm on && pvcreate /dev/sdb1 && vgcreate data /dev/sdb1; fi"
          end

          # Write out the /etc/hosts file
          host_config.vm.provision 'shell', inline: "sudo cat << EOF > /etc/hosts\n%s\nEOF" %  generate_hosts_file($provider, $profile, $hosts)

          host_config.vm.provision 'ansible' do |ansible|
            ansible.playbook = host['ansible_playbook']
            ansible.groups = $ansible_groups
            ansible.extra_vars = $ansible_vars
            # ansible.verbose = "vvv"
          end
        end
      end
    end
  end   

end

