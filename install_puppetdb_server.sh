#!/bin/bash

yum install -y https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum install -y puppet-agent ntp
echo "[main]" >> /etc/puppetlabs/puppet/puppet.conf
echo "server = test-tools-puppet-apatsev1.russianpost.ru" >> /etc/puppetlabs/puppet/puppet.conf
echo "ca_server = test-tools-puppet-apatsev1.russianpost.ru" >> /etc/puppetlabs/puppet/puppet.conf
