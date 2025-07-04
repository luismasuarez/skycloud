# ⚙️ Arquitectura Actual - Infraestructura Self-Hosted

Este documento describe la arquitectura operativa actual, centrada en un **droplet auto-gestionado en DigitalOcean**, usando **Docker, Docker Compose, Jenkins y NGINX Proxy Manager** como núcleo del entorno DevOps.

---

## 🔑 Componentes Clave

### ☁️ Droplet DigitalOcean

- **Servidor virtual principal**.
- Ejecuta todo el stack en un solo host (`bare metal` virtualizado).
- Sistema operativo: Linux (Ubuntu recomendado).

---

### 🐳 Orquestación con Docker Compose

- Todos los servicios corren como **contenedores Docker**.
- Se agrupan bajo una **red Docker externa** (`skycloud`) para comunicación interna segura.
- Cada servicio tiene **volúmenes persistentes** para no perder datos entre reinicios.

---

### 🌐 Proxy Inverso

- **NGINX Proxy Manager** gestiona:
  - Entrada de tráfico HTTP (`80`) y HTTPS (`443`).
  - Emite certificados SSL mediante Let’s Encrypt.
  - Aplica autenticación (*Access Lists*) para proteger paneles internos.
- Cada servicio web (Portainer, DbGate, Jenkins, RabbitMQ Admin) se expone **solo vía subdominios HTTPS**, **no por puertos directos**.

---

### 🗄️ Servicios Core

| Servicio | Propósito | Estado |
|-----------------|----------------------------------|------------------|
| **MySQL** | Base de datos relacional | Acceso interno |
| **MongoDB** | Base de datos NoSQL | Acceso interno |
| **RabbitMQ** | Broker de mensajería | Acceso interno + admin via proxy |
| **DbGate** | GUI para MySQL y MongoDB | Acceso solo vía proxy |
| **Portainer** | Panel de administración de contenedores Docker | Acceso solo vía proxy |
| **Jenkins** | CI/CD server | Acceso solo vía proxy |
| **NGINX Proxy Manager** | Proxy inverso y SSL | Público en 80/443 |

---

### 🔧 Jenkins y Despliegue

- El **pipeline Jenkins** ejecuta un flujo **zero-downtime**:
  - Clona repositorio.
  - Construye imagen Docker **temporal** (`:temp`).
  - Ejecuta contenedor **temporal** para pruebas de arranque.
  - Si pasa test de vida:
    - Detiene contenedor principal anterior.
    - Ejecuta nuevo contenedor `--restart=always`.
    - Reetiqueta imagen como `:latest`.
  - Limpia recursos intermedios.
- Se gestiona el entorno (`.env`) vía credenciales seguras (`Jenkins Credentials`).

---

### 🔒 Seguridad

- **Solo puertos 80/443/22 expuestos públicamente**.
- Todos los paneles de administración están detrás de **NGINX Proxy Manager** con:
  - Subdominios individuales.
  - HTTPS con certificados automáticos.
  - Autenticación de acceso.
- Accesos SSH controlados por claves.
- Firewall (`ufw` o reglas DO) activa y restringe tráfico.
- Respaldos planeados para volúmenes (`mysqldump`, `mongodump`).

---

### 🔄 Flujos Internos

- Contenedores se comunican entre sí solo dentro de la red `skycloud`:
  - Bases de datos no exponen puertos externos.
  - Aplicaciones backend consumen RabbitMQ y DBs vía nombres de servicio Docker (`mysql`, `mongodb`, `rabbitmq`).

---

## 🚀 Resumen de Ventajas

✅ **Despliegue CI/CD sin downtime** (gracias al pipeline de imagen temporal).  
✅ **Escalabilidad controlada** (multi-servicio en un solo droplet).  
✅ **Aislamiento de red interno**.  
✅ **Proxy centralizado** con certificados SSL y autenticación.  
✅ **Admin web segura**: DbGate, Portainer y Jenkins no exponen puertos públicos directos.

---

## 🏗️ Próximos pasos sugeridos

- Integrar **backups automáticos** a Storage externo.
- Agregar **Prometheus + Grafana** para métricas.
- Consolidar Terraform/Ansible si se escala a más droplets.
- Reforzar VPN o túneles si se requiere acceso externo a servicios backend.

---

**Fin del Resumen de Arquitectura**

Última actualización: 🚀 *[04/07/2025]*
