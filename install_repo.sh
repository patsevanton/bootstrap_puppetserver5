#!/bin/bash

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
mem_devide_2=$(( $mem / 2 ))
#Get memory/4
mem_devide_4=$(( $mem / 4 ))

sed -i "s/-Xms2g -Xmx2g/-Xms$mem_devide_2 -Xmx$mem_devide_2/" /etc/sysconfig/puppetserver
sed -i "s/MaxPermSize=256m/MaxPermSize=$mem_devide_4/" /etc/sysconfig/puppetserver

#systemctl enable puppetserver.service
#systemctl start puppetserver.service

/opt/puppetlabs/bin/puppet module install puppetlabs-puppetdb
