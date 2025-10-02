# Configuración temporal de Nginx para N8N (sin SSL)
# Dominio: __DOMAIN__
# Puerto interno: __PORT__

# Configuración HTTP temporal para validación de Certbot
server {
    listen 80;
    listen [::]:80;
    server_name __DOMAIN__;

    # Configuración de logs
    access_log /var/log/nginx/n8n_access.log;
    error_log /var/log/nginx/n8n_error.log;

    # Permitir validación de Certbot
    location /.well-known/acme-challenge/ {
        root /var/www/html;
        try_files $uri $uri/ =404;
    }

    # Configuración de proxy para N8N
    location / {
        proxy_pass http://localhost:__PORT__;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;
        
        # Configuración para WebSockets (necesario para N8N)
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;
        proxy_send_timeout 86400;
        proxy_connect_timeout 86400;
        
        # Configuración de buffers
        proxy_buffering off;
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
    }

    # Configuración específica para webhooks de N8N
    location /webhook/ {
        proxy_pass http://localhost:__PORT__/webhook/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;
        
        # Sin timeout para webhooks
        proxy_read_timeout 0;
        proxy_send_timeout 0;
        proxy_connect_timeout 0;
    }

    # Configuración para archivos estáticos
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        proxy_pass http://localhost:__PORT__;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Cache para archivos estáticos
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Configuración para health check
    location /healthz {
        proxy_pass http://localhost:__PORT__/healthz;
        proxy_set_header Host $host;
        access_log off;
    }

    # Configuración de tamaño máximo de archivo
    client_max_body_size 100M;
    
    # Configuración de timeouts
    client_body_timeout 60s;
    client_header_timeout 60s;
    keepalive_timeout 65s;
    send_timeout 60s;
}