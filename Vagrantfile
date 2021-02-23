# -*- mode: ruby -*-
HEAD_NODE_IP 		= "10.10.1.2"
HEAD_NODE_MEM 		= 2048
HEAD_NODE_CORES 	= 1
NUM_COMPUTE_NODES 	= 1
COMPUTE_NODE_MEM 	= 1536
COMPUTE_NODE_CORES 	= 1
require 'ipaddr'
CLUSTER_IP_ADDR = IPAddr.new HEAD_NODE_IP
CLUSTER_IP_ADDR = CLUSTER_IP_ADDR.succ

Vagrant.configure("2") do |config|
    config.vm.box = "generic/centos8"
    config.vm.synced_folder "sync", "/vagrant", type: "virtualbox", mount_options: ["dmode=775,fmode=777"]

    # Head node
    config.vm.define "head", primary: true do |head|
        head.vm.hostname = "head"
        head.vm.network :private_network, ip: HEAD_NODE_IP

        head.vm.provider :virtualbox do |vb|
            vb.cpus = HEAD_NODE_CORES
            vb.memory = HEAD_NODE_MEM
        end
        
        ###   export VAGRANT_EXPERIMENTAL="dependency_provisioners"   ###
        # Install ansible on the head node
        head.vm.provision "ansible-install", type: "shell", before: "global", \
        path: "./provisioning/ansible-install-config.sh" \
        do |script|
            script.args = [NUM_COMPUTE_NODES]
        end
        
        # Generate ssh-keys
        #head.vm.provision "gen-ssh-keys", type: "shell", before: "global", \
        #path: "./provisioning/ssh-gen-head-keys.sh"
        
        #head.trigger.after :up do |trigger|
        #    trigger.run = {path: "./provisioning/mock.sh"}
        #    trigger.only_on = "compute-0"
        #end

        ##### SSH HBA using Ansible #####
        # Changes in HEAD
        head.vm.provision "HBA-head", type: "ansible_local", after: "ansible-install",
        preserve_order: true do |ansible|
            ansible.playbook = "playbooks/HBA-head.yml"
            ansible.inventory_path = "/etc/ansible/hosts"
            ansible.limit = "all"
        end
        # Changes in COMPUTES
        head.vm.provision "HBA-computes", type: "ansible_local", after: "ansible-install", 
        preserve_order: true do |ansible|
            ansible.playbook = "playbooks/HBA-computes.yml"
            ansible.inventory_path = "/etc/ansible/hosts"
            ansible.limit = "all"
        end
        #################################

        ### Create users in all nodes
        head.vm.provision "Users", type: "ansible_local", after: "ansible-install" \
        do |ansible|
            ansible.playbook = "playbooks/users.yml"
            ansible.inventory_path = "/etc/ansible/hosts"
            ansible.limit = "all"
        end

        ##### NFS ######
        # Changes in HEAD
        head.vm.provision "NFS-head", type: "ansible_local", after: "ansible-install" \
        do |ansible|
            ansible.playbook = "playbooks/NFS-head.yml"
            ansible.inventory_path = "/etc/ansible/hosts"
            ansible.limit = "all"
        end
        # Changes in COMPUTES
        head.vm.provision "NFS-computes", type: "ansible_local", after: :all \
        do |ansible|
            ansible.playbook = "playbooks/NFS-computes.yml"
            ansible.inventory_path = "/etc/ansible/hosts"
            ansible.limit = "all"
        end
        ################
    end
 
    # Compute nodes
    (1..NUM_COMPUTE_NODES).each do |i|
        config.vm.define "compute-#{i - 1}" do |compute|
            IP_ADDR = CLUSTER_IP_ADDR.to_s
            CLUSTER_IP_ADDR = CLUSTER_IP_ADDR.succ
            compute.vm.hostname = "compute-#{i - 1}"
            compute.vm.network :private_network, ip: IP_ADDR

            compute.vm.provider :virtualbox do |vb|
                vb.cpus = COMPUTE_NODE_CORES
                vb.memory = COMPUTE_NODE_MEM
            end
            #compute.vm.provision "mock", type: "shell", path: "./provisioning/mock.sh"
        end
    end

    # Global provisioning bash script
    config.vm.provision "global", type: "shell", path: "./provisioning/bootstrap.sh" \
    do |script|
        script.args = [NUM_COMPUTE_NODES, HEAD_NODE_IP]
    end
end