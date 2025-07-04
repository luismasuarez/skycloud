#!/bin/bash
BACKUP_DIR=./docker_backups
mkdir -p $BACKUP_DIR

for volume in $(docker volume ls -q); do
  echo "Respaldando $volume..."
  docker run --rm \
    -v $volume:/volume \
    -v $BACKUP_DIR:/backup \
    alpine \
    tar czf /backup/${volume}_backup.tar.gz -C /volume .
done