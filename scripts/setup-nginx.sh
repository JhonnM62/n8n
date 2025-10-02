#!/bin/bash

# Script para configurar Nginx y SSL para N8N
# Dominio: n8n.autosystemprojects.site

set -e

DOMAIN="n8n.autosystemprojects.site"
NGINX_CONF_PATH="/etc/nginx/sites-available/n8n"
NGINX_ENABLED_PATH="/etc/nginx/sites-enabled/n8n"
PROJECT_NGINX_CONF="./nginx/n8n.conf"
PROJECT_NGINX_TEMP_CONF="./nginx/n8n-temp.conf"

echo "🚀 Configurando Nginx para N8N en $DOMAIN..."

# Verificar si los archivos de configuración existen
if [ ! -f "$PROJECT_NGINX_CONF" ]; then
    echo "❌ Error: No se encuentra el archivo de configuración $PROJECT_NGINX_CONF"
    exit 1
fi

if [ ! -f "$PROJECT_NGINX_TEMP_CONF" ]; then
    echo "❌ Error: No se encuentra el archivo de configuración temporal $PROJECT_NGINX_TEMP_CONF"
    exit 1
fi

# Verificar si Nginx está instalado
if ! command -v nginx &> /dev/null; then
    echo "❌ Error: Nginx no está instalado"
    exit 1
fi

# Verificar si Certbot está instalado
if ! command -v certbot &> /dev/null; then
    echo "❌ Error: Certbot no está instalado"
    exit 1
fi

# Crear directorio para validación de Certbot
echo "📁 Creando directorio para validación de Certbot..."
sudo mkdir -p /var/www/html

# Crear backup de configuración existente si existe
if [ -f "$NGINX_CONF_PATH" ]; then
    echo "📋 Creando backup de configuración existente..."
    sudo cp "$NGINX_CONF_PATH" "$NGINX_CONF_PATH.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Paso 1: Usar configuración temporal sin SSL
echo "📝 Copiando configuración temporal de Nginx (sin SSL)..."
sudo cp "$PROJECT_NGINX_TEMP_CONF" "$NGINX_CONF_PATH"

# Verificar configuración temporal de Nginx
echo "🔍 Verificando configuración temporal de Nginx..."
if sudo nginx -t; then
    echo "✅ Configuración temporal de Nginx válida"
else
    echo "❌ Error en la configuración temporal de Nginx"
    exit 1
fi

# Habilitar sitio si no está habilitado
if [ ! -L "$NGINX_ENABLED_PATH" ]; then
    echo "🔗 Habilitando sitio en Nginx..."
    sudo ln -sf "$NGINX_CONF_PATH" "$NGINX_ENABLED_PATH"
fi

# Deshabilitar sitio por defecto si existe
if [ -L "/etc/nginx/sites-enabled/default" ]; then
    echo "🚫 Deshabilitando sitio por defecto..."
    sudo rm -f "/etc/nginx/sites-enabled/default"
fi

# Recargar Nginx con configuración temporal
echo "🔄 Recargando Nginx con configuración temporal..."
sudo systemctl reload nginx

# Paso 2: Obtener certificado SSL
echo "🔒 Configurando SSL con Certbot para $DOMAIN..."

# Verificar si ya existe certificado SSL
if [ -d "/etc/letsencrypt/live/$DOMAIN" ]; then
    echo "🔒 Certificado SSL ya existe para $DOMAIN"
    echo "🔄 Renovando certificado si es necesario..."
    sudo certbot renew --quiet
else
    echo "🔒 Obteniendo certificado SSL para $DOMAIN..."
    
    # Obtener certificado SSL con Certbot usando webroot
    sudo certbot certonly \
        --webroot \
        --webroot-path=/var/www/html \
        -d "$DOMAIN" \
        -d "www.$DOMAIN" \
        --non-interactive \
        --agree-tos \
        --email admin@autosystemprojects.site
    
    if [ $? -eq 0 ]; then
        echo "✅ Certificado SSL obtenido exitosamente"
    else
        echo "❌ Error al obtener certificado SSL"
        exit 1
    fi
fi

# Paso 3: Aplicar configuración completa con SSL
echo "📝 Aplicando configuración completa con SSL..."
sudo cp "$PROJECT_NGINX_CONF" "$NGINX_CONF_PATH"

# Verificar configuración final de Nginx
echo "🔍 Verificando configuración final de Nginx..."
if sudo nginx -t; then
    echo "✅ Configuración final de Nginx válida"
else
    echo "❌ Error en la configuración final de Nginx"
    exit 1
fi

# Recargar Nginx con configuración SSL
echo "🔄 Recargando Nginx con configuración SSL..."
sudo systemctl reload nginx

# Verificar que el servicio esté funcionando
echo "🔍 Verificando configuración final..."
if sudo nginx -t && sudo systemctl is-active --quiet nginx; then
    echo "✅ Nginx configurado correctamente"
    echo "🌐 El sitio debería estar disponible en: https://$DOMAIN"
else
    echo "❌ Error en la configuración final"
    exit 1
fi

# Configurar renovación automática de SSL
echo "⏰ Configurando renovación automática de SSL..."
(sudo crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet") | sudo crontab -

echo "🎉 ¡Configuración completada exitosamente!"
echo "📋 Resumen:"
echo "   - Dominio: https://$DOMAIN"
echo "   - Puerto interno: 8022"
echo "   - Configuración: $NGINX_CONF_PATH"
echo "   - SSL: Habilitado con renovación automática"
echo "   - Logs: /var/log/nginx/n8n_*.log"