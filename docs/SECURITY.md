# 📌 DevOps - Seguridad y Buenas Prácticas para Infraestructura Self-Hosted

Este documento resume **las prácticas mínimas y recomendadas** para asegurar un entorno auto-gestionado en un Droplet de DigitalOcean con `docker-compose`, `NGINX Proxy Manager` y servicios comunes como bases de datos, mensajería y herramientas de CI/CD.

---

## 🚩 1️⃣ Exposición de Puertos

### ✅ Principio General

- **ÚNICO PUERTO expuesto públicamente:** `80` y `443` (manejado por NGINX Proxy Manager).
- Todos los demás servicios deben estar:
  - Solo disponibles dentro de la **red Docker interna**.
  - Expuestos públicamente **solo mediante subdominios protegidos por NGINX Proxy Manager + HTTPS + autenticación**.

---

## 🚩 2️⃣ Análisis Servicio por Servicio

### 🔹 MySQL
- ✔️ Sin puertos externos (`3306` NO expuesto).
- Solo accesible dentro de la red interna (`skycloud`).
- Administración: vía `DbGate`.

### 🔹 MongoDB
- ✔️ Sin puertos externos (`27017` NO expuesto).
- Solo accesible dentro de la red interna.
- Administración: vía `DbGate`.

### 🔹 DbGate
- 📌 Quitar `ports:` directos (`8082:3000`).
- Configurar como **Proxy Host** en NGINX Proxy Manager:
  - Subdominio: `dbgate.midominio.com`
  - Proxy `http://dbgate:3000`
  - Habilitar HTTPS (Let’s Encrypt) + lista de acceso con usuario y contraseña.

### 🔹 RabbitMQ
- 📌 Quitar puertos AMQP (`5672`) y Admin (`15672`) directos.
- Usar solo dentro de la red interna.
- Configurar panel admin como **Proxy Host**:
  - Subdominio: `rabbitmq.midominio.com`
  - Proxy `http://rabbitmq:15672`
  - HTTPS + lista de acceso.

- Si una app externa necesita `5672`:
  - Usar **VPN**, túnel SSH o Gateway API. **No abrir puerto público directo.**

### 🔹 NGINX Proxy Manager
- ✔️ Exponer solo `80`, `443` públicamente.
- Panel admin (`81`) NO debe estar expuesto directo:
  - Quitar `81:81` del `docker-compose`.
  - Crear `npm.midominio.com`:
    - Proxy `http://nginx-proxy-manager:81`
    - HTTPS + lista de acceso.

### 🔹 Portainer
- 📌 Quitar `9000:9000` directos.
- Configurar como **Proxy Host**:
  - Subdominio: `portainer.midominio.com`
  - Proxy `http://portainer:9000`
  - HTTPS + lista de acceso.
  - Habilitar MFA en Portainer.

### 🔹 Jenkins
- 📌 Quitar `8080:8080` directos.
- Configurar como **Proxy Host**:
  - Subdominio: `jenkins.midominio.com`
  - Proxy `http://jenkins:8080`
  - HTTPS + lista de acceso.
- El puerto `50000` (agentes) solo si es necesario, preferir mantenerlo interno.

### 🔹 Watchtower
- ✔️ No necesita puertos externos.

### 🔹 cAdvisor
- 📌 Quitar `8085:8080` directos.
- Configurar como **Proxy Host**:
  - Subdominio: `cadvisor.midominio.com`
  - Proxy `http://cadvisor:8080`
  - HTTPS + lista de acceso opcional.

---

## 🚩 3️⃣ Red de Docker

- Todos los servicios deben estar en la **red externa compartida**, por ejemplo `skycloud`:
  ```yaml
  networks:
    default:
      external: true
      name: skycloud

## 🚩 4️⃣ Acceso Remoto Seguro

* Para bases de datos o colas que **sí requieran conexiones externas**:

  * Configurar una **VPN privada** (`WireGuard`, `OpenVPN`, `Tailscale`).
  * O usar **túneles SSH** con usuarios restringidos.
  * Evitar exponer puertos como `3306` o `5672` directo a Internet.

---

## 🚩 5️⃣ Reglas de Firewall

* Activar `UFW` o reglas de red en DigitalOcean:

  * Solo permitir:

    * `22` (SSH)
    * `80` y `443` (HTTP/HTTPS)
  * Bloquear todo lo demás.

* Comando ejemplo para `ufw`:

  ```bash
  ufw allow OpenSSH
  ufw allow 80
  ufw allow 443
  ufw enable
  ```

---

## 🚩 6️⃣ Buenas Prácticas Generales

✅ **Usuarios SSH sin root directo.**
✅ **Fail2ban** para mitigar ataques de fuerza bruta.
✅ **Claves SSH fuertes.**
✅ **Backups automáticos** de volúmenes (`mysqldump`, `mongodump`) a espacio remoto (Spaces/S3).
✅ **Revisión periódica de certificados Let’s Encrypt.**
✅ **Mantener contenedores actualizados** (p.ej. usando `Watchtower`).
✅ **Documentar subdominios y accesos** (qué proxy host apunta a qué contenedor).

---

## 🚩 7️⃣ Plantilla de Subdominios Sugeridos

| Servicio            | Subdominio                | Proxy                           |
| ------------------- | ------------------------- | ------------------------------- |
| NGINX Proxy Manager | `npm.midominio.com`       | `http://nginx-proxy-manager:81` |
| DbGate              | `dbgate.midominio.com`    | `http://dbgate:3000`            |
| RabbitMQ Admin      | `rabbitmq.midominio.com`  | `http://rabbitmq:15672`         |
| Portainer           | `portainer.midominio.com` | `http://portainer:9000`         |
| Jenkins             | `jenkins.midominio.com`   | `http://jenkins:8080`           |
| cAdvisor            | `cadvisor.midominio.com`  | `http://cadvisor:8080`          |

---

## 🚩 8️⃣ Resumen: ¿Qué expones al final?

| Puerto | Servicio            | Público |
| ------ | ------------------- | ------- |
| 80     | NGINX Proxy Manager | ✅       |
| 443    | NGINX Proxy Manager | ✅       |
| 22     | SSH                 | ✅       |
| Otros  | Todo lo demás       | 🚫      |

---

## 🚀 Resultado Esperado

✔️ Puertos cerrados, solo expuestos vía proxy controlado.
✔️ HTTPS válido en todo.
✔️ Paneles protegidos con credenciales fuertes y listas de acceso.
✔️ Acceso a backend vía red interna o VPN segura.
✔️ Backups y actualizaciones automatizadas.

---

## 🏁 Mantén este doc versionado ✅

* Actualiza este archivo cuando:

  * Agregues nuevos servicios.
  * Cambies dominios o redes.
  * Modifiques reglas de acceso.

---

**Fin.**
