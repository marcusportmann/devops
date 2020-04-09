#!/bin/sh

# xattr -d com.apple.quarantine devops.sh

programname=$0

function usage {
    echo "Usage: $programname [options] <action> <profile> [host]"
    echo ""
    echo "Where <action> is one of up, provision, halt or destroy and <profile> is the name of a profile in the config.yml file."
    echo ""
    echo "Options:"
    echo "  -h           Print this message and exit."
    echo "  -p PROVIDER  One of the following providers: virtualbox, vmware_desktop, vsphere, hyperv, esxi."
    echo "               If not specified the provider will default to vmware."
    echo ""
}

action=""
profile=""
host=""
provider="vmware"

if [ "$#" -lt 2 ]; then
    usage
    exit 1
fi

while getopts ":h:p:" opt; do
    case ${opt} in
        h )
            usage
            exit 0
            ;;
        p)
            if [[ ${OPTARG} =~ ^virtualbox|vmware_desktop|vsphere|hyperv|esxi$ ]]
            then
                provider=${OPTARG}
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
shift $((OPTIND -1))

subcommand=$1; shift

case "$subcommand" in
  up)
    profile=$1; shift
    host=$1; shift
    VAGRANT_DEFAULT_PROVIDER=$provider vagrant --provider=$provider --profile=$profile up --no-parallel --no-provision $host
    ;;
  provision)
    profile=$1; shift
    host=$1; shift
    VAGRANT_DEFAULT_PROVIDER=$provider vagrant --provider=$provider --profile=$profile provision $host
    ;;
  destroy)
    profile=$1; shift
    host=$1; shift
    VAGRANT_DEFAULT_PROVIDER=$provider vagrant --provider=$provider --profile=$profile destroy $host --force
    ;;
  halt)
    profile=$1; shift
    host=$1; shift
    VAGRANT_DEFAULT_PROVIDER=$provider vagrant --provider=$provider --profile=$profile halt $host --force
    ;;    
  *)
    echo "Invalid action: $subcommand\n"
    usage
    exit 1
    ;;

esac

















