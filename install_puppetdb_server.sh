#!/bin/bash

read -p "Enter your domain: " domain
read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

read -p "Enter FQDN Puppet Master: " fqdn_puppet_master
read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

if [[ $fqdn_puppet_master = *$domain* ]]; then
  echo "$fqdn_puppet_master contains $domain"
else
  echo "$fqdn_puppet_master does not contains $domain"
  exit 1
fi

#Stop iptables.service
#systemctl stop iptables.service
#Disable iptables.service
#systemctl disable iptables.service

#Disable Selinux
setenforce 0
sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config

while true ; do
  #cat < /dev/null > /dev/tcp/$fqdn_puppet_master/8140
  timeout 1 bash -c "cat < /dev/null > /dev/tcp/$fqdn_puppet_master/8140"
  if [ "$?" -ne 0 ]; then
    echo "Connection to $fqdn_puppet_master on port 8140 failed"
    echo "Wait 10 second"
  else
    break
  fi
  sleep 10
done

yum install -y https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum install -y puppet-agent ntp
echo "[main]" > /etc/puppetlabs/puppet/puppet.conf
echo "server = $fqdn_puppet_master" >> /etc/puppetlabs/puppet/puppet.conf
echo "ca_server = $fqdn_puppet_master" >> /etc/puppetlabs/puppet/puppet.conf

/opt/puppetlabs/bin/puppet agent --test
/opt/puppetlabs/bin/puppet agent --test
