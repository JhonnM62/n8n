# N8N - Pipeline de CI/CD y Configuración de Despliegue

## 📋 Descripción General

Este proyecto implementa un pipeline completo de CI/CD para N8N (Workflow Automation) con despliegue automático en VPS, configuración de Nginx, SSL con Certbot y gestión de contenedores Docker.

## 🚀 Características del Pipeline

### ✅ Funcionalidades Implementadas

- **Construcción automática de imágenes Docker** con Node.js 22
- **Despliegue automático en VPS** via SSH
- **Configuración automática de Nginx** para nuevos dominios
- **Certificados SSL automáticos** con Certbot
- **Gestión de volúmenes Docker** para persistencia de datos
- **Soporte para múltiples puertos y dominios**
- **Contenedores únicos** para cada despliegue
- **Health checks** y monitoreo de contenedores

## 🔧 Configuración Requerida

### Variables de GitHub Actions

Asegúrate de tener configuradas estas variables en tu repositorio:

#### Secrets Requeridos:
- `ENV_FILE_CONTENT`: Contenido del archivo .env con configuraciones de N8N
- `AUTH_PASS`: Token de GitHub o contraseña del servidor VPS
- `AUTH_SERVER`: IP o hostname del servidor VPS

### Variables de Entorno por Defecto:
- **Puerto**: `8022` (configurable)
- **Dominio**: `n8n.autosystemprojects.site` (configurable)

## 📁 Estructura del Proyecto

```
n8n/
├── .github/
│   └── workflows/
│       └── publish.yml          # Pipeline principal de CI/CD
├── nginx/
│   └── n8n.conf                # Configuración de Nginx (referencia)
├── scripts/
│   └── setup-nginx.sh          # Script de configuración manual
├── Dockerfile                   # Imagen Docker optimizada
├── package.json                # Dependencias de Node.js
└── README-DEPLOYMENT.md        # Esta documentación
```

## 🎯 Uso del Pipeline

### Despliegue Manual

1. **Ir a Actions** en tu repositorio de GitHub
2. **Seleccionar** "Deploy N8N Automation"
3. **Configurar parámetros** (opcional):
   - Puerto: `8022` (por defecto)
   - Dominio: `n8n.autosystemprojects.site` (por defecto)
4. **Ejecutar** el workflow

### Despliegue Automático

El pipeline se ejecuta automáticamente en:
- **Push a main/master**
- **Pull requests**
- **Releases**

## 🔄 Proceso de Despliegue

### Fase 1: Construcción de Imagen
1. ✅ Checkout del código
2. ✅ Configuración de parámetros
3. ✅ Login en GitHub Container Registry
4. ✅ Generación de archivo .env
5. ✅ Construcción y subida de imagen Docker

### Fase 2: Despliegue en VPS
1. ✅ Conexión SSH al servidor
2. ✅ Configuración automática de Nginx (si no existe)
3. ✅ Configuración de SSL con Certbot (si no existe)
4. ✅ Creación de volúmenes Docker
5. ✅ Detención de contenedores anteriores en el mismo puerto
6. ✅ Despliegue del nuevo contenedor
7. ✅ Verificación de salud del contenedor

## 🐳 Configuración Docker

### Imagen Base
- **Node.js 22** con Alpine Linux
- **Usuario no-root** para seguridad
- **Dependencias optimizadas** para producción
- **Health checks** integrados

### Volúmenes
- `n8n_data_{PORT}`: Datos persistentes de N8N
- Configuración `.env` montada como solo lectura

### Puertos
- **Interno**: `8001` (dentro del contenedor)
- **Externo**: Configurable (por defecto `8022`)

## 🌐 Configuración de Nginx

### Características
- **Redirección HTTP → HTTPS** automática
- **Soporte para WebSockets** (N8N workflows)
- **Configuración de webhooks** optimizada
- **Headers de seguridad** implementados
- **Logs separados** por dominio
- **Health checks** configurados

### Dominios Soportados
- Dominio principal: `n8n.autosystemprojects.site`
- Subdominio www: `www.n8n.autosystemprojects.site`

## 🔒 Configuración SSL

### Certbot
- **Certificados automáticos** para nuevos dominios
- **Renovación automática** configurada
- **Soporte para múltiples dominios**
- **Configuración segura** con headers HTTPS

## 📊 Monitoreo y Logs

### Health Checks
- **Endpoint**: `/healthz`
- **Intervalo**: 30 segundos
- **Timeout**: 10 segundos
- **Reintentos**: 3

### Logs
- **Nginx**: `/var/log/nginx/{domain}.access.log`
- **Docker**: `docker logs {container_name}`
- **N8N**: Logs internos de la aplicación

## 🔧 Comandos Útiles

### Verificar Estado
```bash
# Ver contenedores activos
docker ps

# Ver logs del contenedor
docker logs n8n_{port}_{timestamp}

# Ver volúmenes
docker volume ls
```

### Gestión Manual
```bash
# Detener contenedor
docker stop n8n_{port}_{timestamp}

# Eliminar contenedor
docker rm n8n_{port}_{timestamp}

# Ver configuración de Nginx
cat /etc/nginx/sites-available/{domain}
```

## 🚨 Solución de Problemas

### Problemas Comunes

1. **Error de SSL**:
   - Verificar que Certbot esté instalado
   - Comprobar configuración DNS del dominio

2. **Contenedor no inicia**:
   - Revisar logs: `docker logs {container_name}`
   - Verificar archivo .env
   - Comprobar puerto disponible

3. **Nginx no funciona**:
   - Verificar sintaxis: `nginx -t`
   - Revisar logs: `/var/log/nginx/error.log`

### Logs de Depuración
```bash
# Ver logs del pipeline
# (Disponible en GitHub Actions)

# Ver logs del servidor
tail -f /var/log/nginx/{domain}.error.log

# Ver logs de Docker
docker logs --follow {container_name}
```

## 🔄 Actualizaciones y Mantenimiento

### Cambio de Puerto o Dominio
1. Ejecutar el workflow con nuevos parámetros
2. El sistema creará automáticamente:
   - Nueva configuración de Nginx (si es necesario)
   - Nuevo certificado SSL (si es necesario)
   - Nuevo contenedor con configuración actualizada

### Actualizaciones de Código
1. Push a la rama principal
2. El pipeline se ejecutará automáticamente
3. Se creará una nueva imagen y contenedor

## 📈 Escalabilidad

### Múltiples Instancias
- Cada puerto puede tener su propia instancia
- Volúmenes separados por puerto
- Configuraciones independientes

### Balanceador de Carga
- Nginx configurado para proxy reverso
- Soporte para múltiples backends (futuro)

## 🛡️ Seguridad

### Implementado
- ✅ Usuario no-root en contenedores
- ✅ Headers de seguridad en Nginx
- ✅ Certificados SSL automáticos
- ✅ Cookies seguras en HTTPS
- ✅ Configuración de firewall básica

### Recomendaciones
- Configurar fail2ban
- Implementar rate limiting
- Monitoreo de logs de seguridad
- Actualizaciones regulares del sistema

---

## 📞 Soporte

Para problemas o consultas sobre el pipeline de CI/CD:
1. Revisar logs en GitHub Actions
2. Verificar configuración del servidor
3. Consultar esta documentación

**¡El pipeline está listo para usar! 🎉**