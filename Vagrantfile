# -*- mode: ruby -*-
HEAD_NODE_IP 			= "10.10.1.2"
HEAD_NODE_MEM 			= 2048
HEAD_NODE_CORES 		= 1
NUM_COMPUTE_NODES 		= 1
COMPUTE_NODE_MEM 		= 1024
COMPUTE_NODE_CORES 		= 1
DISKS_HEAD         		= 2
DISKS_HEAD_MEM_GB  		= 1
DISKS_COMPUTES			= 2
DISKS_COMPUTES_MEM_GB 	= 1

require 'ipaddr'
CLUSTER_IP_ADDR = IPAddr.new HEAD_NODE_IP
CLUSTER_IP_ADDR = CLUSTER_IP_ADDR.succ

Vagrant.configure("2") do |config|
    config.vm.box = "generic/centos8"
    config.vm.synced_folder "sync", "/vagrant", type: "virtualbox", mount_options: ["dmode=775,fmode=777"]

    # Generate /etc/hosts (plugin)
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = false
    config.hostmanager.manage_guest = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = true
    
    # Head node
    config.vm.define "head", primary: true do |head|
        head.vm.hostname = "head"
        head.vm.network :private_network, ip: HEAD_NODE_IP

        if DISKS_HEAD < 2 then DISKS_HEAD = 2 end
        #puts DISKS_HEAD

        #(1..DISKS_HEAD).each do |i|
        #	head.vm.disk :disk, name: "disk#{i}", size: DISKS_HEAD_MEM_GB * 1024 * 1024 * 1024
        #end
        #head.vm.disk :disk, name: "disk1", size: "1GB"

        head.vm.provider :virtualbox do |vb|
            vb.cpus = HEAD_NODE_CORES
            vb.memory = HEAD_NODE_MEM
            unless File.exist?(".vagrant/machines/head/virtualbox/private_key")
            	vb.customize ["storagectl", :id, "--name", "SATA Controller", "--add", "sata"]
            end
            (1..DISKS_HEAD).each do |j|
            	filename = "./disks/head/disk#{j}.vmdk"
            	unless File.exist?(filename)
                	vb.customize ["createmedium", "disk", "--filename", filename, "--size", DISKS_HEAD_MEM_GB * 1024]
                 	vb.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", j + 1, "--device", 0, "--type", "hdd", "--medium", filename]
                end
            end
        end
        ###   export VAGRANT_EXPERIMENTAL="dependency_provisioners,disks"   ###
        # Install ansible on the head node
        head.vm.provision "ansible-install", type: "shell", \
        path: "./provisioning/ansible-install.sh" \
        do |script|
            script.args = [NUM_COMPUTE_NODES]
        end
        
        # Generate ssh-keys
        #head.vm.provision "gen-ssh-keys", type: "shell", before: "global", \
        #path: "./provisioning/ssh-gen-head-keys.sh"

        # Initial configs in ALL nodes
        head.vm.provision "Init", type: "ansible_local", before: "RAID" \
        do |ansible|
            ansible.playbook = "playbooks/init.yml"
            ansible.inventory_path = "/etc/ansible/hosts"
            ansible.limit = "all"
        end

        ##### SSH HBA using Ansible #####
        # Changes in HEAD
        head.vm.provision "HBA-head", type: "ansible_local", before: "RAID",
        preserve_order: true do |ansible|
            ansible.playbook = "playbooks/HBA-head.yml"
            ansible.inventory_path = "/etc/ansible/hosts"
            ansible.limit = "all"
        end
        # Changes in COMPUTES
        head.vm.provision "HBA-computes", type: "ansible_local", before: "RAID", 
        preserve_order: true do |ansible|
           ansible.playbook = "playbooks/HBA-computes.yml"
            ansible.inventory_path = "/etc/ansible/hosts"
            ansible.limit = "all"
        end
        #################################

        # Create RAID for /home and /share
        head.vm.provision "RAID", type: "ansible_local" \
        do |ansible|
            ansible.playbook = "playbooks/RAID.yml"
           ansible.inventory_path = "/etc/ansible/hosts"
            ansible.limit = "all"
        end

        ### Software (lmod, compilers and MPI) ###
        head.vm.provision "software", type: "ansible_local", after: "RAID",
        preserve_order: true do |ansible|
            ansible.playbook = "playbooks/software.yml"
            ansible.inventory_path = "/etc/ansible/hosts"
            ansible.limit = "all"
        end

        ### Slurm ###
        head.vm.provision "Slurm", type: "ansible_local", after: "RAID",
        preserve_order: true do |ansible|
            ansible.playbook = "playbooks/slurm.yml"
            ansible.inventory_path = "/etc/ansible/hosts"
            ansible.limit = "all"
        end

       	### NTP ###
        head.vm.provision "NTP", type: "ansible_local", after: "RAID",
        preserve_order: true do |ansible|
            ansible.playbook = "playbooks/NTP.yml"
            ansible.inventory_path = "/etc/ansible/hosts"
            ansible.limit = "all"
        end

        #### Directories /scratch in COMPUTES
        head.vm.provision "Scratch", type: "ansible_local", after: "RAID",
        preserve_order: true do |ansible|
            ansible.playbook = "playbooks/scratch.yml"
            ansible.inventory_path = "/etc/ansible/hosts"
            ansible.limit = "all"
        end

        ### Create users in all nodes
        head.vm.provision "Users", type: "ansible_local", after: "RAID" \
        do |ansible|
            ansible.playbook = "playbooks/users.yml"
            ansible.inventory_path = "/etc/ansible/hosts"
            ansible.limit = "all"
        end

        ##### NFS ######
        # Changes in HEAD
        head.vm.provision "NFS-head", type: "ansible_local", after: "RAID" \
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
                unless File.exist?(".vagrant/machines/compute-#{i - 1}/virtualbox/private_key")
            		vb.customize ["storagectl", :id, "--name", "SATA Controller", "--add", "sata"]
            	end
            	(1..DISKS_COMPUTES).each do |j|
            		filename = "./disks/compute-#{i - 1}/disk#{j}.vmdk"
            		unless File.exist?(filename)
                  		vb.customize ["createmedium", "disk", "--filename", filename, "--size", DISKS_COMPUTES_MEM_GB * 1024]
                  		vb.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", j + 1, "--device", 0, "--type", "hdd", "--medium", filename]
                	end
            	end
            end
            #compute.vm.provision "mock", type: "shell", path: "./provisioning/mock.sh"
        end
    end

    # Global provisioning bash script
    config.vm.provision "ssh", type: "shell", path: "./provisioning/ssh.sh" \
    do |script|
        script.args = [NUM_COMPUTE_NODES, HEAD_NODE_IP]
    end
end