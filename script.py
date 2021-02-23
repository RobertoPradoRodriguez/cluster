#!/usr/bin/python

import os
import yaml
from jinja2 import Template

# Export env variable to allow dependency provisioners in Vagrant 
#os.system(". ~/.bashrc")
os.system("if [ $(grep -c VAGRANT_EXPERIMENTAL ~/.bashrc) -eq 0 ]; \
	then echo VAGRANT_EXPERIMENTAL='dependency_provisioners' >> ~/.bashrc; fi")

with open("sync/variables.yml") as variables:
	doc = yaml.safe_load(variables)

with open("Vagrantfile-template") as VagrantTemplate:
    t = Template(VagrantTemplate.read())
    
output = t.render(
		HEAD_NODE_IP 		= doc["variables"]["HEAD_NODE_IP"], 
		HEAD_NODE_MEM		= doc["variables"]["HEAD_NODE_MEM"], 
		HEAD_NODE_CORES		= doc["variables"]["HEAD_NODE_CORES"],
		NUM_COMPUTE_NODES	= doc["variables"]["NUM_COMPUTE_NODES"],
		COMPUTE_NODE_MEM	= doc["variables"]["COMPUTE_NODE_MEM"],
		COMPUTE_NODE_CORES	= doc["variables"]["COMPUTE_NODE_CORES"])

with open("Vagrantfile", "w") as Vagrantfile:
    Vagrantfile.write(output)