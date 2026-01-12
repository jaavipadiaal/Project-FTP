#!/bin/bash

apt update
apt install -y vsftpd

mkdir -p /srv/ftp

mv /tmp/vsftpd.conf /etc/vsftpd.conf
mv /tmp/banner.msg /srv/ftp/.message

chown root:root /etc/vsftpd.conf
chown root:root /srv/ftp/.message
chmod 644 /etc/vsftpd.conf
chmod 644 /srv/ftp/.message

systemctl restart vsftpd
