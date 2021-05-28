#!/usr/bin/python

import os
import yaml
from jinja2 import Template

with open("synced_folder/variables.yml") as variables:
	doc = yaml.safe_load(variables)

with open("Vagrantfile-template") as VagrantTemplate:
    t = Template(VagrantTemplate.read())
    
output = t.render(
		HEAD_NODE_IP 			= doc["variables"]["HEAD_NODE_IP"], 
		HEAD_NODE_MEM			= doc["variables"]["HEAD_NODE_MEM"], 
		HEAD_NODE_CORES			= doc["variables"]["HEAD_NODE_CORES"],
		NUM_COMPUTE_NODES		= doc["variables"]["NUM_COMPUTE_NODES"],
		COMPUTE_NODE_MEM		= doc["variables"]["COMPUTE_NODE_MEM"],
		COMPUTE_NODE_CORES		= doc["variables"]["COMPUTE_NODE_CORES"],
		DISKS_HEAD				= doc["variables"]["DISKS_HEAD"],
		DISKS_HEAD_MEM_GB		= doc["variables"]["DISKS_HEAD_MEM_GB"],
		DISKS_COMPUTES			= doc["variables"]["DISKS_COMPUTES"],
		DISKS_COMPUTES_MEM_GB	= doc["variables"]["DISKS_COMPUTES_MEM_GB"])

with open("Vagrantfile", "w") as Vagrantfile:
    Vagrantfile.write(output)