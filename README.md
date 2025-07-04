# SkyCloud DevOps Stack

Este proyecto proporciona una infraestructura lista para desarrollo y despliegue de servicios modernos, usando Docker Compose. Incluye bases de datos, herramientas de administración, mensajería, proxy reverso y un entorno de CI/CD autoalojado.

---

## Objetivo

**SkyCloud** busca facilitar la gestión y despliegue de aplicaciones y microservicios, integrando servicios esenciales para desarrollo, pruebas y producción en un solo entorno reproducible.

---

## Servicios incluidos

- **MySQL**: Base de datos relacional.
- **MongoDB**: Base de datos NoSQL.
- **DbGate**: Interfaz web para administrar bases de datos.
- **RabbitMQ**: Broker de mensajería.
- **Nginx Proxy Manager**: Proxy reverso y gestión de certificados SSL.
- **Portainer**: Administración visual de contenedores Docker.
- **Jenkins**: Servidor de CI/CD autoalojado (con Docker y kubectl integrados).

---

## Estructura de carpetas y archivos

```
.
├── README.md
├── .gitignore
├── docker-compose.yml
├── initial_setup.sh
├── jenkins/
│   └── Dockerfile
├── scripts/
│   └── volumes_backup.sh
└── .git/
```

---

## Requisitos previos

- Docker y Docker Compose instalados.
- Acceso a la terminal con permisos de administrador.
- (Opcional) Archivo `.env` configurado con tus credenciales y variables de entorno.

---

## Pasos para la configuración inicial

1. **Clona este repositorio:**
   ```bash
   git clone https://github.com/tuusuario/skycloud.git
   cd skycloud
   ```

2. **Crea la red externa (solo la primera vez):**
   ```bash
   ./initial_setup.sh
   ```
   > Si no tienes el script, puedes crear la red manualmente:
   > ```bash
   > docker network create steampunker
   > ```

3. **Configura tus variables de entorno:**
   - Crea un archivo `.env` en la raíz del proyecto con las credenciales necesarias (ver ejemplo en la documentación).

4. **Levanta los servicios:**
   ```bash
   docker compose up -d
   ```

5. **Accede a los servicios (reemplaza `IP_DEL_HOST` por la IP real de tu servidor):**
   - Jenkins: http://IP_DEL_HOST:8080
   - Portainer: http://IP_DEL_HOST:9000
   - DbGate: http://IP_DEL_HOST:8082
   - Nginx Proxy Manager: http://IP_DEL_HOST:81
   - RabbitMQ: http://IP_DEL_HOST:15672

---

## Backup y restauración de volúmenes

Para respaldar los datos de tus servicios, puedes usar el script incluido:

```bash
./scripts/volumes_backup.sh
```
> Cambia el script según tus necesidades para respaldar/restaurar volúmenes específicos.

---

## Recomendaciones de seguridad

- **No subas tu archivo `.env`** al repositorio.
- Cambia todas las contraseñas por defecto antes de exponer los servicios a internet.
- Limita el acceso a los puertos de administración desde redes seguras.
- Realiza backups periódicos de los volúmenes de datos.

---

## Personalización

Puedes agregar más servicios (por ejemplo, un registry privado de Docker, un servidor npm privado, etc.) editando el archivo `docker-compose.yml` y agregando los Dockerfiles o scripts necesarios en las carpetas correspondientes.

---

## Licencia

MIT

---

## Autor

Luisma
