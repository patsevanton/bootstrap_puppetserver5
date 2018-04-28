#!/bin/bash

read -p "Enter FQDN Puppet Master: " fqdn_puppet_master
read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

yum install -y https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum install -y puppet-agent ntp
echo "[main]" >> /etc/puppetlabs/puppet/puppet.conf
echo "server = $fqdn_puppet_master" >> /etc/puppetlabs/puppet/puppet.conf
echo "ca_server = $fqdn_puppet_master" >> /etc/puppetlabs/puppet/puppet.conf
