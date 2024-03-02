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
  default = "d68f92f41ab008f94bd89ec4e2403920538c19a7b35b731e770ce24d66be129a"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha256"
}

variable "iso_url" {
  type    = string
  default = "https://ftp.dimensiondata.com/linux/distributions/centos/7.9.2009/isos/x86_64/CentOS-7-x86_64-Minimal-2207-02.iso"
}

variable "ssh_password" {
  type    = string
  default = "root"
}

variable "ssh_timeout" {
  type    = string
  default = "1200s"
}

variable "ssh_username" {
  type    = string
  default = "root"
}

source "hyperv-iso" "centos-7-hyperv" {
  boot_command     = ["<tab> net.ifnames=0 biosdevname=0 text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos-7.cfg<enter><wait>"]
  cpus             = "2"
  memory           = "1024"
  disk_block_size  = "1"
  disk_size        = "51200"
  generation       = 1
  headless         = "${var.headless}"
  http_directory   = "http"
  iso_checksum     = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  keep_registered  = "false"
  output_directory = "${var.build_directory}/hyperv/centos-7/"
  shutdown_command = "/sbin/halt -p"
  ssh_password     = "${var.ssh_password}"
  ssh_timeout      = "4h"
  ssh_username     = "${var.ssh_username}"
  switch_name      = "Default Switch"
  temp_path        = "temp"
  vm_name          = "centos-7"
}

source "virtualbox-iso" "centos-7-virtualbox" {
  boot_command           = ["<tab> net.ifnames=0 biosdevname=0 text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos-7.cfg<enter><wait>"]
  cpus                   = "2"
  memory                 = "1024"
  disk_size              = "51200"
  guest_additions_path   = "VBoxGuestAdditions_{{ .Version }}.iso"
  guest_additions_sha256 = "c5e46533a6ff8df177ed5c9098624f6cec46ca392bab16de2017195580088670"
  guest_os_type          = "RedHat_64"
  headless               = "${var.headless}"
  http_directory         = "http"
  iso_checksum           = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url                = "${var.iso_url}"
  output_directory       = "${var.build_directory}/virtualbox/centos-7/"
  shutdown_command       = "/sbin/halt -p"
  ssh_password           = "${var.ssh_password}"
  ssh_timeout            = "${var.ssh_timeout}"
  ssh_username           = "${var.ssh_username}"
  vboxmanage             = [["modifyvm", "{{ .Name }}", "--memory", "1024"], ["modifyvm", "{{ .Name }}", "--cpus", "1"]]
}

source "vmware-iso" "centos-7-vmware" {
  boot_command     = ["<tab> net.ifnames=0 biosdevname=0 text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos-7.cfg<enter><wait>"]
  cpus             = "2"
  memory           = "1024"
  disk_size        = "51200"
  disk_type_id     = "0"
  guest_os_type    = "centos-64"
  headless         = "${var.headless}"
  http_directory   = "http"
  iso_checksum     = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  output_directory = "${var.build_directory}/vmware/centos-7/"
  shutdown_command = "/sbin/halt -p"
  ssh_password     = "${var.ssh_password}"
  ssh_timeout      = "${var.ssh_timeout}"
  ssh_username     = "${var.ssh_username}"
  vm_name          = "centos-7"
  vmdk_name        = "centos-7"
  vmx_data = {
    "disk.EnableUUID"          = "TRUE"
    "ethernet0.connectiontype" = "nat"
    "rtc.diffFromUTC"          = "0"
  }
}

build {
  sources = ["source.hyperv-iso.centos-7-hyperv", "source.virtualbox-iso.centos-7-virtualbox", "source.vmware-iso.centos-7-vmware"]

  provisioner "file" {
    destination = "/tmp/configure-network"
    source      = "files/centos-7/configure-network"
  }

  provisioner "file" {
    destination = "/tmp/create-swap-file"
    source      = "files/centos-7/create-swap-file"
  }

  provisioner "file" {
    destination = "/tmp/resize-root-partition"
    source      = "files/centos-7/resize-root-partition"
  }

  provisioner "shell" {
    inline = ["sudo cp /tmp/configure-network /usr/bin/", "sudo chmod a+x /usr/bin/configure-network", "sudo cp /tmp/create-swap-file /usr/bin/", "sudo chmod a+x /usr/bin/create-swap-file", "sudo cp /tmp/resize-root-partition /usr/bin/", "sudo chmod a+x /usr/bin/resize-root-partition"]
  }

  provisioner "shell" {
    execute_command   = "{{ .Vars }} sh {{ .Path }}"
    expect_disconnect = true
    scripts           = ["scripts/centos-7/base.sh", "scripts/centos-7/vmtools.sh", "scripts/centos-7/cloud-init.sh", "scripts/centos-7/vagrant.sh", "scripts/centos-7/cleanup.sh", "scripts/centos-7/zerodisk.sh"]
  }

  post-processor "vagrant" {
    keep_input_artifact = true
    output              = "${var.build_directory}/boxes/centos-7-{{ .Provider }}.box"
  }
}
