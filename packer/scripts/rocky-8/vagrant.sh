# Create the vagrant user
groupadd --gid 301 vagrant
useradd --gid 301 --uid 301 --create-home --home-dir=/home/vagrant vagrant

# Configure SSH for the vagrant user
mkdir -m 700 /home/vagrant/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" > /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# Set the password for the cloud user
echo "vagrant" | passwd --stdin vagrant

# Enable sudo for the vagrant user
echo 'vagrant             ALL=(ALL)   NOPASSWD: ALL' >> /etc/sudoers.d/vagrant
echo 'Defaults:vagrant    env_keep += SSH_AUTH_SOCK' >> /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant
sed -i 's/^.*requiretty/#Defaults requiretty/' /etc/sudoers
