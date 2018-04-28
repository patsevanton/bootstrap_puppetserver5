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

sed -i "s/-Xms2g -Xmx2g/-Xms512m -Xmx512m -XX:MaxPermSize=256m/" /etc/sysconfig/puppetserver
