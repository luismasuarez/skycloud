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
├── env.example
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

## Despliegue en VPS/Droplet (DigitalOcean, AWS, etc.)

### 1. Preparación del servidor

#### Instalar Docker y Docker Compose
```bash
# Actualizar el sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependencias
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Agregar la clave GPG oficial de Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Agregar el repositorio de Docker
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Agregar usuario al grupo docker
sudo usermod -aG docker $USER
```

#### Configurar firewall (UFW)
```bash
# Instalar UFW si no está instalado
sudo apt install -y ufw

# Configurar reglas básicas
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Permitir SSH (cambia 22 por tu puerto SSH si es diferente)
sudo ufw allow ssh

# Permitir puertos de servicios (opcional, para acceso directo)
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw allow 8080/tcp # Jenkins
sudo ufw allow 9000/tcp # Portainer
sudo ufw allow 8082/tcp # DbGate
sudo ufw allow 81/tcp   # Nginx Proxy Manager

# Activar firewall
sudo ufw enable
```

### 2. Configuración del proyecto

#### Clonar el repositorio
```bash
git clone https://github.com/luismasuarez/skycloud.git
cd skycloud
```

#### Configurar variables de entorno
```bash
# Copiar el archivo de ejemplo
cp env.example .env

# Editar las variables con contraseñas seguras
nano .env
```

**Variables importantes a configurar:**
- `MYSQL_ROOT_PASSWORD`: Contraseña segura para MySQL root
- `MYSQL_PASSWORD`: Contraseña para el usuario de aplicación
- `MONGODB_ROOT_PASSWORD`: Contraseña segura para MongoDB
- `RABBITMQ_PASS`: Contraseña segura para RabbitMQ

#### Crear la red de Docker
```bash
./initial_setup.sh
```

### 3. Despliegue inicial

```bash
# Levantar todos los servicios
docker compose up -d

# Verificar que todos los servicios estén corriendo
docker compose ps
```

### 4. Configuración de dominio y SSL

#### Configurar DNS
1. En tu proveedor de DNS, crea registros A apuntando a la IP de tu VPS:
   - `skycloud.tudominio.com` → IP_DEL_VPS
   - `jenkins.tudominio.com` → IP_DEL_VPS
   - `portainer.tudominio.com` → IP_DEL_VPS

#### Configurar Nginx Proxy Manager
1. Accede a http://IP_DEL_VPS:81
2. Credenciales por defecto:
   - Email: `admin@example.com`
   - Password: `changeme`
3. Cambia la contraseña inmediatamente
4. Configura los proxy hosts para tus dominios:
   - Jenkins: `jenkins.tudominio.com` → `localhost:8080`
   - Portainer: `portainer.tudominio.com` → `localhost:9000`
   - DbGate: `dbgate.tudominio.com` → `localhost:8082`

### 5. Configuración de Jenkins

1. Accede a Jenkins: http://jenkins.tudominio.com
2. Obtén la contraseña inicial:
   ```bash
   docker compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
   ```
3. Instala los plugins recomendados
4. Crea un usuario administrador
5. Configura Jenkins para usar Docker:
   - Ve a "Manage Jenkins" → "Configure System"
   - Busca "Docker" y configura la conexión al socket de Docker

### 6. Configuración de seguridad adicional

#### Restringir acceso a puertos de administración
```bash
# Editar docker-compose.yml y comentar los puertos de administración
# Solo mantener los puertos necesarios para el proxy reverso
```

#### Configurar backups automáticos
```bash
# Crear un cron job para backups diarios
crontab -e

# Agregar esta línea para backup diario a las 2 AM
0 2 * * * /ruta/completa/a/skycloud/scripts/volumes_backup.sh
```

#### Monitoreo básico
```bash
# Instalar htop para monitoreo del sistema
sudo apt install -y htop

# Ver logs de los servicios
docker compose logs -f [nombre_servicio]
```

---

## Acceso a los servicios

Una vez configurado el proxy reverso, accede a través de tus dominios:
- **Jenkins**: https://jenkins.tudominio.com
- **Portainer**: https://portainer.tudominio.com
- **DbGate**: https://dbgate.tudominio.com
- **Nginx Proxy Manager**: https://npm.tudominio.com

---

## Mantenimiento

### Actualizar servicios
```bash
# Detener servicios
docker compose down

# Actualizar imágenes
docker compose pull

# Levantar servicios
docker compose up -d
```

### Backup y restauración
```bash
# Backup manual
./scripts/volumes_backup.sh

# Restaurar desde backup
docker compose down
# Copiar archivos de backup a los volúmenes
docker compose up -d
```

### Logs y troubleshooting
```bash
# Ver logs de todos los servicios
docker compose logs

# Ver logs de un servicio específico
docker compose logs jenkins

# Ver logs en tiempo real
docker compose logs -f
```

---

## Recomendaciones de seguridad

- **Cambia todas las contraseñas por defecto** antes de exponer a internet
- **Configura un firewall** (UFW) para restringir acceso
- **Usa HTTPS** para todos los servicios
- **Realiza backups periódicos** de los volúmenes
- **Monitorea los logs** regularmente
- **Mantén el sistema actualizado** con `apt update && apt upgrade`
- **Considera usar un VPN** para acceso administrativo
- **Configura alertas** para uso de recursos y errores

---

## Personalización

Puedes agregar más servicios editando el archivo `docker-compose.yml`:
- Registry privado de Docker
- Servidor npm privado
- GitLab/Gitea para repositorios
- Prometheus/Grafana para monitoreo
- ELK Stack para logs

---

## Licencia

MIT

---

## Autor

Luisma
