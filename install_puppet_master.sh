#!/bin/bash

# ask if the machine must be updated
while true; do
	read -p "Run dnf update? y(es),n(o)skip,a(bort)script: " yna
    case $yna in
        [Yy]* ) dnf update; break;;
        [Nn]* ) echo "Skipping updates"; break;;
	[Aa]* ) exit;;
        * ) echo "Please answer yes, no or abort.";;
    esac
done

# ask if the machine must be rebooted
while true; do
        read -p "Reboot the machine? y(es),n(o)skip,a(bort)script: " yna
    case $yna in
        [Yy]* ) shutdown -r now; break;;
        [Nn]* ) echo "Skipping reboot"; break;;
        [Aa]* ) exit;;
        * ) echo "Please answer yes, no or abort.";;
    esac
done

# install puppet repo if not present
echo "check if puppet repo is installed, and install if not"
if [ -f "/etc/yum.repos.d/puppet6.repo" ]; then
	echo "Puppet6 repo is installed"
else
	rpm -Uvh https://yum.puppet.com/puppet6-release-el-8.noarch.rpm
fi

# set hostname
echo "set hostname if its not already correct"
if [[ ( $HOSTNAME == "puppetmaster" ) ]]; then
	echo "hostname is already puppetmaster"
else
	hostnamectl set-hostname puppetmaster 
fi

# ask if the machine must be rebooted
while true; do
        read -p "Reboot the machine? y(es),n(o)skip,a(bort)script: " yna
    case $yna in
        [Yy]* ) shutdown -r now; break;;
        [Nn]* ) echo "Skipping reboot"; break;;
        [Aa]* ) exit;;
        * ) echo "Please answer yes, no or abort.";;
    esac
done

# install puppetserver
while true; do
        read -p "Install puppetserver? y(es),n(o)skip,a(bort)script: " yna
    case $yna in
        [Yy]* ) dnf install -y puppetserver; break;;
        [Nn]* ) echo "Skipping install"; break;;
        [Aa]* ) exit;;
        * ) echo "Please answer yes, no or abort.";;
    esac
done

# change memory allocation for the puppetserver
echo "changing memory allocation for puppetserver"
sed -i 's/JAVA_ARGS="-Xms2g -Xmx2g/JAVA_ARGS="-Xms512m -Xmx512m/g' /etc/sysconfig/puppetserver

# configure puppet.conf
/opt/puppetlabs/bin/puppet config set dns_alt_names 'puppet,puppetserver,puppetmaster' --section master

/opt/puppetlabs/bin/puppet config set certname 'puppetmaster' --section main

/opt/puppetlabs/bin/puppet config set server 'puppetmaster' --section main

/opt/puppetlabs/bin/puppet config set runinterval '30m' --section main

# Add /opt/puppetlabs/bin to the path for sh compatible users
echo "Add /opt/puppetlabs/bin to the path for sh compatible users"
source /etc/profile.d/puppet-agent.sh

# setup puppet server ca
echo "setup puppet server ca"
puppetserver ca setup

# enable and start puppet server
echo "starting and enabling puppet server"
systemctl enable --now puppetserver

# configure /etc/hosts
ETCHOSTSPATH="/etc/hosts"
ETCHOSTSLINE1="10.0.0.2 puppet puppetmaster puppetserver"
ETCHOSTSLINE2="10.0.0.3 puppetc01"
ETCHOSTSLINE3="10.0.0.4 puppetc02"

if [ ! -z "$(grep "$ETCHOSTSLINE1" "$ETCHOSTSPATH")" ]; then
        echo "line already in /etc/hosts, skipping"; else
        echo "adding line to /etc/hosts"
        echo "$ETCHOSTSLINE1" >> "$ETCHOSTSPATH";
fi

if [ ! -z "$(grep "$ETCHOSTSLINE2" "$ETCHOSTSPATH")" ]; then
        echo "line already in /etc/hosts, skipping"; else
        echo "adding line to /etc/hosts"
        echo "$ETCHOSTSLINE2" >> "$ETCHOSTSPATH";
fi

if [ ! -z "$(grep "$ETCHOSTSLINE3" "$ETCHOSTSPATH")" ]; then
        echo "line already in /etc/hosts, skipping"; else
        echo "adding line to /etc/hosts"
        echo "$ETCHOSTSLINE3" >> "$ETCHOSTSPATH";
fi
