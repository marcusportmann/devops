# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'
require 'yaml'
require 'getoptlong'


def generate_guest_info_meta_data(name, hostname, dhcp, ip, gateway, dns_server, dns_search)

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
      namehosts:
        search: [#{dns_search}]
        addresses: [#{dns_server}]
"""

end


def generate_hosts_file(provider, profile, hosts)

  hosts = """127.0.0.1 localhost
::1 localhost

"""

  profile['hosts'].each do |hostName|

    if hosts.include?(hostName)

      host = hosts[hostName]

      if ((not host[provider]['ip'].nil?) && (not host[provider]['ip'].empty?) && (not host[provider]['hostname'].nil?) && (not host[provider]['hostname'].empty?))

        ip = host[provider]['ip']

        if not (ip.index "/").nil?
          ip = ip[0, (ip.index "/")]
        end

        hosts += "%-15.15s" % ip
        hosts += " "
        hosts += host[provider]['hostname']

        if ((not host[provider]['fqdn'].nil?) && (not host[provider]['fqdn'].empty?))
          hosts += " "
          hosts += host[provider]['fqdn']
        end

        hosts += "\n"

      end

    end

  end

  hosts

end




profileName = ''
provider = ''

Vagrant.require_version ">= 2.2.0"

VAGRANTFILE_API_VERSION = '2'
VAGRANT_DEFAULT_PROVIDER = 'virtualbox'

if not ENV['VAGRANT_PROVIDER'].nil?
  provider = ENV['VAGRANT_PROVIDER']
end

ARGV.each_with_index do |argument, index|

  if argument and argument.include? '--provider' and argument.include? '=' and (argument.split('=')[0] == "--provider")
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

CONFIG_FILE = 'config.yml'
CONFIG_FILE_PATH = File.join(File.dirname(__FILE__), CONFIG_FILE)

if File.exist?(CONFIG_FILE_PATH)
  puts "Using the configuration file: %s" % CONFIG_FILE_PATH
else
  raise "Failed to find the configuration file (%s)" % CONFIG_FILE_PATH
end

config_file = YAML.load_file(CONFIG_FILE_PATH)
hosts_config = config_file['hosts']

hosts = Hash.new

hosts_config.each do |host_config|
  hosts[host_config['name']] = host_config
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
  raise "Failed to find the profile %s in the config.yml file" % profileName
else
  puts "Executing with profile: %s" % profileName
end


# ------------------------------------------------------------------------------------
# Build the Ansible groups using the enabled hosts
# ------------------------------------------------------------------------------------
ansible_groups = Hash.new

profile['hosts'].each do |hostName|

  host = hosts[hostName]

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

  ansible_vars["hosts"] = Hash.new
  ansible_vars["host_names_by_group"] = Hash.new

  profile['hosts'].each do |hostName|

    host = hosts[hostName]

    host_var = Hash.new

    if ((not host[provider]['hostname'].nil?) && (not host[provider]['hostname'].empty?))
      host_var['hostname'] = host[provider]['hostname']
    end
    if ((not host[provider]['fqdn'].nil?) && (not host[provider]['fqdn'].empty?))
      host_var['fqdn'] = host[provider]['fqdn']
    end
    if ((not host[provider]['ip'].nil?) && (not host[provider]['ip'].empty?))
      host_var['ip'] = host[provider]['ip']
    end
    if ((not host[provider]['network'].nil?) && (not host[provider]['network'].empty?))
      host_var['network'] = host[provider]['network']
    end

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

    if hosts.include?(hostName)

      host = hosts[hostName]

      file.puts "%s ansible_host=%s\n" % [hostName, host[provider]['ip'].split("/").first]

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



Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Always use Vagrant's insecure key
  config.ssh.username = "cloud-user"
  config.ssh.password = "cloud"
  config.ssh.insert_key = true

  config.vm.synced_folder ".", "/vagrant", disabled: true

  # ------------------------------------------------------------------------------------
  # Virtualbox Configuration
  # ------------------------------------------------------------------------------------
  if provider == "virtualbox"

    puts "Using the '%s' provider..." % provider

    config.vm.provider "virtualbox" do |virtualbox|
      virtualbox.gui = false
    end

    profile['hosts'].each do |hostName|

      if hosts.include?(hostName)

        host = hosts[hostName]

        puts "Provisioning host: %s" % host['name']

        config.vm.define host['name'] do |host_vm|
          host_vm.vm.provider :virtualbox do |virtualbox, override|

            # NOTE: This box must have been added to Vagrant before executing this project.
            #
            #       Clone the mmp-packer Git repository and build and add the Vagrant boxes.
            #
            if host['type'] == "centos"
	            override.vm.box = "mmp/centos77"
	        end
			if host['type'] == "ubuntu"
				override.vm.box = "mmp/ubuntu1804"
			end

            override.vm.synced_folder '.', '/vagrant', disabled: true

            override.vm.hostname = host['virtualbox']['fqdn']

            override.vm.network "private_network", ip: host['virtualbox']['ip']

            virtualbox.customize ["modifyvm", :id, "--memory", host['virtualbox']['ram'], "--cpus", host['virtualbox']['cpus'], "--cableconnected1", "on", "--cableconnected2", "on"]

            # Write out the /etc/hosts file
            override.vm.provision "shell", inline: "sudo cat << EOF > /etc/hosts\n%s\nEOF" %  generate_hosts_file(provider, profile, hosts)

            override.vm.provision "ansible" do |ansible|
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
  # VMware Fusion Configuration
  # ------------------------------------------------------------------------------------
  if provider == "vmware_fusion"

    puts "Using the '%s' provider..." % provider

    config.vm.provider "vmware_fusion" do |vmware_fusion|
      vmware_fusion.gui = true
    end

    profile['hosts'].each do |hostName|

      if hosts.include?(hostName)

        host = hosts[hostName]

        config.vm.define host['name'] do |host_vm|
          host_vm.vm.provider :vmware_fusion do |vmware_fusion, override|

            # NOTE: This box must have been added to Vagrant before executing this project.
            #
            #       Clone the mmp-packer Git repository and build and add the Vagrant boxes.
            #
            if host['type'] == "centos"
	            override.vm.box = "mmp/centos77"
	        end
			if host['type'] == "ubuntu"
				override.vm.box = "mmp/ubuntu1804"
			end

            override.vm.synced_folder '.', '/vagrant', disabled: true

            # Perform the VMware Fusion specific initialisation
            vmware_fusion.gui = true
            vmware_fusion.vmx["numvcpus"] = host['vmware_fusion']['cpus']
            vmware_fusion.vmx["memsize"] = host['vmware_fusion']['ram']
            vmware_fusion.vmx["ethernet0.connectionType"] = "nat"
            vmware_fusion.vmx["ethernet0.virtualDev"] = "vmxnet3"
            vmware_fusion.vmx["ethernet0.vnet"] = "vmnet8"
            vmware_fusion.vmx["guestinfo.metadata.encoding"] = "base64"
            vmware_fusion.vmx["guestinfo.metadata"] = Base64.encode64(generate_guest_info_meta_data(host['name'], host['vmware_fusion']['hostname'], host['vmware_fusion']['dhcp'], host['vmware_fusion']['ip'], host['vmware_fusion']['gateway'], host['vmware_fusion']['dns_server'], host['vmware_fusion']['dns_search'])).gsub(/\n/, '')

            # Write out the /etc/hosts file
            override.vm.provision "shell", inline: "sudo cat << EOF > /etc/hosts\n%s\nEOF" %  generate_hosts_file(provider, profile, hosts)

            override.vm.provision "ansible" do |ansible|
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

