#!/bin/bash

# Script para configurar Nginx y SSL para N8N
# Uso:
#   - DOMAIN=your.domain.com PORT=8022 ./setup-nginx.sh
#   - Si no se proporcionan, se usarán valores por defecto.

set -e

# 1. Configuración de variables (requeridas)
if [ -z "$DOMAIN" ]; then
    echo "❌ Error: La variable DOMAIN es requerida"
    exit 1
fi

if [ -z "$PORT" ]; then
    echo "❌ Error: La variable PORT es requerida"
    exit 1
fi

if [ -z "$EMAIL" ]; then
    echo "❌ Error: La variable EMAIL es requerida"
    exit 1
fi

NGINX_CONF_PATH="/etc/nginx/sites-available/$DOMAIN"
NGINX_ENABLED_PATH="/etc/nginx/sites-enabled/$DOMAIN"
NGINX_TEMP_CONF_PATH="/etc/nginx/sites-available/$DOMAIN-temp"
NGINX_TEMP_ENABLED_PATH="/etc/nginx/sites-enabled/$DOMAIN-temp"
PROJECT_NGINX_TEMP_CONF_TPL="./templates/n8n-temp.conf.tpl"
PROJECT_NGINX_CONF_TPL="./templates/n8n.conf.tpl"
GENERATED_TEMP_CONF="./nginx/$DOMAIN-temp.conf"
GENERATED_CONF="./nginx/$DOMAIN.conf"

echo "🚀 Configurando Nginx para N8N en $DOMAIN en el puerto $PORT..."

# 2. Validaciones previas
# Verificar si las plantillas de configuración existen
if [ ! -f "$PROJECT_NGINX_CONF_TPL" ] || [ ! -f "$PROJECT_NGINX_TEMP_CONF_TPL" ]; then
    echo "❌ Error: No se encuentran los archivos de plantilla .tpl"
    exit 1
fi

# Verificar si Nginx y Certbot están instalados
if ! command -v nginx &> /dev/null || ! command -v certbot &> /dev/null; then
    echo "❌ Error: Nginx o Certbot no están instalados."
    exit 1
fi

# 3. Generar configuraciones a partir de plantillas
echo "📝 Generando archivos de configuración a partir de plantillas..."
sed "s/__DOMAIN__/$DOMAIN/g; s/__PORT__/$PORT/g" "$PROJECT_NGINX_TEMP_CONF_TPL" > "$GENERATED_TEMP_CONF"
sed "s/__DOMAIN__/$DOMAIN/g; s/__PORT__/$PORT/g" "$PROJECT_NGINX_CONF_TPL" > "$GENERATED_CONF"
echo "✅ Archivos de configuración generados."

# 4. Configuración de Nginx y SSL
# Crear directorio para validación de Certbot
sudo mkdir -p /var/www/html

# Backup de configuración existente
if [ -f "$NGINX_CONF_PATH" ]; then
    echo "📋 Creando backup de la configuración de Nginx existente..."
    sudo cp "$NGINX_CONF_PATH" "$NGINX_CONF_PATH.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Copiar configuración temporal para la validación de SSL
echo "🔄 Copiando configuración temporal de Nginx..."
sudo cp "$GENERATED_TEMP_CONF" "$NGINX_TEMP_CONF_PATH"

# Habilitar el sitio temporal y deshabilitar el sitio por defecto
sudo ln -sf "$NGINX_TEMP_CONF_PATH" "$NGINX_TEMP_ENABLED_PATH"
[ -L "/etc/nginx/sites-enabled/default" ] && sudo rm -f "/etc/nginx/sites-enabled/default"

# Verificar y recargar Nginx
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo "✅ Nginx recargado con configuración temporal."
else
    echo "❌ Error en la configuración temporal de Nginx."
    sudo cat "$NGINX_TEMP_CONF_PATH" # Muestra la configuración generada para depuración
    exit 1
fi

# 5. Obtención o renovación de certificado SSL
if [ -d "/etc/letsencrypt/live/$DOMAIN" ]; then
    echo "🔄 Certificado SSL ya existe. Renovando si es necesario..."
    sudo certbot renew --quiet
else
    echo "🔒 Obteniendo nuevo certificado SSL para $DOMAIN..."
    sudo certbot certonly \
        --webroot \
        --webroot-path=/var/www/html \
        -d "$DOMAIN" \
        --non-interactive \
        --agree-tos \
        --email "$EMAIL"
fi

# 6. Aplicar configuración final con SSL
echo "✨ Aplicando configuración final de Nginx con SSL..."
sudo cp "$GENERATED_CONF" "$NGINX_CONF_PATH"

# Remover configuración temporal y habilitar la final
sudo rm -f "$NGINX_TEMP_ENABLED_PATH"
sudo ln -sf "$NGINX_CONF_PATH" "$NGINX_ENABLED_PATH"

# Verificar y recargar Nginx por última vez
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo "✅ Nginx recargado con configuración SSL."
else
    echo "❌ Error en la configuración final de Nginx."
    sudo cat "$NGINX_CONF_PATH" # Muestra la configuración generada para depuración
    exit 1
fi

# 7. Configurar renovación automática de SSL
echo "⏰ Configurando renovación automática de SSL..."
(sudo crontab -l 2>/dev/null | grep -v "certbot renew" || true; echo "0 12 * * * /usr/bin/certbot renew --quiet") | sudo crontab -

# 8. Resumen final
echo "🎉 ¡Configuración de Nginx completada exitosamente!"
echo "   - Dominio: https://$DOMAIN"
echo "   - Puerto interno de N8N: $PORT"
echo "   - Email de Let's Encrypt: $EMAIL"
echo "   - Logs: /var/log/nginx/${DOMAIN}_*.log"

# 9. Limpieza de archivos temporales
echo "🧹 Limpiando archivos de configuración generados..."
rm -f "$GENERATED_TEMP_CONF"
rm -f "$GENERATED_CONF"

# Limpiar archivos temporales de Nginx en /etc/nginx/sites-available/
echo "🧹 Limpiando archivos temporales de Nginx..."
sudo rm -f "$NGINX_TEMP_CONF_PATH"
sudo rm -f "$NGINX_TEMP_ENABLED_PATH"

echo "✅ Limpieza completada."