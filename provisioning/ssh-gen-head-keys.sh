#!/bin/bash

if [ ! -f /vagrant/ssh-keys/id_rsa ] || [ ! -f /vagrant/ssh-keys/id_rsa.pub ]
then
	rm -rf /vagrant/ssh-keys/*
	ssh-keygen -b 2048 -t rsa -f /vagrant/ssh-keys/id_rsa -q -P ""
fi