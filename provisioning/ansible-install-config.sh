#!/bin/bash

NUM_COMPUTE_NODES=$1
HOSTS=/etc/ansible/hosts

# Ansible installation
dnf makecache
dnf install -y ansible
mkdir -p /etc/ansible
cp /vagrant/ansible/ansible.cfg /etc/ansible

# Create hosts Ansible file
echo -n "" > aux

echo -e "head \t ansible_connection=local" > $HOSTS
for (( i=0; i<$NUM_COMPUTE_NODES; i++ )); do
	echo -e "compute-$i" >> aux
done	

cat aux >> $HOSTS
echo -e "\n[computes]" >> $HOSTS
cat aux >> $HOSTS && rm aux