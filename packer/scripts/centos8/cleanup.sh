# Remove the machine specified configuration files
> /etc/machine-id
rm -rf /etc/sysconfig/rhn/systemid

# Clear log files
> /var/log/audit/audit.log
rm -rf /var/log/anaconda
rm -rf /var/log/ntpstats
rm -rf /var/log/ppp
rm -rf /var/log/tuned
rm -f /var/log/*
> /var/log/lastlog

# Other cleanup
rm -f /etc/ssh/ssh_host_*
rm -f /var/lib/NetworkManager/*
rm -rf /tmp/*

# Clean yum packages
yum -y clean all

