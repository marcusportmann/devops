
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
  default = "4827dce1c58560d3ca470a5053e8d86ba059cbb77cfca3b5f6a5863d2aac5b84"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha256"
}

variable "iso_url" {
  type    = string
  default = "http://download.rockylinux.org/pub/rocky/8/isos/x86_64/Rocky-8.7-x86_64-dvd1.iso"
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

source "hyperv-iso" "rocky-8-hyperv" {
  boot_command     = ["<tab> net.ifnames=0 biosdevname=0 text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rocky-8.cfg<enter><wait>"]
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
  output_directory = "${var.build_directory}/hyperv/rocky-8/"
  shutdown_command = "/sbin/halt -p"
  ssh_password     = "${var.ssh_password}"
  ssh_timeout      = "4h"
  ssh_username     = "${var.ssh_username}"
  switch_name      = "Default Switch"
  temp_path        = "temp"
  vm_name          = "rocky-8"
}

source "virtualbox-iso" "rocky-8-virtualbox" {
  boot_command           = ["<tab> net.ifnames=0 biosdevname=0 text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rocky-8.cfg<enter><wait>"]
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
  output_directory       = "${var.build_directory}/virtualbox/rocky-8/"
  shutdown_command       = "/sbin/halt -p"
  ssh_password           = "${var.ssh_password}"
  ssh_timeout            = "${var.ssh_timeout}"
  ssh_username           = "${var.ssh_username}"
}

source "vmware-iso" "rocky-8-vmware" {
  boot_command     = ["<tab> net.ifnames=0 biosdevname=0 text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rocky-8.cfg<enter><wait>"]
  cpus             = "2"
  memory           = "1024"
  disk_size        = "51200"
  disk_type_id     = "0"
  guest_os_type    = "centos-64"
  headless         = "${var.headless}"
  http_directory   = "http"
  iso_checksum     = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  output_directory = "${var.build_directory}/vmware/rocky-8/"
  shutdown_command = "/sbin/halt -p"
  ssh_password     = "${var.ssh_password}"
  ssh_timeout      = "${var.ssh_timeout}"
  ssh_username     = "${var.ssh_username}"
  vm_name          = "rocky-8"
  vmdk_name        = "rocky-8"
  vmx_data = {
    "disk.EnableUUID"          = "TRUE"
    "ethernet0.connectiontype" = "nat"
    "rtc.diffFromUTC"          = "0"
  }
}

build {
  sources = ["source.hyperv-iso.rocky-8-hyperv", "source.virtualbox-iso.rocky-8-virtualbox", "source.vmware-iso.rocky-8-vmware"]

  provisioner "file" {
    destination = "/tmp/configure-network"
    source      = "files/rocky-8/configure-network"
  }

  provisioner "file" {
    destination = "/tmp/create-swap-file"
    source      = "files/rocky-8/create-swap-file"
  }

  provisioner "file" {
    destination = "/tmp/resize-root-partition"
    source      = "files/rocky-8/resize-root-partition"
  }

  provisioner "shell" {
    inline = ["sudo cp /tmp/configure-network /usr/bin/", "sudo chmod a+x /usr/bin/configure-network", "sudo cp /tmp/create-swap-file /usr/bin/", "sudo chmod a+x /usr/bin/create-swap-file", "sudo cp /tmp/resize-root-partition /usr/bin/", "sudo chmod a+x /usr/bin/resize-root-partition"]
  }

  provisioner "shell" {
    execute_command   = "{{ .Vars }} sh {{ .Path }}"
    expect_disconnect = true
    scripts           = ["scripts/rocky-8/base.sh", "scripts/rocky-8/vmtools.sh", "scripts/rocky-8/cloud-init.sh", "scripts/rocky-8/vagrant.sh", "scripts/rocky-8/cleanup.sh", "scripts/rocky-8/zerodisk.sh"]
  }

  post-processor "vagrant" {
    keep_input_artifact = true
    output              = "${var.build_directory}/boxes/rocky-8-{{ .Provider }}.box"
  }
}
