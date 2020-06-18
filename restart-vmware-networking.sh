#!/bin/sh
rm -f /opt/vagrant-vmware-desktop/settings/nat.json
killall vagrant-vmware-utility
/Applications/VMware\ Fusion.app/Contents/Library/vmnet-cli --configure
/Applications/VMware\ Fusion.app/Contents/Library/vmnet-cli --stop
rm -f /Library/Preferences/VMware\ Fusion/vmnet1/*.bak
rm -f /Library/Preferences/VMware\ Fusion/vmnet8/*.bak
rm -f /Library/Preferences/VMware\ Fusion/networking.bak*
/Applications/VMware\ Fusion.app/Contents/Library/vmnet-cli --start
