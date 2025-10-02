# ========== DOCKERFILE PARA N8N ==========
# Usamos la imagen oficial de Node.js 22 (más actual) con Alpine para optimización
FROM node:22-alpine

# Información del mantenedor
LABEL maintainer="AutoSystemProjects"
LABEL description="N8N Workflow Automation - Production Ready"

# Establecer directorio de trabajo
WORKDIR /app

# Instalar dependencias del sistema necesarias para n8n
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    git \
    curl \
    sqlite \
    && rm -rf /var/cache/apk/*

# Crear usuario no-root para seguridad
RUN addgroup -g 1001 -S n8n && \
    adduser -S n8n -u 1001 -G n8n

# Copiar archivos de dependencias
COPY package.json package-lock.json ./

# Instalar dependencias de producción
RUN npm ci --only=production && \
    npm cache clean --force

# Copiar el código fuente de la aplicación
COPY . .

# Crear directorios necesarios para n8n
RUN mkdir -p /app/data /app/logs && \
    chown -R n8n:n8n /app

# Variables de entorno para n8n
ENV NODE_ENV=production
ENV N8N_PORT=8022
ENV N8N_HOST=0.0.0.0
ENV N8N_PROTOCOL=http
ENV WEBHOOK_URL=https://www.n8n.autosystemprojects.site/
ENV N8N_EDITOR_BASE_URL=https://www.n8n.autosystemprojects.site/
ENV GENERIC_TIMEZONE=America/Mexico_City
ENV TZ=America/Mexico_City

# Configuración de base de datos SQLite
ENV DB_TYPE=sqlite
ENV N8N_USER_FOLDER=/home/n8n/.n8n
ENV DB_SQLITE_DATABASE=/home/n8n/.n8n/database.sqlite
ENV DB_SQLITE_POOL_SIZE=10

# Configuración de seguridad
ENV N8N_SECURE_COOKIE=true
ENV N8N_ENCRYPTION_KEY=n8n-default-key-change-me

# Configuración de logs
ENV N8N_LOG_LEVEL=info
ENV N8N_LOG_OUTPUT=file
ENV N8N_LOG_FILE_LOCATION=/app/logs/

# Configuración de runners (nueva versión)
ENV N8N_RUNNERS_ENABLED=true

# Cambiar al usuario no-root
USER n8n

# Exponer el puerto configurado
EXPOSE 8022

# Crear volúmenes para persistencia de datos
VOLUME ["/app/data", "/app/logs"]

# Healthcheck para verificar que n8n esté funcionando
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8022/healthz || exit 1

# Comando para iniciar n8n
CMD ["npm", "start"]