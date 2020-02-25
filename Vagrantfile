# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'
require 'yaml'
require 'getoptlong'
require 'ipaddr'

def generate_guest_info_meta_data(name, hostname, ip, gateway, dns_server, dns_search)

ubuntu_boot_cloud_config = """
instance-id: #{name}
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

  profile['hosts'].each do |hostName|

    if hosts.include?(hostName)

      host = hosts[hostName]

      if ((not host['ip'].nil?) && (not host['ip'].empty?) && (not host['hostname'].nil?) && (not host['hostname'].empty?))

        ip = host['ip']

        if not (ip.index "/").nil?
          ip = ip[0, (ip.index "/")]
        end

        hosts_file += "%-15.15s" % ip
        hosts_file += ' '
        hosts_file += host['hostname']

        if ((not host['fqdn'].nil?) && (not host['fqdn'].empty?))
          hosts_file += ' '
          hosts_file += host['fqdn']
        end

        hosts_file += "\n"

      end

    end

  end

  hosts_file

end

def cidr_to_ip_and_netmask(cidr)

  # TODO: Add validation for CIDR

	cidr = cidr.strip

	ip,prefix = cidr.split('/')

	mask =  (2**32-1) ^ ((2**32-1) >> prefix.to_i)

  octets = []
	3.downto(0) do |x|
	  octet = (mask >> 8*x) & 0xFF 
	  octets.push(octet.to_s)
  end
  
  return ip, octets.join('.')
end

if ARGV.length > 2 and ARGV[0] == 'box' and ARGV[1] == 'remove'
  abort
end

profileName = ''
provider = ''

Vagrant.require_version '>= 2.2.0'

VAGRANTFILE_API_VERSION = '2'
VAGRANT_DEFAULT_PROVIDER = 'virtualbox'

if not ENV['VAGRANT_PROVIDER'].nil?
  provider = ENV['VAGRANT_PROVIDER']
end

ARGV.each_with_index do |argument, index|

  if argument and argument.include? '--provider' and argument.include? '=' and (argument.split('=')[0] == '--provider')
    provider = argument.split('=')[1]

    if not ENV['VAGRANT_PROVIDER'].nil?
      if not ENV['VAGRANT_PROVIDER'] == provider
        raise "The vagrant provider specified by the command-line argument --provider (%s) does not match the provider specified using the VAGRANT_PROVIDER environment variable (%s)" % [provider, ENV['VAGRANT_PROVIDER']]
      end
    end
  end

  if argument and argument.include? '--profile' and argument.include? '=' and (argument.split('=')[0] == "--profile")
    profileName = argument.split('=')[1]
  end

end

if (provider.nil? || provider.empty?)
  puts "Using the Vagrant default provider: %s" %  VAGRANT_DEFAULT_PROVIDER
  provider = VAGRANT_DEFAULT_PROVIDER
else
  puts "Using the Vagrant provider: %s" % provider
end

CONFIG_FILE = 'config.yaml'
CONFIG_FILE_PATH = File.join(File.dirname(__FILE__), CONFIG_FILE)

if File.exist?(CONFIG_FILE_PATH)
  puts "Using the configuration file: %s" % CONFIG_FILE_PATH
else
  raise "Failed to find the configuration file (%s)" % CONFIG_FILE_PATH
end

config_file = YAML.load_file(CONFIG_FILE_PATH)
hosts_config = config_file['hosts']

$hosts = Hash.new

hosts_config.each do |host_config|
  $hosts[host_config['name']] = host_config
end

if (profileName.nil? || profileName.empty?)
  raise "Please specify the name of a profile defined in the config.yml file using the --profile=PROFILE_NAME command-line argument"
end

profiles = config_file['profiles']

profile = nil

profiles.each do |tmpProfile|
  if tmpProfile['name'] == profileName
    profile = tmpProfile
  end
end

if !profile
  raise "Failed to find the profile %s in the config.yaml file" % profileName
else
  puts "Executing with profile: %s" % profileName
end


# ------------------------------------------------------------------------------------
# Build the Ansible groups using the enabled hosts
# ------------------------------------------------------------------------------------
ansible_groups = Hash.new

profile['hosts'].each do |hostName|

  host = $hosts[hostName]

  if !host
	raise "Failed to find the host (%s) for the profile (%s)" % [hostName, profileName]
  else

    if (!host['ansible_groups'].nil? && !host['ansible_groups'].empty?)

	  host['ansible_groups'].split(/\s*,\s*/).each do |ansible_group|

	    if !ansible_groups[ansible_group]
	  	ansible_groups[ansible_group] = []
	    end

	    ansible_groups[ansible_group] += [host['name']]
	  end

	end
  end
end

puts "ansible_groups: %s" % ansible_groups


# ------------------------------------------------------------------------------------
# Build the Ansible variables
# ------------------------------------------------------------------------------------
ansible_vars = Hash.new

# Save the configuration for the enabled hosts in the Ansible variables
if (!provider.nil? && !provider.empty?)

  ansible_vars['hosts'] = Hash.new
  ansible_vars['host_names_by_group'] = Hash.new

  profile['hosts'].each do |hostName|

    host = $hosts[hostName]

    host_var = Hash.new

    if ((not host['hostname'].nil?) && (not host['hostname'].empty?))
      host_var['hostname'] = host['hostname']
    end
    if ((not host['fqdn'].nil?) && (not host['fqdn'].empty?))
      host_var['fqdn'] = host['fqdn']
    end
    if ((not host['ip'].nil?) && (not host['ip'].empty?))
      host_var['ip'] = host['ip']
    end
#     if ((not host['network'].nil?) && (not host['network'].empty?))
#       host_var['network'] = host['network']
#     end

    ansible_vars['hosts'][host['name']] = host_var

    if (!host['ansible_groups'].nil? && !host['ansible_groups'].empty?)
      host['ansible_groups'].split(/\s*,\s*/).each do |ansible_group|

        if !ansible_vars["host_names_by_group"][ansible_group]
          ansible_vars["host_names_by_group"][ansible_group] = []
        end

        ansible_vars["host_names_by_group"][ansible_group] += [host['name']]

      end
	end


  end
end

# Add the variables in the config.yml file to the Ansible variables
variables = config_file['variables']

variables.each do |variable|

  if variable['values'].length == 1
	ansible_vars[variable['name']] = variable['values'][0]
  end

  if variable['values'].length > 1
	ansible_vars[variable['name']] = []

	variable['values'].each do |value|
	  ansible_vars[variable['name']] += [value]
	end
  end
end

puts "ansible_vars: %s" % ansible_vars

# ------------------------------------------------------------------------------------
# Write the Ansible inventory file
# ------------------------------------------------------------------------------------
INVENTORY_FILE = '.vagrant/provisioners/ansible/inventory/custom_ansible_inventory'
INVENTORY_FILE_PATH = File.join(File.dirname(__FILE__), INVENTORY_FILE)

puts "Writing the Ansible inventory file: %s" % INVENTORY_FILE_PATH

FileUtils.mkdir_p '.vagrant/provisioners/ansible/inventory'

File.open(INVENTORY_FILE_PATH, 'w') { |file|

  profile['hosts'].each do |hostName|

    if $hosts.include?(hostName)

      host = $hosts[hostName]

      file.puts "%s ansible_host=%s\n" % [hostName, host['ip'].split('/').first]

    end
  end

  file.puts "\n"

  ansible_groups.each do |ansible_group_name, ansible_group_members|

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

			if host['data_disk']

				disk_file = vm_folder + '/data-disk002.vmdk'

				ui.info 'Adding disk to VM'
				if File.exist?(disk_file)
					ui.info 'Disk already exists'
				else
					ui.info 'Creating new disk'
					driver.execute('createmedium', 'disk', '--filename', disk_file, '--size', "#{host['data_disk']}", '--format', 'VMDK')
					ui.info 'Attaching disk to VM'
					driver.execute('storageattach', uuid, '--storagectl', 'IDE Controller', '--port', '1', '--device', '0', '--type', 'hdd', '--medium', disk_file)
				end

			end

    end

    original_call(env)
  end
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Always use Vagrant's insecure key
  config.ssh.username = 'cloud-user'
  config.ssh.password = 'cloud'
  config.ssh.insert_key = true

  config.vm.synced_folder ".", "/vagrant", disabled: true

  # ------------------------------------------------------------------------------------
  # Virtualbox Configuration
  # ------------------------------------------------------------------------------------
  if provider == "virtualbox"

    puts "Using the '%s' provider..." % provider

    config.vm.provider 'virtualbox' do |virtualbox|
      virtualbox.gui = false
    end

    profile['hosts'].each do |hostName|

      if $hosts.include?(hostName)

        host = $hosts[hostName]

        puts "Provisioning host: %s" % host['name']

        config.vm.define host['name'] do |host_vm|
          host_vm.vm.provider :virtualbox do |virtualbox, override|

            # NOTE: These boxes must have been added to Vagrant before executing this project.
            if host['type'] == 'centos77'
	            override.vm.box = 'devops/centos77'
	          end
            if host['type'] == 'centos80'
	            override.vm.box = 'devops/centos80'
	          end          
      			if host['type'] == 'ubuntu1804'
	      			override.vm.box = 'devops/ubuntu1804'
		      	end

            override.vm.synced_folder '.', '/vagrant', disabled: true

            override.vm.hostname = host['fqdn']
            
            ip, netmask = cidr_to_ip_and_netmask(host['ip'])

            override.vm.network 'private_network', ip: ip, netmask: netmask

            virtualbox.customize ['modifyvm', :id, '--memory', host['memory'], '--cpus', host['cpus'], '--cableconnected1', 'on', '--cableconnected2', 'on']

			      # Ensure that the /etc/rc.local file exists
			      override.vm.provision 'shell', inline: "if [ ! -f /etc/rc.local ]; then echo -e '#!/bin/sh -e' > /etc/rc.local && chmod 0755 /etc/rc.local; fi"

            # Add the routes for the additional networks to the private network interface and persist them in /etc/rc.local
            if host['private_networks']
							host['private_networks'].split(/\s*,\s*/).each do |private_network|
							  static_route_command = "ip route replace %s dev eth1 src %s" % [private_network, host['ip']]
														  
						  	override.vm.provision 'shell', inline: static_route_command
						  	override.vm.provision 'shell', inline: "static_route_command_check=`cat /etc/rc.local | grep '#{ static_route_command }' | wc -l`; if [ $static_route_command_check == '0' ]; then echo -e '\n#{ static_route_command }' >> /etc/rc.local; fi"						  	
							end
						end

						# Initialize the LVM configuration for the data disk if required
						if host['data_disk']
						  override.vm.provision 'shell', inline: "data_vg_check=`vgdisplay | grep 'VG Name' | grep 'data' | wc -l`; if [ $data_vg_check == '0' ]; then parted -s /dev/sdb mklabel msdos && parted -s /dev/sdb unit mib mkpart primary 1 100% && parted -s /dev/sdb set 1 lvm on && pvcreate /dev/sdb1 && vgcreate data /dev/sdb1; fi"
						end

            # Write out the /etc/hosts file
            override.vm.provision 'shell', inline: "sudo cat << EOF > /etc/hosts\n%s\nEOF" %  generate_hosts_file(provider, profile, $hosts)

            override.vm.provision 'ansible' do |ansible|
              #ansible.inventory_path = '.vagrant/provisioners/ansible/inventory/custom_ansible_inventory'
              ansible.playbook = host['ansible_playbook']
              ansible.groups = ansible_groups
              ansible.extra_vars = ansible_vars
            end

          end
        end

      end
    end
  end

  # ------------------------------------------------------------------------------------
  # VMware Configuration
  # ------------------------------------------------------------------------------------
  if provider == 'vmware'

    puts "Using the '%s' provider..." % provider

    config.vm.provider 'vmware_desktop' do |vmware_desktop|
      vmware_desktop.gui = true
    end

    profile['hosts'].each do |hostName|

      if $hosts.include?(hostName)

        host = $hosts[hostName]

        config.vm.define host['name'] do |host_vm|
          host_vm.vm.provider :vmware_desktop do |vmware_desktop, override|

            # NOTE: These boxes must have been added to Vagrant before executing this project.
            if host['type'] == 'centos77'
	            override.vm.box = 'devops/centos77'
	          end
            if host['type'] == 'centos80'
	            override.vm.box = 'devops/centos80'
	          end          
      			if host['type'] == 'ubuntu1804'
	      			override.vm.box = 'devops/ubuntu1804'
		      	end

            # Create the data disk if required and associate it with the VM
		      	if host['data_disk']

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

              vm_folder = ".vagrant/machines/#{ host['name'] }/vmware_desktop"

              if File.exists?(vm_folder)
                disk_file = vm_folder + '/data-disk002.vmdk'

                unless File.exists?( disk_file )
                     `#{vdiskmanager} -c -s #{ host['data_disk'] }MB -a lsilogic -t 0 #{disk_file}`
                end

                vmware_desktop.vmx['scsi0:1.filename'] = '../data-disk002.vmdk'
                vmware_desktop.vmx['scsi0:1.present']  = 'TRUE'
                vmware_desktop.vmx['scsi0:1.redo']     = ''
              end
		      	end

            override.vm.synced_folder '.', '/vagrant', disabled: true

            # Perform the VMware Fusion specific initialisation
            vmware_desktop.gui = true
            vmware_desktop.vmx['numvcpus'] = host['cpus']
            vmware_desktop.vmx['memsize'] = host['memory']
            vmware_desktop.vmx['ethernet0.connectionType'] = 'nat'
            vmware_desktop.vmx['ethernet0.virtualDev'] = 'vmxnet3'
            vmware_desktop.vmx['ethernet0.vnet'] = 'vmnet8'
            vmware_desktop.vmx['guestinfo.metadata.encoding'] = 'base64'
            vmware_desktop.vmx['guestinfo.metadata'] = Base64.encode64(generate_guest_info_meta_data(host['name'], host['hostname'], host['ip'], host['gateway'], host['dns_server'], host['dns_search'])).gsub(/\n/, '')

						# Initialize the LVM configuration for the data disk if required
						if host['data_disk']
						  override.vm.provision 'shell', inline: "data_vg_check=`vgdisplay | grep 'VG Name' | grep 'data' | wc -l`; if [ $data_vg_check == '0' ]; then parted -s /dev/sdb mklabel msdos && parted -s /dev/sdb unit mib mkpart primary 1 100% && parted -s /dev/sdb set 1 lvm on && pvcreate /dev/sdb1 && vgcreate data /dev/sdb1; fi"
						end

            # Write out the /etc/hosts file
            override.vm.provision 'shell', inline: "sudo cat << EOF > /etc/hosts\n%s\nEOF" %  generate_hosts_file(provider, profile, $hosts)

            override.vm.provision 'ansible' do |ansible|
              #ansible.inventory_path = '.vagrant/provisioners/ansible/inventory/custom_ansible_inventory'
              ansible.playbook = host['ansible_playbook']
              ansible.groups = ansible_groups
              ansible.extra_vars = ansible_vars
            end

          end
        end
      end
    end
  end
  
  # ------------------------------------------------------------------------------------
  # Hyper-V Configuration
  # ------------------------------------------------------------------------------------
  if provider == "hyperv"

    puts "Using the '%s' provider..." % provider

    profile['hosts'].each do |hostName|

      if $hosts.include?(hostName)

        host = $hosts[hostName]

        puts "Provisioning host: %s" % host['name']

        config.vm.define host['name'] do |host_vm|
        
          host_vm.trigger.after :up do |trigger|
            trigger.info = 'Configuring the VM network...'
            trigger.run_remote = {inline: "/usr/bin/configure-network --interface eth0 --ip #{host['ip']} --hostname #{host['hostname']} --gateway #{host['gateway']} --dnsservers #{host['dns_server']} --dnssearch #{host['dns_search']}"}
          end
       
          host_vm.vm.provider :hyperv do |hyperv, override|

					  hyperv.cpus = host['cpus']
					  hyperv.memory = host['memory']
						hyperv.maxmemory = host['memory']
					  hyperv.vmname = host['hostname']

            # NOTE: These boxes must have been added to Vagrant before executing this project.
            if host['type'] == 'centos77'
	            override.vm.box = 'devops/centos77'
	          end
            if host['type'] == 'centos80'
	            override.vm.box = 'devops/centos80'
	          end          
      			if host['type'] == 'ubuntu1804'
	      			override.vm.box = 'devops/ubuntu1804'
		      	end

            override.vm.synced_folder '.', '/vagrant', disabled: true

            override.vm.network 'private_network', bridge: 'Vagrant Switch'

			      # Ensure that the /etc/rc.local file exists
			      #override.vm.provision 'shell', inline: "if [ ! -f /etc/rc.local ]; then echo -e '#!/bin/sh -e' > /etc/rc.local && chmod 0755 /etc/rc.local; fi"

            # Add the routes for the additional networks to the private network interface and persist them in /etc/rc.local
            #if host['private_networks']
						#	host['private_networks'].split(/\s*,\s*/).each do |private_network|
						#	  static_route_command = "ip route replace %s dev eth1 src %s" % [private_network, host['ip']]
						#								  
						#  	override.vm.provision 'shell', inline: static_route_command
						#  	override.vm.provision 'shell', inline: "static_route_command_check=`cat /etc/rc.local | grep '#{ static_route_command }' | wc -l`; if [ $static_route_command_check == '0' ]; then echo -e '\n#{ static_route_command }' >> /etc/rc.local; fi"						  	
						#	end
						#end

						# Initialize the LVM configuration for the data disk if required
						#if host['data_disk']
						#  override.vm.provision 'shell', inline: "data_vg_check=`vgdisplay | grep 'VG Name' | grep 'data' | wc -l`; if [ $data_vg_check == '0' ]; then parted -s /dev/sdb mklabel msdos && parted -s /dev/sdb unit mib mkpart primary 1 100% && parted -s /dev/sdb set 1 lvm on && pvcreate /dev/sdb1 && vgcreate data /dev/sdb1; fi"
						#end

            # Write out the /etc/hosts file
            override.vm.provision 'shell', inline: "sudo cat << EOF > /etc/hosts\n%s\nEOF" %  generate_hosts_file(provider, profile, $hosts)

            override.vm.provision 'ansible' do |ansible|
              #ansible.inventory_path = '.vagrant/provisioners/ansible/inventory/custom_ansible_inventory'
              ansible.playbook = host['ansible_playbook']
              ansible.groups = ansible_groups
              ansible.extra_vars = ansible_vars
            end

          end
        end

      end
    end
  end  

end

