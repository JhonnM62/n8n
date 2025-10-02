#!/bin/bash

# Script para configurar SSL con Certbot para n8n
# Uso: ./setup-ssl.sh [dominio] [email]

set -e

# Configuración por defecto
DEFAULT_DOMAIN="n8n.autosystemprojects.site"
DEFAULT_EMAIL="admin@autosystemprojects.site"

# Obtener parámetros
DOMAIN=${1:-$DEFAULT_DOMAIN}
EMAIL=${2:-$DEFAULT_EMAIL}

echo "🔧 Configurando SSL para n8n..."
echo "Dominio: $DOMAIN"
echo "Email: $EMAIL"

# Verificar si certbot está instalado
if ! command -v certbot &> /dev/null; then
    echo "📦 Instalando Certbot..."
    sudo apt update
    sudo apt install -y certbot python3-certbot-nginx
fi

# Verificar si nginx está instalado
if ! command -v nginx &> /dev/null; then
    echo "📦 Instalando Nginx..."
    sudo apt update
    sudo apt install -y nginx
fi

# Crear configuración temporal de nginx sin SSL
echo "📝 Creando configuración temporal de Nginx..."
sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN;
    
    location / {
        proxy_pass http://localhost:8017;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # Para validación de Let's Encrypt
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
}
EOF

# Habilitar el sitio
sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Verificar configuración de nginx
echo "🔍 Verificando configuración de Nginx..."
sudo nginx -t

# Recargar nginx
echo "🔄 Recargando Nginx..."
sudo systemctl reload nginx

# Obtener certificado SSL
echo "🔐 Obteniendo certificado SSL..."
sudo certbot --nginx -d $DOMAIN --email $EMAIL --agree-tos --non-interactive --redirect

# Copiar configuración final con SSL
echo "📝 Aplicando configuración final de Nginx..."
sudo cp /opt/n8n/nginx/n8n.conf /etc/nginx/sites-available/$DOMAIN

# Actualizar el server_name en la configuración
sudo sed -i "s/n8n\.autosystemprojects\.site/$DOMAIN/g" /etc/nginx/sites-available/$DOMAIN
sudo sed -i "s/\/etc\/letsencrypt\/live\/n8n\.autosystemprojects\.site/\/etc\/letsencrypt\/live\/$DOMAIN/g" /etc/nginx/sites-available/$DOMAIN

# Verificar configuración final
echo "🔍 Verificando configuración final..."
sudo nginx -t

# Recargar nginx con la configuración final
echo "🔄 Aplicando configuración final..."
sudo systemctl reload nginx

# Configurar renovación automática
echo "⏰ Configurando renovación automática..."
sudo crontab -l 2>/dev/null | grep -v certbot | sudo crontab -
(sudo crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet --nginx") | sudo crontab -

# Verificar estado del servicio
echo "✅ Verificando servicios..."
sudo systemctl status nginx --no-pager -l
sudo systemctl status certbot.timer --no-pager -l || echo "⚠️  Timer de certbot no disponible, usando cron"

echo ""
echo "🎉 ¡SSL configurado exitosamente!"
echo "🌐 Tu sitio n8n está disponible en: https://$DOMAIN"
echo "🔐 Certificado SSL válido por 90 días"
echo "⏰ Renovación automática configurada"
echo ""
echo "📋 Comandos útiles:"
echo "  - Verificar certificado: sudo certbot certificates"
echo "  - Renovar manualmente: sudo certbot renew"
echo "  - Ver logs de nginx: sudo tail -f /var/log/nginx/n8n.*.log"
echo "  - Reiniciar nginx: sudo systemctl restart nginx"