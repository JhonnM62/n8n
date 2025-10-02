# ========== DOCKERFILE SIMPLIFICADO PARA N8N ==========
# Usamos la imagen de Node.js 22 con Alpine para optimización
FROM node:22-alpine

# Argumento para el puerto, con un valor por defecto
ARG N8N_PORT=8022

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

# Exponemos el puerto configurado
EXPOSE $N8N_PORT

# Comando para iniciar n8n. No se usa entrypoint.
CMD [ "npm", "start" ]