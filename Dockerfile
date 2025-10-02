# ========== DOCKERFILE SIMPLIFICADO PARA N8N ==========
# Usamos la imagen de Node.js 22 con Alpine para optimización
FROM node:22-alpine

# Información del mantenedor
LABEL maintainer="AutoSystemProjects"
LABEL description="N8N Workflow Automation - Simplified"

# Establecemos el directorio de trabajo dentro del contenedor
WORKDIR /app

# Instalar dependencias del sistema necesarias para n8n
# su-exec y el usuario no-root se eliminan para simplificar
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    git \
    curl \
    sqlite \
    && rm -rf /var/cache/apk/*

# Copiamos los archivos de manifiesto para instalar las dependencias
COPY package.json package-lock.json ./

# Instalamos únicamente las dependencias de producción
RUN npm install --only=production && \
    npm cache clean --force

# Copiamos todo el código fuente de la aplicación
COPY . .

# Variables de entorno para n8n (ajustadas a la nueva estructura)
ENV NODE_ENV=production
ENV N8N_PORT=8022
ENV N8N_HOST=0.0.0.0
ENV N8N_PROTOCOL=http
ENV WEBHOOK_URL=https://n8n.autosystemprojects.site/
ENV N8N_EDITOR_BASE_URL=https://n8n.autosystemprojects.site/
ENV GENERIC_TIMEZONE=America/Mexico_City
ENV TZ=America/Mexico_City
ENV DB_TYPE=sqlite
# Los datos de usuario ahora estarán dentro de /app/.n8n
ENV N8N_USER_FOLDER=/app/.n8n
ENV DB_SQLITE_POOL_SIZE=10
ENV N8N_SECURE_COOKIE=true
ENV N8N_ENCRYPTION_KEY=n8n-default-key-change-me
ENV N8N_LOG_LEVEL=info
ENV N8N_LOG_OUTPUT=file
# Los logs ahora estarán dentro de /app/logs
ENV N8N_LOG_FILE_LOCATION=/app/logs/
ENV N8N_RUNNERS_ENABLED=true

# Exponemos el puerto configurado
EXPOSE 8022

# Healthcheck para verificar que n8n esté funcionando
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8022/healthz || exit 1

# Comando para iniciar n8n. No se usa entrypoint.
CMD [ "npm", "start" ]