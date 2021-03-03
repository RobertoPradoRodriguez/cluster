#!/bin/bash

#echo toor | passwd --stdin root
#localectl set-keymap es
#localectl set-locale LANG=es_ES
#-- disable SELinux && reboot

#yum install mdadm -y
#yes | mdadm --create --verbose /dev/md0 --level=1 --raid-devices=2 /dev/sdb /dev/sdc
#mdadm --detail --scan > /etc/mdadm.conf
#pvcreate /dev/md0
#vgcreate vg_raid /dev/md0
#lvcreate -n lv_home -l 50%VG vg_raid
#mkfs -t xfs /dev/mapper/vg_raid-lv_home
#yes | cp -r /home/vagrant/ /vagrant/
#mount /dev/mapper/vg_raid-lv_home /home/
#yes | cp -r /vagrant/vagrant /home/
#chown -R vagrant:vagrant /home/vagrant/
#chmod 755 /home/vagrant/ && chmod 700 /home/vagrant/.ssh/ && chmod 600 /home/vagrant/.ssh/authorized_keys

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