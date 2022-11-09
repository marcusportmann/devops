#!/bin/sh
sudo route delete -net 192.168.184 -interface bridge101
sudo route add -net 192.168.184 -interface bridge101
