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

# Ask if hostname must be set 
while true; do
        read -p "Set hostname? y(es),n(o)skip,a(bort)script: " yna
    case $yna in
        [Yy]* ) echo "Please insert desired hostname!"; read DESIREDHOSTNAME; hostnamectl set-hostname $DESIREDHOSTNAME; break;;
        [Nn]* ) echo "Skipping set hostname"; break;;
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

# install puppet agent
while true; do
        read -p "Install puppet agent? y(es),n(o)skip,a(bort)script: " yna
    case $yna in
        [Yy]* ) dnf install -y puppet-agent; break;;
        [Nn]* ) echo "Skipping install"; break;;
        [Aa]* ) exit;;
        * ) echo "Please answer yes, no or abort.";;
    esac
done

# configure puppet.conf
PUPPETDOTCONFPATH="/etc/puppetlabs/puppet/puppet.conf"
PUPPETDOTCONFLINE1="[main]"
PUPPETDOTCONFLINE2="server = puppetmaster"
PUPPETDOTCONFLINE3="certname = puppetc01"
PUPPETDOTCONFLINE4="runinterval = 30m"

if [ ! -z "$(grep "$PUPPETDOTCONFLINE1" "$PUPPETDOTCONFPATH")" ]; then
        echo "line already in puppet.conf, skipping"; else
        echo "adding line to puppet.conf"
        echo "$PUPPETDOTCONFLINE1" >> "$PUPPETDOTCONFPATH";
fi

if [ ! -z "$(grep "$PUPPETDOTCONFLINE2" "$PUPPETDOTCONFPATH")" ]; then
        echo "line already in puppet.conf, skipping"; else
        echo "adding line to puppet.conf"
        echo "$PUPPETDOTCONFLINE2" >> "$PUPPETDOTCONFPATH";
fi

if [ ! -z "$(grep "$PUPPETDOTCONFLINE3" "$PUPPETDOTCONFPATH")" ]; then
        echo "line already in puppet.conf, skipping"; else
        echo "adding line to puppet.conf"
        echo "$PUPPETDOTCONFLINE3" >> "$PUPPETDOTCONFPATH";
fi

if [ ! -z "$(grep "$PUPPETDOTCONFLINE4" "$PUPPETDOTCONFPATH")" ]; then
        echo "line already in puppet.conf, skipping"; else
        echo "adding line to puppet.conf"
        echo "$PUPPETDOTCONFLINE4" >> "$PUPPETDOTCONFPATH";
fi

# Add /opt/puppetlabs/bin to the path for sh compatible users
echo "Add /opt/puppetlabs/bin to the path for sh compatible users"
source /etc/profile.d/puppet-agent.sh

# enable and start puppet agent
echo "starting and enabling puppet agent"
puppet resource service puppet ensure=running enable=true

# configure /etc/hosts
ETCHOSTSPATH="/etc/hosts"
ETCHOSTSLINE1="10.0.0.2 puppetmaster"

if [ ! -z "$(grep "$ETCHOSTSLINE1" "$ETCHOSTSPATH")" ]; then
        echo "line already in /etc/hosts, skipping"; else
        echo "adding line to /etc/hosts"
        echo "$ETCHOSTSLINE1" >> "$ETCHOSTSPATH";
fi
