
variable "atlas_name" {
  type = string
  default = ""
}

variable "atlas_username" {
  type = string
  default = ""
}

variable "build_directory" {
  type    = string
  default = "build"
}

variable "headless" {
  type    = string
  default = "false"
}

variable "iso_checksum" {
  type    = string
  default = "5035be37a7e9abbdc09f0d257f3e33416c1a0fb322ba860d42d74aa75c3468d4"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha256"
}

variable "iso_url" {
  type    = string
  default = "https://releases.ubuntu.com/20.04/ubuntu-20.04.5-live-server-amd64.iso"
}

variable "ssh_password" {
  type    = string
  default = "root"
}

variable "ssh_port" {
  type    = string
  default = "22"
}

variable "ssh_timeout" {
  type    = string
  default = "4h"
}

variable "ssh_username" {
  type    = string
  default = "root"
}

source "hyperv-iso" "ubuntu-2004-hyperv" {
  boot_command     = ["<enter><enter><f6><esc><wait> ", "autoinstall net.ifnames=0 biosdevname=0 ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/", "<enter>"]
  boot_wait        = "3s"
  cpus             = "1"
  disk_block_size  = "1"
  disk_size        = "51200"
  generation       = 1
  headless         = "${var.headless}"
  http_directory   = "http/ubuntu-2004-hyperv"
  iso_checksum     = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  keep_registered  = "false"
  memory           = "1024"
  output_directory = "${var.build_directory}/hyperv/ubuntu-2004/"
  shutdown_command = "shutdown -P now"
  ssh_password     = "${var.ssh_password}"
  ssh_port         = "${var.ssh_port}"
  ssh_timeout      = "4h"
  ssh_username     = "${var.ssh_username}"
  switch_name      = "Default Switch"
  temp_path        = "temp"
  vm_name          = "ubuntu-2004"
}

source "virtualbox-iso" "ubuntu-2004-virtualbox" {
  boot_command           = ["<enter><enter><f6><esc><wait> ", "autoinstall net.ifnames=0 biosdevname=0 ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/", "<enter>"]
  boot_wait              = "3s"
  cpus                   = "1"
  disk_size              = "51200"
  guest_additions_path   = "VBoxGuestAdditions_{{ .Version }}.iso"
  guest_additions_sha256 = "c5e46533a6ff8df177ed5c9098624f6cec46ca392bab16de2017195580088670"
  guest_os_type          = "Ubuntu_64"
  headless               = "${var.headless}"
  http_directory         = "http/ubuntu-2004"
  iso_checksum           = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url                = "${var.iso_url}"
  memory                 = "1024"
  output_directory       = "${var.build_directory}/virtualbox/ubuntu-2004/"
  shutdown_command       = "shutdown -P now"
  ssh_password           = "${var.ssh_password}"
  ssh_port               = "${var.ssh_port}"
  ssh_timeout            = "${var.ssh_timeout}"
  ssh_username           = "${var.ssh_username}"
  vm_name                = "ubuntu-2004"
}

source "vmware-iso" "ubuntu-2004-vmware" {
  boot_command     = ["<enter><enter><f6><esc><wait> ", "autoinstall net.ifnames=0 biosdevname=0 ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/", "<enter>"]
  boot_wait        = "3s"
  cpus             = "1"
  disk_size        = "51200"
  disk_type_id     = "0"
  guest_os_type    = "ubuntu-64"
  headless         = "${var.headless}"
  http_directory   = "http/ubuntu-2004"
  iso_checksum     = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  memory           = "1024"
  output_directory = "${var.build_directory}/vmware/ubuntu-2004/"
  shutdown_command = "shutdown -P now"
  ssh_password     = "${var.ssh_password}"
  ssh_port         = "${var.ssh_port}"
  ssh_timeout      = "${var.ssh_timeout}"
  ssh_username     = "${var.ssh_username}"
  vm_name          = "ubuntu-2004"
  vmdk_name        = "ubuntu-2004"
  vmx_data = {
    "disk.EnableUUID"          = "TRUE"
    "ethernet0.connectiontype" = "nat"
    "rtc.diffFromUTC"          = "0"
  }
}

build {
  sources = ["source.hyperv-iso.ubuntu-2004-hyperv", "source.virtualbox-iso.ubuntu-2004-virtualbox", "source.vmware-iso.ubuntu-2004-vmware"]

  provisioner "shell" {
    inline = [
      "echo set debconf to Noninteractive", 
      "echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections" ]
  }  

  provisioner "file" {
    destination = "/var/tmp/configure-network"
    source      = "files/ubuntu-2004/configure-network"
  }

  provisioner "file" {
    destination = "/var/tmp/resize-root-partition"
    source      = "files/ubuntu-2004/resize-root-partition"
  }

  provisioner "file" {
    destination = "/var/tmp/ssh-keygen.service"
    source      = "files/ubuntu-2004/ssh-keygen.service"
  }

  provisioner "shell" {
    execute_command   = "echo 'cloud' | {{ .Vars }} bash '{{ .Path }}'"
    expect_disconnect = true
    scripts           = ["scripts/ubuntu-2004/base.sh", "scripts/ubuntu-2004/vmtools.sh", "scripts/ubuntu-2004/cloud-init.sh", "scripts/ubuntu-2004/vagrant.sh", "scripts/ubuntu-2004/cleanup.sh", "scripts/ubuntu-2004/zerodisk.sh"]
  }

  post-processor "vagrant" {
    keep_input_artifact = true
    output              = "${var.build_directory}/boxes/ubuntu-2004-{{ .Provider }}.box"
  }
}
