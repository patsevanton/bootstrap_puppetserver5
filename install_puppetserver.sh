#!/bin/bash

read -p "Enter your domain: " your_domain
read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

#read -p "Enter your Puppet Master host: " puppet_master_host
#read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

read -p "Enter your PuppetDB host: " puppetdb_host
read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

#Disable Selinux
setenforce 0
sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config

#Stop firewalld
#systemctl stop firewalld
#Disable firewalld
#systemctl disable firewalld

#Install repo
yum install -y https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
#Install puppetserver
yum install -y puppetserver ntp

#Get total memory using free
mem=$(free -m|awk '/^Mem:/{print $2}')
#Get memory/2
mem_devide_2="$(( $mem / 2 ))m"
#Get memory/4
mem_devide_4=$(( $mem / 4 ))

sed -i "s/-Xms2g/-Xms$mem_devide_2/" /etc/sysconfig/puppetserver
sed -i "s/-Xmx2g/-Xmx$mem_devide_2/" /etc/sysconfig/puppetserver
sed -i "s/MaxPermSize=256/MaxPermSize=$mem_devide_4/" /etc/sysconfig/puppetserver

systemctl enable puppetserver.service
systemctl start puppetserver.service

/opt/puppetlabs/bin/puppet module install puppetlabs-puppetdb
echo "*.$your_domain" > /etc/puppetlabs/puppet/autosign.conf
cp site.pp /etc/puppetlabs/code/environments/production/manifests/site.pp
sed -i "s/puppet.my.domain/$HOSTNAME/" /etc/puppetlabs/code/environments/production/manifests/site.pp
sed -i "s/puppetdb.my.domain/$puppetdb_host/" /etc/puppetlabs/code/environments/production/manifests/site.pp

#Added $HOSTNAME to /etc/puppetlabs/puppet/puppet.conf
echo "[main]" > /etc/puppetlabs/puppet/puppet.conf
echo "server = $HOSTNAME" >> /etc/puppetlabs/puppet/puppet.conf
echo "ca_server = $HOSTNAME" >> /etc/puppetlabs/puppet/puppet.conf
