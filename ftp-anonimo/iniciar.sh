#!/bin/bash

echo "Levantando máquinas y configurando el laboratorio..."
vagrant up --provision

echo "Conectando al servidor FTP anónimo desde el cliente..."
vagrant ssh cliente -c "ftp -p 192.168.56.10"