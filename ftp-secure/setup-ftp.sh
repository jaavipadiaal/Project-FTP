#!/bin/bash

apt-get update
apt-get install -y vsftpd openssl


PASS_HASH=$(openssl passwd -6 "password")

for usuario in luis maria miguel; do
    if ! id "$usuario" &>/dev/null; then
        useradd -m -p "$PASS_HASH" -s /bin/bash "$usuario"
        echo "Usuario $usuario creado."
    fi
done


touch /home/luis/luis1.txt /home/luis/luis2.txt
chown luis:luis /home/luis/luis*.txt

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/vsftpd.pem \
  -out /etc/ssl/certs/example.test.pem \
  -subj "/C=ES/ST=Granada/L=Granada/O=Sistema/CN=ftp.example.test"

echo "maria" > /etc/vsftpd.chroot_list


cp /vagrant/file/vsftpd.conf /etc/vsftpd.conf
chown root:root /etc/vsftpd.conf

echo "set ssl:verify-certificate no" > /home/vagrant/.lftprc
chown vagrant:vagrant /home/vagrant/.lftprc


systemctl restart vsftpd