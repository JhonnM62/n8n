# ========== DOCKERFILE PARA N8N ==========
# Imagen base de Node.js 20 con Alpine para optimización
FROM node:20-alpine

# Establecer directorio de trabajo
WORKDIR /app

# Instalar dependencias del sistema necesarias para n8n
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    cairo-dev \
    jpeg-dev \
    pango-dev \
    giflib-dev \
    librsvg-dev \
    pixman-dev

# Crear usuario no-root para seguridad
RUN addgroup -g 1001 -S n8nuser && \
    adduser -S n8nuser -u 1001 -G n8nuser

# Copiar archivos de dependencias
COPY package.json package-lock.json ./

# Instalar dependencias de n8n
RUN npm ci --only=production && \
    npm cache clean --force

# Copiar código fuente de la aplicación
COPY . .

# Crear directorios necesarios para n8n
RUN mkdir -p /app/data /app/logs && \
    chown -R n8nuser:n8nuser /app

# Cambiar al usuario no-root
USER n8nuser

# Variables de entorno por defecto
ENV NODE_ENV=production
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=http
ENV DB_TYPE=sqlite
ENV DB_SQLITE_DATABASE=/app/data/n8n.db
ENV N8N_USER_FOLDER=/app/data
ENV N8N_LOG_LEVEL=info
ENV N8N_LOG_OUTPUT=file
ENV N8N_LOG_FILE_LOCATION=/app/logs

# Exponer puerto de n8n
EXPOSE 5678

# Comando de inicio
CMD ["npm", "start"]