#!/bin/bash

vagrant up

echo "Conectando al servidor FTP anónimo..."
vagrant ssh cliente -c "ftp -p 192.168.56.10"