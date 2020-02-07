#!/bin/sh

programname=$0

function usage {
    echo "Usage: $programname -p provider -o operating_system"
    echo "Options:"
    echo "  -h                   Print this message and exit."
    echo "  -p PROVIDER          One of the following providers: virtualbox, vmware, vsphere."
    echo "  -o OPERATING_SYSTEM  One of the following operating systems: centos77, centos80, ubuntu1804."
}

function build_image {
  local provider=$1
  local operating_system=$2

  echo "Building $operating_system using provider $provider..."

  if [[ "$provider" == "virtualbox" ]]; then
    rm -rf build/boxes/${operating_system}-virtualbox.box
    rm -rf build/virtualbox/${operating_system}

    vagrant box remove --force --provider virtualbox --all devops/${operating_system};
    
    packer build -only=${operating_system}-virtualbox ${operating_system}.json

	  vagrant box add --force --name devops/${operating_system} build/boxes/${operating_system}-virtualbox.box    
  fi

  if [[ "$provider" == "vmware" ]]; then
    rm -rf build/boxes/${operating_system}-vmware.box
    rm -rf build/vmware/${operating_system}
    rm -rf build/ovf/${operating_system}
    rm -rf build/ova/${operating_system}

    vagrant box remove --force --provider vmware --all devops/${operating_system};

    packer build -only=${operating_system}-vmware ${operating_system}.json

	  vagrant box add --force --name devops/${operating_system} build/boxes/${operating_system}-vmware.box

	  mkdir -p build/ovf/${operating_system}

	  /Applications/VMware\ Fusion.app/Contents/Library/VMware\ OVF\ Tool/ovftool --acceptAllEulas -n=${operating_system} build/vmware/${operating_system}/${operating_system}.vmx build/ovf/${operating_system}/${operating_system}.ovf

	  mkdir -p build/ova/${operating_system}

	  /Applications/VMware\ Fusion.app/Contents/Library/VMware\ OVF\ Tool/ovftool --acceptAllEulas -n=${operating_system} build/vmware/${operating_system}/${operating_system}.vmx build/ova/${operating_system}/${operating_system}.ova
  fi

  if [[ "$provider" == "vsphere" ]]; then
    vagrant box remove --force --provider vsphere --all devops/${operating_system};

 	  vagrant box add --force --provider vsphere --name devops/${operating_system} build/boxes/${operating_system}-vsphere.box
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
        if [[ ${OPTARG} =~ ^virtualbox|vmware|vsphere$ ]]
        then
            provider=${OPTARG}
        else
            usage
            exit 1
        fi
        ;;
    o)
        if [[ ${OPTARG} =~ ^centos77|centos80|ubuntu1804$ ]]
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