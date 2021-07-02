#!/bin/sh

# xattr -d com.apple.quarantine build.sh

programname=$0

function usage {
    echo "Usage: $programname -p provider -o operating_system"
    echo "Options:"
    echo "  -h                   Print this message and exit."
    echo "  -p PROVIDER          One of the following Vagrant providers: virtualbox, vmware_desktop, vsphere, hyperv."
    echo "  -o OPERATING_SYSTEM  One of the following operating systems: centos-7, centos-8, ubuntu-2004."
}

function build_image {
  local provider=$1
  local operating_system=$2

  echo "Building $operating_system for Vagrant provider $provider..."

  if [[ "$provider" == "virtualbox" ]]; then
    rm -rf build/boxes/${operating_system}-virtualbox.box
    rm -rf build/virtualbox/${operating_system}

    vagrant box remove --force --provider virtualbox --all devops/${operating_system}

    packer build -only=${operating_system}-virtualbox ${operating_system}.json

    vagrant box add --force --name devops/${operating_system} build/boxes/${operating_system}-virtualbox.box
  fi

  if [[ "$provider" == "vmware_desktop" ]]; then
    rm -rf build/boxes/${operating_system}-vmware.box
    rm -rf build/vmware/${operating_system}
    rm -rf build/ovf/${operating_system}
    rm -rf build/ova/${operating_system}

    vagrant box remove --force --provider vmware_desktop --all devops/${operating_system}

    packer build -only=${operating_system}-vmware ${operating_system}.json

    vagrant box add --force --name devops/${operating_system} build/boxes/${operating_system}-vmware.box

  	mkdir -p build/ova/${operating_system}

	  /Applications/VMware\ Fusion.app/Contents/Library/VMware\ OVF\ Tool/ovftool --acceptAllEulas -n=${operating_system} build/vmware/${operating_system}/${operating_system}.vmx build/ova/${operating_system}/${operating_system}.ova
  fi

  if [[ "$provider" == "vsphere" ]]; then
    vagrant box remove --force --provider vsphere --all devops/${operating_system};

 	  vagrant box add --force --provider vsphere --name devops/${operating_system} build/boxes/${operating_system}-vsphere.box
  fi

  if [[ "$provider" == "hyperv" ]]; then
    rm -rf build/boxes/${operating_system}-hyperv.box
    rm -rf build/hyperv/${operating_system}

    vagrant box remove --force --provider hyperv --all devops/${operating_system}

    packer build -only=${operating_system}-hyperv ${operating_system}.json

    vagrant box add --force --name devops/${operating_system} build/boxes/${operating_system}-hyperv.box
  fi
}

if [ "$#" -ne 4 ]; then
    usage
    exit 1
fi

while getopts h:p:o: option
do
case "${option}" in
    h)
        usage
        exit 1
        ;;
    p)
        if [[ ${OPTARG} =~ ^virtualbox|vmware_desktop|vsphere|hyperv$ ]]
        then
            provider=${OPTARG}
        else
            usage
            exit 1
        fi
        ;;
    o)
        if [[ ${OPTARG} =~ ^centos-7|centos-8|ubuntu-2004$ ]]
        then
            operating_system=${OPTARG}
        else
            usage
            exit 1
        fi
        ;;

    \? )
        echo "Invalid Option: -$OPTARG" 1>&2
        exit 1
        ;;
esac
done

build_image $provider $operating_system