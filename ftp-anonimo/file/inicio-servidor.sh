#!/bin/bash

apt-get update && apt-get install -y vsftpd

mkdir -p /srv/ftp

mv /tmp/vsftpd.conf /etc/vsftpd.conf
mv /tmp/banner.msg /srv/ftp/.message

chown root:root /etc/vsftpd.conf
chmod 644 /etc/vsftpd.conf

systemctl restart vsftpd
