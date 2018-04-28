#!/bin/bash

read -p "Enter FQDN Puppet Master: " fqdn_puppet_master
read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

</dev/tcp/$fqdn_puppet_master/8140
if [ "$?" -ne 0 ]; then
  echo "Connection to $fqdn_puppet_master on port 8140 failed"
  exit 1
fi

yum install -y https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum install -y puppet-agent ntp
echo "[main]" > /etc/puppetlabs/puppet/puppet.conf
echo "server = $fqdn_puppet_master" >> /etc/puppetlabs/puppet/puppet.conf
echo "ca_server = $fqdn_puppet_master" >> /etc/puppetlabs/puppet/puppet.conf
