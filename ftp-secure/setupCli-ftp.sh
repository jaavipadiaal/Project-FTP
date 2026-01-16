#!/bin/bash
apt-get update
apt-get install -y lftp


mkdir -p /home/vagrant
echo "set ssl:verify-certificate no" > /home/vagrant/.lftprc
chown vagrant:vagrant /home/vagrant/.lftprc

echo "Cliente listo para conectarse al servidor 192.168.56.10"