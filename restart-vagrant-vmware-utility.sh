#!/bin/sh

# xattr -d com.apple.quarantine restart-vagrant-vmware-utility.sh

sudo launchctl unload -w /Library/LaunchDaemons/com.vagrant.vagrant-vmware-utility.plist
sudo launchctl load -w /Library/LaunchDaemons/com.vagrant.vagrant-vmware-utility.plist

