#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Sintaxis: $0 NUM_COMPUTE_NODES HEAD_NODE_IP"
    exit
fi

#NUM_COMPUTE_NODES=$1
#HEAD_NODE_IP=$2

# Populate /etc/hosts
#sed -i "/$HOSTNAME/d" /etc/hosts

#if ! grep -Fq $HEAD_NODE_IP /etc/hosts ; then
#    echo -e "$HEAD_NODE_IP \t head" >> /etc/hosts
#fi

#CLUSTER_NETWORK=`echo $HEAD_NODE_IP | cut -d "." -f 1,2,3`
#FIRST_IP=`echo $HEAD_NODE_IP | cut -d "." -f 4`
#ini=$(($FIRST_IP+1))
#fin=$(($FIRST_IP+$NUM_COMPUTE_NODES))
#num=0
#for (( i=$ini; i<=$fin; i++ )); do
#    if ! grep -Fq $CLUSTER_NETWORK.$i /etc/hosts ; then
#        echo -e "$CLUSTER_NETWORK.$i \t compute-$num" >> /etc/hosts
#    fi
#    num=$((num+1))
#done

# Manage ssh keys from public-key access (used before configure HB Auth)
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