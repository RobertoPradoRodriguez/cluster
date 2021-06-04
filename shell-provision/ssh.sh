#!/bin/bash

# Manage ssh keys from public-key access (used for Ansible tasks)
if [[ $HOSTNAME == "head" ]] 
then
    if [ ! -f /synced_folder/ssh-keys/id_rsa ] || [ ! -f /synced_folder/ssh-keys/id_rsa.pub ]
    then
        rm -rf /synced_folder/ssh-keys/*
        ssh-keygen -b 2048 -t rsa -f /synced_folder/ssh-keys/id_rsa -q -P ""
    fi
    if [ -d /home/vagrant/.ssh ]
    then
        cp /synced_folder/ssh-keys/* /home/vagrant/.ssh
        chmod 600 /home/vagrant/.ssh/id_rsa
        chown vagrant:vagrant /home/vagrant/.ssh/id_rsa*
    fi
# Compute nodes
elif [ -f /synced_folder/ssh-keys/id_rsa.pub ]
then
    sed -i '/root@head/d' /home/vagrant/.ssh/authorized_keys
    cat /synced_folder/ssh-keys/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
fi

if [ ! -d /vagrant ]
then
	mkdir -m 700 /vagrant && chown vagrant:vagrant /vagrant
fi