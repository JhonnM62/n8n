# ========== DOCKERFILE MEJORADO PARA N8N ==========
# Usamos la imagen de Node.js 22 con Alpine para optimización
FROM node:22-alpine

# Información del mantenedor
LABEL maintainer="AutoSystemProjects"
LABEL description="N8N Workflow Automation - Secure & Production-Ready"

# Instalar dependencias del sistema, incluyendo su-exec para manejo de permisos
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    git \
    curl \
    sqlite \
    su-exec \
    && rm -rf /var/cache/apk/*

# Crear usuario y grupo no-root para n8n
RUN addgroup -g 1000 n8n && \
    adduser -u 1000 -G n8n -h /home/n8n -s /bin/sh -D n8n

# Crear directorios necesarios y establecer permisos
# Directorio de datos de n8n y directorio de la aplicación
RUN mkdir -p /home/n8n/.n8n /app/logs && \
    chown -R n8n:n8n /home/n8n/.n8n /app /app/logs

# Establecemos el directorio de trabajo
WORKDIR /app

# Copiamos los archivos de manifiesto y damos permisos
COPY package.json package-lock.json ./
RUN chown n8n:n8n package.json package-lock.json

# Cambiamos al usuario n8n para instalar dependencias
USER n8n

# Instalamos únicamente las dependencias de producción
RUN npm install --only=production && \
    npm cache clean --force

# Volvemos a ser root para copiar el resto de los archivos
USER root

# Copiamos el código fuente y el entrypoint
COPY . .
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    chown -R n8n:n8n /app

# Cambiamos al usuario n8n para la ejecución final
USER n8n

# Exponemos el puerto configurado
EXPOSE 8022

# Healthcheck para verificar que n8n esté funcionando
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8022/healthz || exit 1

# Entrypoint para configurar permisos antes de iniciar
ENTRYPOINT ["docker-entrypoint.sh"]

# Comando por defecto para iniciar n8n
CMD [ "npm", "start" ]