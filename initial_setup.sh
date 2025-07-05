#!/bin/bash

set -e

# Crear red externa si no existe
NETWORK_NAME="skycloud"
if ! docker network ls --format '{{.Name}}' | grep -qw "$NETWORK_NAME"; then
  echo "Creando red externa: $NETWORK_NAME"
  docker network create "$NETWORK_NAME"
else
  echo "La red $NETWORK_NAME ya existe."
fi

echo "Configuración inicial completada."
echo "Asegúrate de tener tu archivo .env configurado antes de ejecutar:"
echo "  docker compose up -d"
