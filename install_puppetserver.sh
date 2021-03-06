#!/bin/bash

read -p "Enter your domain: " domain
read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

read -p "Enter your FQDN PuppetDB: " fqdn_puppetdb
read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

if [[ $fqdn_puppetdb = *$domain* ]]; then
  echo "$fqdn_puppetdb contains $domain"
else
  echo "$fqdn_puppetdb does not contains $domain"
  exit 1
fi

#Disable Selinux
setenforce 0
sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config

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

/opt/puppetlabs/bin/puppet module install puppetlabs-puppetdb
#Autosign Puppet certificates on you domain
echo "*.$domain" > /etc/puppetlabs/puppet/autosign.conf
#Added site.pp for Puppet Master and PuppetDB
cp site.pp /etc/puppetlabs/code/environments/production/manifests/site.pp
sed -i "s/puppet.my.domain/$HOSTNAME.$domain/" /etc/puppetlabs/code/environments/production/manifests/site.pp
sed -i "s/puppetdb.my.domain/$fqdn_puppetdb/" /etc/puppetlabs/code/environments/production/manifests/site.pp

#Added $HOSTNAME to /etc/puppetlabs/puppet/puppet.conf
echo "[main]" > /etc/puppetlabs/puppet/puppet.conf
echo "server = $HOSTNAME.$domain" >> /etc/puppetlabs/puppet/puppet.conf
echo "ca_server = $HOSTNAME.$domain" >> /etc/puppetlabs/puppet/puppet.conf
echo "dns_alt_names = $HOSTNAME,$HOSTNAME.$domain" >> /etc/puppetlabs/puppet/puppet.conf

systemctl enable puppetserver.service
systemctl start puppetserver.service

while true ; do
  timeout 1 bash -c "cat < /dev/null > /dev/tcp/$fqdn_puppetdb/8081"
  if [ "$?" -ne 0 ]; then
    echo "Connection to $fqdn_puppetdb on port 8081 failed"
    echo "Wait 10 second"
  else
    break
  fi
  sleep 10
done

/opt/puppetlabs/bin/puppet agent --test
