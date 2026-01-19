# Project FTP

## Proyecto FTP Final: Servidor Seguro con SSL/TLS y Ansible

Este proyecto crea una infraestructura de red usando **Vagrant** y **Ansible** para desplegar un **servidor FTP seguro** con cifrado SSL/TLS.  
Incluye usuarios con distintos permisos, control de acceso y límites de velocidad.

---

## 📂 2. Estructura del Proyecto

```text
.
├── Vagrantfile             
├── provision.yml
├── hosts               
├── templates/                
│   └── vsftpd.conf.j2         
└── README.md                 

```

- **Vagrantfile**: Define las máquinas virtuales (Servidor y Cliente).
- **provision.yml**: Playbook de Ansible para instalar y configurar todo.
- **templates/vsftpd.conf.j2**: Plantilla de configuración del servidor FTP.
- **hosts**: Inventario de Ansible.

---

## 🚀 Requisitos Previos

- Vagrant instalado.
- VirtualBox (u otro proveedor compatible).
- Ansible instalado en la máquina anfitriona.

---

## 🛠️ Despliegue

Desde la raíz del proyecto ejecuta:

```bash
vagrant up
```

## 🔧 Acciones Automáticas del Despliegue

Al ejecutar `vagrant up`, el sistema realiza automáticamente las siguientes acciones:

- Crea el servidor **ftp.example.test** con IP `192.168.56.10`.
- Crea la máquina cliente con IP `192.168.56.11`.
- Instala los paquetes **vsftpd** y **openssl**.
- Genera un certificado SSL autofirmado.
- Crea los usuarios **luis**, **maria** y **miguel**.

---

## 🔒 Configuraciones de Seguridad

### 1. Cifrado SSL/TLS

- El uso de SSL es obligatorio.
- Se cifra tanto el inicio de sesión como la transferencia de archivos.
- El certificado se encuentra en:  
  `/etc/ssl/certs/example.test.pem`.

### 2. Usuarios y Chroot

- **Usuarios enjaulados**:  
  Por defecto, los usuarios no pueden salir de su carpeta personal.
- **Excepción**:  
  El usuario **maria** puede salir de su home porque está incluida en la lista blanca:  
  `/etc/vsftpd.chroot_list`.

### 3. Límites de Tráfico

- Usuarios anónimos: **2 MB/s**.
- Usuarios locales: **5 MB/s**.
- Máximo de **15 conexiones simultáneas**.

---

## 🧪 Verificación

### Acceso desde el Cliente

La máquina cliente ya incluye las herramientas necesarias:
- `ftp`
- `lftp`
- `filezilla`

También está configurada para aceptar certificados autofirmados durante las pruebas.

Prueba rápida:

```bash

vagrant ssh cliente
lftp -u luis 192.168.56.10

```

## 🔍 Comprobación de Chroot

### Luis
- No puede acceder al directorio `/etc`.
- Queda limitado a su carpeta personal.

### Maria
- Puede acceder al directorio `/etc`.
- No está enjaulada, por lo que puede moverse fuera de su home.

---

**Autor:** Javier Padial González & David Ortiz Sierra

**Proyecto:** Administración de Sistemas / Proyect-FTP.

