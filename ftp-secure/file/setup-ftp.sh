#!/bin/bash
# Script de configuración FTP Seguro (Sustituye a Ansible)

# 1. Instalación
apt-get update
apt-get install -y vsftpd openssl

# 2. Crear usuarios (luis, maria, miguel) con contraseña 'password'
# Generamos el hash compatible con Debian
PASS_HASH=$(openssl passwd -6 "password")

for usuario in luis maria miguel; do
    if ! id "$usuario" &>/dev/null; then
        useradd -m -p "$PASS_HASH" -s /bin/bash "$usuario"
        echo "Usuario $usuario creado."
    fi
done

# 3. Archivos de prueba para Luis
touch /home/luis/luis1.txt /home/luis/luis2.txt
chown luis:luis /home/luis/luis*.txt

# 4. Generar certificado SSL (Requisito ftp-seguro.html)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/vsftpd.pem \
  -out /etc/ssl/certs/example.test.pem \
  -subj "/C=ES/ST=Granada/L=Granada/O=Sistema/CN=ftp.example.test"

# 5. Lista de usuarios NO enjaulados (Maria puede salir de su home)
echo "maria" > /etc/vsftpd.chroot_list

# 6. Aplicar configuración desde el directorio compartido /vagrant/vagrant/
# Usamos 'cp' en lugar de 'mv' para no borrar el archivo de tu PC real
cp /vagrant/file/vsftpd.conf /etc/vsftpd.conf
chown root:root /etc/vsftpd.conf

# 7. Configurar lftp para el usuario vagrant (evitar error de certificado)
echo "set ssl:verify-certificate no" > /home/vagrant/.lftprc
chown vagrant:vagrant /home/vagrant/.lftprc

# Reiniciar para aplicar cambios
systemctl restart vsftpd