# Remove the machine specified configuration files
> /etc/machine-id

# Clear log files
> /var/log/auth.log
rm -rf /var/log/ntpstats
rm -f /var/log/*

# Other cleanup
rm -f /etc/resolv.conf
rm -f /etc/ssh/ssh_host_*
rm -rf /tmp/*

