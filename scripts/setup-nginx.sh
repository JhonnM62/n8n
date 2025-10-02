#!/bin/bash

# Script para configurar Nginx y SSL para N8N
# Dominio: n8n.autosystemprojects.site

set -e

DOMAIN="n8n.autosystemprojects.site"
NGINX_CONF_PATH="/etc/nginx/sites-available/n8n"
NGINX_ENABLED_PATH="/etc/nginx/sites-enabled/n8n"
PROJECT_NGINX_CONF="./nginx/n8n.conf"

echo "🚀 Configurando Nginx para N8N en $DOMAIN..."

# Verificar si el archivo de configuración existe
if [ ! -f "$PROJECT_NGINX_CONF" ]; then
    echo "❌ Error: No se encuentra el archivo de configuración $PROJECT_NGINX_CONF"
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

# Crear backup de configuración existente si existe
if [ -f "$NGINX_CONF_PATH" ]; then
    echo "📋 Creando backup de configuración existente..."
    sudo cp "$NGINX_CONF_PATH" "$NGINX_CONF_PATH.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Copiar configuración de Nginx
echo "📝 Copiando configuración de Nginx..."
sudo cp "$PROJECT_NGINX_CONF" "$NGINX_CONF_PATH"

# Verificar configuración de Nginx
echo "🔍 Verificando configuración de Nginx..."
if sudo nginx -t; then
    echo "✅ Configuración de Nginx válida"
else
    echo "❌ Error en la configuración de Nginx"
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

# Recargar Nginx
echo "🔄 Recargando Nginx..."
sudo systemctl reload nginx

# Verificar si ya existe certificado SSL
if [ -d "/etc/letsencrypt/live/$DOMAIN" ]; then
    echo "🔒 Certificado SSL ya existe para $DOMAIN"
    echo "🔄 Renovando certificado si es necesario..."
    sudo certbot renew --quiet
else
    echo "🔒 Obteniendo certificado SSL para $DOMAIN..."
    
    # Obtener certificado SSL con Certbot
    sudo certbot --nginx -d "$DOMAIN" -d "www.$DOMAIN" \
        --non-interactive \
        --agree-tos \
        --email admin@autosystemprojects.site \
        --redirect
    
    if [ $? -eq 0 ]; then
        echo "✅ Certificado SSL obtenido exitosamente"
    else
        echo "❌ Error al obtener certificado SSL"
        exit 1
    fi
fi

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