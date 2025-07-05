#!/bin/bash

set -e

echo "🚀 SkyCloud VPS Deployment Script"
echo "=================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir mensajes con colores
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar si estamos ejecutando como root
if [[ $EUID -eq 0 ]]; then
   print_error "Este script no debe ejecutarse como root. Usa un usuario con sudo."
   exit 1
fi

print_status "Verificando requisitos del sistema..."

# Verificar sistema operativo
if [[ ! -f /etc/os-release ]]; then
    print_error "No se pudo detectar el sistema operativo"
    exit 1
fi

source /etc/os-release
if [[ "$ID" != "ubuntu" && "$ID" != "debian" ]]; then
    print_warning "Este script está optimizado para Ubuntu/Debian. Otros sistemas pueden requerir ajustes."
fi

# Actualizar sistema
print_status "Actualizando el sistema..."
sudo apt update && sudo apt upgrade -y

# Instalar dependencias básicas
print_status "Instalando dependencias..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common git

# Instalar Docker
print_status "Instalando Docker..."
if ! command -v docker &> /dev/null; then
    # Agregar clave GPG de Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Agregar repositorio de Docker
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Instalar Docker
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io

    # Agregar usuario al grupo docker
    sudo usermod -aG docker $USER
    print_status "Docker instalado. Necesitarás cerrar sesión y volver a entrar para que los cambios surtan efecto."
else
    print_status "Docker ya está instalado."
fi

# Instalar Docker Compose
print_status "Instalando Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
else
    print_status "Docker Compose ya está instalado."
fi

# Configurar firewall
print_status "Configurando firewall (UFW)..."
sudo apt install -y ufw

# Configurar reglas básicas
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Permitir SSH
sudo ufw allow ssh

# Permitir puertos de servicios
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw allow 8080/tcp # Jenkins
sudo ufw allow 9000/tcp # Portainer
sudo ufw allow 8082/tcp # DbGate
sudo ufw allow 81/tcp   # Nginx Proxy Manager

# Activar firewall
echo "y" | sudo ufw enable

print_status "Firewall configurado y activado."

# Verificar si el proyecto ya existe
if [[ -d "skycloud" ]]; then
    print_warning "El directorio skycloud ya existe. ¿Quieres actualizarlo? (y/n)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        cd skycloud
        git pull
    else
        print_status "Saltando actualización del repositorio."
    fi
else
    print_status "Clonando repositorio SkyCloud..."
    git clone https://github.com/tuusuario/skycloud.git
    cd skycloud
fi

# Configurar variables de entorno
if [[ ! -f ".env" ]]; then
    print_status "Configurando variables de entorno..."
    if [[ -f "env.example" ]]; then
        cp env.example .env
        print_warning "Archivo .env creado desde env.example. Por favor, edita las contraseñas antes de continuar."
        print_status "Puedes editar el archivo con: nano .env"
        read -p "Presiona Enter cuando hayas configurado las contraseñas..."
    else
        print_error "No se encontró env.example. Por favor, crea el archivo .env manualmente."
        exit 1
    fi
else
    print_status "Archivo .env ya existe."
fi

# Crear red de Docker
print_status "Configurando red de Docker..."
./initial_setup.sh

# Levantar servicios
print_status "Levantando servicios..."
docker compose up -d

# Verificar estado de los servicios
print_status "Verificando estado de los servicios..."
sleep 10
docker compose ps

print_status "🎉 ¡Despliegue completado!"
echo ""
echo "📋 Próximos pasos:"
echo "1. Configura tu dominio DNS para apuntar a esta IP: $(curl -s ifconfig.me)"
echo "2. Accede a Nginx Proxy Manager: http://$(curl -s ifconfig.me):81"
echo "   - Email: admin@example.com"
echo "   - Password: changeme"
echo "3. Configura los proxy hosts para tus dominios"
echo "4. Accede a Jenkins: http://$(curl -s ifconfig.me):8080"
echo "5. Obtén la contraseña inicial de Jenkins:"
echo "   docker compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
echo ""
echo "🔒 Recomendaciones de seguridad:"
echo "- Cambia todas las contraseñas por defecto"
echo "- Configura SSL para todos los servicios"
echo "- Realiza backups periódicos"
echo "- Monitorea los logs regularmente"