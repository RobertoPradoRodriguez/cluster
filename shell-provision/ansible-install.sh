#!/bin/bash

NUM_COMPUTE_NODES=$1
HOSTS=/etc/ansible/hosts
CONFIG=/etc/ansible/ansible.cfg

# Ansible installation
dnf makecache
dnf install -y ansible

# Create hosts file
echo -e "head \t ansible_connection=local\n" > $HOSTS
echo -e "[computes]" >> $HOSTS

for (( i=0; i<$NUM_COMPUTE_NODES; i++ )); do
	echo -e "compute-$i" >> $HOSTS
done	

# Create ansible.cfg file
echo -e "[defaults]\nhost_key_checking = False" > $CONFIG
echo -e "local_tmp = /tmp/.ansible/tmp_local" >> $CONFIG
echo -e "remote_tmp = /tmp/.ansible/tmp_remote" >> $CONFIG