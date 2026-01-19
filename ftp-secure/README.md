# 🚀 Proyecto: Servidor FTP Seguro (FTPS) Automatizado
### (Vagrant + Shell Provisioning + SSL/TLS)

---

## 🛠️ 1. Memoria Técnica: Configuración de Seguridad

### A. Cifrado SSL/TLS (Seguridad Robusta)
Para poder proteger el tráfico frente a los ataques, hemos aplicado estas directivas:
* **Certificado RSA:** Esta genera una clave de 2048 bits y un certificado autofirmado en `/etc/ssl/certs/example.test.pem`.
* **Cifrado Forzado:** Obligamos a los usuarios locales (`luis`, `maria`, `miguel`) a que deban de realizar tanto el *login* como la propia transferencia de datos.


### B. Gestión de Usuarios y Enjaulamiento (Chroot)
* **Usuarios Locales:** Aqui creamos de manera automatizada cuentas con directorios personales protegidos.
* **Excepciones de Enjaulamiento:** Implementamos una `chroot_list`. Asi mientras que `luis` y `miguel` están restringidos a sus carpetas, `maria` tiene permisos para navegar fuera de su home.
* **Límites de Ancho de Banda :** * **Anónimos:** Limitados a **2MB/s**.
    * **Locales:** Limitados a **5MB/s** y asi podemos priorizar a los usuarios registrados.

---

## 📂 2. Estructura del Proyecto
Este despliegue usa a la propia carpeta compartida `/vagrant/file/` para que asi los cambios en el Host se apliquen de manera inmediata al reiniciar el servicio en la VM.

```text
.
├── Vagrantfile              
├── README.md                
├── setup-ftp.sh               
├── setupCli-ftp.sh         
└── file/                
    └── vsfptd.conf           

```

---

## ⚠️ 3. Guía de Ejecución y Seguridad

### Paso 1: Otorgar Permisos de Ejecución 
Para que Vagrant pueda iniciarse, debemos de dar permisos al archivo en nuestra máquina:

```bash

# Ejecutamos en la terminal
chmod 755 vagrant/setup.sh

```
```bash

#!/bin/bash
# =================================================================
# PASO 2 - PUNTO 3: Generación de Certificados y Configuración
# =================================================================

# 3.1. Crear archivos de prueba para Luis 
touch /home/luis/luis1.txt /home/luis/luis2.txt
chown luis:luis /home/luis/luis*.txt

# 3.2. Generar certificado SSL autofirmado 
# Usaremos una clave de 2048 bits válida por un año
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/vsftpd.pem \
  -out /etc/ssl/certs/example.test.pem \
  -subj "/C=ES/ST=Granada/L=Granada/O=Sistema/CN=ftp.example.test"

# 3.3. Configuración de excepciones de enjaulamiento (chroot_list)
# Para que Maria pueda salir de su directorio personal, Luis y Miguel no.
echo "maria" > /etc/vsftpd.chroot_list

# 3.4. Aplicación de la configuración final
cp /vagrant/file/vsftpd.conf /etc/vsftpd.conf
chown root:root /etc/vsftpd.conf
chmod 644 /etc/vsftpd.conf

# 3.5. Configuración de cliente lftp para el usuario vagrant
echo "set ssl:verify-certificate no" > /home/vagrant/.lftprc
chown vagrant:vagrant /home/vagrant/.lftprc

# Reinicio del servicio para aplicar todo lo anterior
systemctl restart vsftpd
echo "--- Configuración de FTP Seguro completada ---"

# =================================================================
# CONFIGURACIÓN VSFTPD - PROYECTO FTP SEGURO
# =================================================================

# Parámetros básicos
listen=YES
listen_ipv6=NO
anonymous_enable=YES
local_enable=YES
write_enable=YES

# SSL / TLS (Punto 4 del Paso 2)
# Forzamos cifrado para usuarios locales pero lo dejamos opcional para anónimos
ssl_enable=YES
allow_anon_ssl=YES
force_local_data_ssl=YES
force_local_logins_ssl=YES

# Protocolos permitidos 
ssl_tlsv1=YES
ssl_sslv3=YES

# Rutas de los certificados generados en el punto 3
rsa_cert_file=/etc/ssl/certs/example.test.pem
rsa_private_key_file=/etc/ssl/private/vsftpd.pem
require_ssl_reuse=NO

# Enjaulamiento y Seguridad
chroot_local_user=YES
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd.chroot_list
allow_writeable_chroot=YES

# QoS - Límites de ancho de banda (Requisito: 2MB anónimos / 5MB locales)
anon_max_rate=2097152
local_max_rate=5242880
max_clients=15


```  
---

## 🧪 4. Validación de los Requisitos

Para poder garantizar que funciona debemos de realizar las siguientes pruebas desde la máquina cliente o un cliente externo (como FileZilla):

| Requisito | Acción de Verificación | Resultado Esperado |
| :--- | :--- | :--- |
| **Cifrado Obligatorio** | Intentar login con `luis` sin usar TLS/SSL. | El servidor rechaza la conexión (530 Login incorrect). |
| **Conexión FTPS** | Conectar con `luis` usando "FTP explícito sobre TLS". | Éxito: Se acepta el certificado y aparece el candado. |
| **Transferencia Segura** | Descargar un archivo con el usuario `luis`. | El tráfico viaja cifrado y la descarga se completa. |
| **Enjaulamiento (Luis)** | Ejecutar `cd /` conectado como `luis`. | No puede salir de su directorio `/home/luis`. |
| **Excepción (Maria)** | Ejecutar `cd /` conectado como `maria`. | **Éxito:** Puede navegar por la raíz del servidor. |
| **Límite Locales** | Descargar archivo con usuario local. | Velocidad máxima limitada a **5MB/s**. |
| **Límite Anónimos** | Descargar archivo como anónimo. | Velocidad máxima limitada a **2MB/s**. |



---

## 🆘 5. Solución de Problemas Comunes

En el caso de que aparezcan errores:

| Error Detectado | Causa Probable | Acción Correctiva |
| :--- | :--- | :--- |
| `Connection refused` | El servicio vsftpd no está activo. | Ejecuta `sudo systemctl status vsftpd` para ver el error. |
| `maria no puede salir de su home` | El usuario no está en la lista de excepciones. | Verifica que el archivo `/etc/vsftpd.chroot_list` contenga el nombre `maria`. |



---

**Autor:** Javier Padial González & David Ortiz Sierra  
**Proyecto:** FTP Segura.
