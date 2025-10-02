#!/bin/sh
set -e

# Este script se ejecuta como root.
# Establece los permisos correctos para el directorio de datos de n8n,
# que podría ser un volumen montado desde el host.

echo "Entrypoint: Setting permissions for /home/n8n/.n8n..."
# Crea el directorio si no existe y establece la propiedad
mkdir -p /home/n8n/.n8n
chown -R n8n:n8n /home/n8n/.n8n
echo "Entrypoint: Permissions set."

# Abandona los privilegios y ejecuta el comando principal (CMD) como el usuario 'n8n'.
echo "Entrypoint: Dropping privileges and executing command: $@"
exec su-exec n8n "$@"