# 🚀 Proyecto: Servidor FTP Anónimo Automatizado
### (Vagrant + Shell Provisioning + Memoria Técnica)

En este repositorio podemos encontrar la infraestructura y la configuracion de manera automatizada de un servidor FTP anonimo el cual esta basado en **vsftpd**.

---

## 🛠️ 1. Memoria Técnica: Arquitectura y Configuración

### A. Gestión de Red y Acceso (`vsftpd.conf`)
* **Protocolo IPv4:** Se ha desactivado `listen_ipv6` y activado `listen=YES`. Esto nos asegura que el servicio se escuche exclusivamente en IPv4, evitando conflictos de red en entornos virtuales.
* **Acceso Restringido:** Se habilita `anonymous_enable=YES` pero se fuerza `local_enable=NO`. Esto garantiza que **solo** aquellos usuarios anónimos puedan entrar, impidiendo que las cuentas del sistema sean vulneradas.
* **Modo Espejo (Mirror):** La directiva `write_enable=NO` deshabilita cualquier permiso de escritura, protegiendo asi la integridad de los archivos alojados.

### B. Políticas de Rendimiento y QoS
Para poder prevenir abusos de recursos o ataques de Denegación de Servicio (DoS), hemos empleado la siguiente configuracion:
* **Control de Conexiones:** `max_clients=200` este nos limita la carga simultánea en el servidor.
* **Limitación de Ancho de Banda:** `anon_max_rate=51200`. (Configurado como $50 \times 1024$ bytes/segundo para cumplir con el requisito exacto de **50KB/s**).
* **Gestión de Inactividad:** `idle_session_timeout=30` nos aseguramos que las conexiones colgadas se liberen justo tras 30 segundos, optimizando asi el uso de memoria.

### C. Experiencia del Usuario (Mensajes)
* **Banner de Bienvenida:** Visible inmediatamente al conectar (`ftpd_banner`).
* **Mensaje de Directorio:** Mediante `dirmessage_enable=YES`, el servidor lee de manera automática el archivo oculto `.message` en la raíz para asi informar al usuario de las normas y límites del servidor.

---

## 📂 2. Estructura del Proyecto

```text
.
├── Vagrantfile              # Definición de red privada y creacion de VMs
├── vagrant/                 # Carpeta sincronizada (/vagrant/vagrant en la VM)
│   ├── setup.sh             # Script de automatización (Bash)
│   ├── vsftpd.conf          # Fichero de configuración
│   └── banner.msg           # Contenido informativo para el usuario
└── README.md                # Documentación 

```

---

## ⚙️ 3. Detalles del Provisionamiento (`inicio-servidor.sh`)

En el proceso de automatización nos hemos centralizado en un unico script (puedes ejecutarlo varias veces no rompera nada)

Las tareas críticas que realiza son:

1.  **Instalación Silenciosa:**
    Instalación de `vsftpd` y `openssl` mediante `apt-get` con el flag `-y` y asi podemos evitar bloqueos.
2.  **Enlace de Configuración Directo:**
    Copia el archivo `vsftpd.conf` desde el punto de montaje compartido `/vagrant/vagrant/` directamente a `/etc/vsftpd.conf`, asegurando que el servidor use nuestra configuración personalizada.
3.  **Gestión de Permisos de Sistema:**
    Aplica `chown root:root` y `chmod 644` al fichero de configuración, es un requisito indispensable para que nuestro servicio `vsftpd` arranque por motivos de seguridad.

---

## 🧪 4. Validación de los Requisitos (QA)

Pruebas de verificación: 

| Requisito | Método de Verificación | Comando / Acción | Resultado Esperado |
| :--- | :--- | :--- | :--- |
| **Protocolo de Red** | Verificar escucha IPv4 | `netstat -plnt` | El puerto 21 debe estar en `0.0.0.0` |
| **Acceso Seguro** | Intento de login local | `ftp localhost` | Mensaje: `530 Login incorrect` |
| **Anonimato** | Login sin credenciales | `ftp 192.168.56.10` | Acceso concedido (anonymous) |
| **QoS (Banda)** | Descarga de prueba | `get archivo_grande` | Tasa limitada a **50KB/s** |
| **Persistencia** | Prueba de Timeout | Dejar sesión inactiva | Desconexión automática a los **30s** |

---

## 🆘 5. Solución de Problemas Comunes

Si el despliegue falla, puedes consultar esta tabla de errores frecuentes.

> ⚠️ **IMPORTANTE:** La mayoría de errores en este proyecto derivan de permisos incorrectos en el sistema anfitrión (Windows/Mac).

| Error Detectado | Causa Probable | Acción Correctiva |
| :--- | :--- | :--- |
| `bash: setup.sh: Permission denied` | El script no es ejecutable en el Host. | Ejecuta `chmod +x vagrant/setup.sh`. |
| `Job for vsftpd.service failed` | Error de sintaxis en `vsftpd.conf`. | Revisar el archivo con `sudo vsftpd -t`. |
| `500 OOPS: config file not owned by root` | Permisos de la carpeta compartida. | Verifica `owner: "root"` en el propio Vagrantfile. |
| `Connection timed out` | Conflicto con Firewall o IP. | Desactiva firewalls locales temporalmente. |



---

**Autor:** Javier Padial González & David Ortiz Sierra
**Fecha:** Enero 2026  
**Proyecto:** Administración de Sistemas / Despliegue de Servicios FTP.




