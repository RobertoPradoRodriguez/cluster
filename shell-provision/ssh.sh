#!/bin/bash

# Manage ssh keys from public-key access (used for Ansible tasks)
if [[ $HOSTNAME == "head" ]] 
then
    if [ ! -f /vagrant/ssh-keys/id_rsa ] || [ ! -f /vagrant/ssh-keys/id_rsa.pub ]
    then
        rm -rf /vagrant/ssh-keys/*
        ssh-keygen -b 2048 -t rsa -f /vagrant/ssh-keys/id_rsa -q -P ""
    fi
    cp /vagrant/ssh-keys/* /home/vagrant/.ssh
    chmod 600 /home/vagrant/.ssh/id_rsa
    chown vagrant:vagrant /home/vagrant/.ssh/id_rsa*
# Compute nodes
elif [ -f /vagrant/ssh-keys/id_rsa.pub ]
then
    sed -i '/root@head/d' /home/vagrant/.ssh/authorized_keys
    cat /vagrant/ssh-keys/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
fi