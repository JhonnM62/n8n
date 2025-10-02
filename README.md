# n8n Automation Platform

Este es un despliegue personalizado de n8n con pipeline automatizado de CI/CD para `n8n.autosystemprojects.site`.

## 🚀 Características

- **Despliegue automatizado** con GitHub Actions
- **Contenedorización Docker** optimizada
- **Proxy inverso NGINX** con SSL automático
- **Scripts de despliegue flexibles**
- **Configuración de seguridad** avanzada
- **Monitoreo de salud** integrado

## 📋 Requisitos Previos

- Servidor con Docker instalado
- Dominio configurado (`n8n.autosystemprojects.site`)
- Acceso SSH al servidor
- GitHub Container Registry configurado

## 🛠️ Configuración Inicial

### 1. Variables de Entorno

Crea un archivo `.env` basado en `.env.example`:

```bash
# Configuración del servidor
N8N_HOST=0.0.0.0
N8N_PORT=5678
N8N_PROTOCOL=https
N8N_SECURE_COOKIE=true

# Base de datos
DB_TYPE=sqlite
N8N_DATABASE_SQLITE_DATABASE=/app/data/database.sqlite

# Logs
N8N_LOG_LEVEL=info
N8N_LOG_OUTPUT=file
N8N_LOG_FILE_LOCATION=/app/logs/n8n.log

# Configuración de dominio
WEBHOOK_URL=https://n8n.autosystemprojects.site
N8N_EDITOR_BASE_URL=https://n8n.autosystemprojects.site
```

### 2. Secretos de GitHub

Configura los siguientes secretos en tu repositorio de GitHub:

- `TOKEN_N8N`: Token de acceso a GitHub Container Registry
- `SSH_HOST`: IP del servidor de destino
- `SSH_USERNAME`: Usuario SSH
- `SSH_PRIVATE_KEY`: Clave privada SSH
- `SSH_PORT`: Puerto SSH (por defecto 22)

## 🔄 Pipeline de CI/CD

### Flujo de Trabajo Automatizado

El pipeline se activa automáticamente en:
- Push a ramas: `main`, `master`, `develop`
- Ejecución manual con parámetros personalizables

### Trabajos del Pipeline

#### 1. **create-docker-image**
```yaml
- Construye la imagen Docker
- Sube a GitHub Container Registry (ghcr.io)
- Etiqueta con SHA del commit
```

#### 2. **deploy**
```yaml
- Conecta al servidor vía SSH
- Descarga la nueva imagen
- Detiene el contenedor anterior
- Despliega el nuevo contenedor
- Configura NGINX y SSL
- Verifica el estado del servicio
```

### Configuración del Workflow

El archivo `.github/workflows/deploy.yml` permite personalización:

```yaml
inputs:
  domain:
    description: 'Dominio para n8n'
    default: 'n8n.autosystemprojects.site'
  internal_port:
    description: 'Puerto interno del contenedor'
    default: '5678'
  external_port:
    description: 'Puerto externo del contenedor'
    default: '8017'
```

## 🐳 Docker

### Dockerfile Optimizado

- **Imagen base**: Node.js 20 Alpine
- **Usuario no-root**: Seguridad mejorada
- **Volúmenes persistentes**: Datos y logs
- **Variables de entorno**: Configuración flexible

### Construcción Local

```bash
# Construir imagen
docker build -t n8n-custom .

# Ejecutar contenedor
docker run -d \
  --name n8n \
  -p 8017:5678 \
  -v n8n_data:/app/data \
  -v n8n_logs:/app/logs \
  --env-file .env \
  n8n-custom
```

### 3. Estructura de Archivos
```
C:\APIS_v2.3\n8n\
├── node_modules/          # Módulos de n8n instalados localmente
│   ├── n8n/              # Ejecutable principal de n8n
│   ├── n8n-core/         # Núcleo de n8n
│   ├── n8n-editor-ui/    # Interfaz de usuario
│   ├── n8n-nodes-base/   # Nodos base
│   └── n8n-workflow/     # Motor de workflows
├── .env.example          # Plantilla de variables de entorno
├── README.md             # Esta documentación
├── package.json          # Configuración del proyecto
└── package-lock.json     # Dependencias bloqueadas
```

## Configuración Actual

### Acceso a la Interfaz Web
- **URL**: http://localhost:5678
- **Puerto por defecto**: 5678
- **Estado**: ✅ Funcionando correctamente

### Scripts Disponibles
```bash
# Iniciar n8n
npm start

# Iniciar n8n con túnel (para webhooks externos)
npm run dev

# Exportar todos los workflows
npm run export

# Importar workflows
npm run import
```

## Comandos de Uso

### Iniciar n8n Local
```bash
cd C:\APIS_v2.3\n8n
npm start
```

### Detener n8n
- Presionar `Ctrl + C` en la terminal donde se ejecuta n8n

### Acceso Directo
```bash
# Ejecutar directamente desde node_modules
./node_modules/.bin/n8n start

# O usando npx
npx n8n start
```

## Integración con el Proyecto

### Posibles Casos de Uso
1. **Automatización de WhatsApp**: Conectar con la API de WhatsApp del proyecto
2. **Integración con Flowise**: Crear flujos que conecten n8n con Flowise
3. **Procesamiento de datos**: Automatizar el procesamiento de mensajes y respuestas
4. **Webhooks**: Recibir y procesar webhooks de diferentes servicios
5. **Notificaciones**: Enviar notificaciones automáticas basadas en eventos

### Endpoints de Integración
- **API WhatsApp**: Disponible en el proyecto para conectar con n8n
- **Base de datos**: Acceso a la misma base de datos del proyecto principal
- **Webhooks**: n8n puede recibir webhooks en rutas personalizadas

## Configuración de Seguridad

### Recomendaciones
1. **Autenticación**: Configurar autenticación básica para producción
2. **HTTPS**: Usar HTTPS en producción
3. **Variables de entorno**: No exponer credenciales en los flujos
4. **Acceso a red**: Restringir acceso solo a IPs autorizadas

### Variables de Seguridad
```env
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=tu_password_seguro
```

## Troubleshooting

### Problemas Comunes

#### Error de versión de Node.js
```
Error: Node.js version not supported
```
**Solución**: Actualizar Node.js a una versión compatible (20.19-24.x)

#### Puerto ocupado
```
Error: Port 5678 is already in use
```
**Solución**: Cambiar el puerto usando la variable `N8N_PORT`

#### Problemas de permisos
**Solución**: Ejecutar como administrador o verificar permisos de escritura

### Logs y Debugging
- Los logs se muestran en la consola donde se ejecuta n8n
- Para logs más detallados, usar: `N8N_LOG_LEVEL=debug`

## Próximos Pasos

1. ✅ Instalación completada
2. ✅ Configuración básica funcionando
3. 🔄 Crear archivo de configuración con variables de entorno
4. ⏳ Crear flujos de ejemplo para integración con el proyecto
5. ⏳ Documentar casos de uso específicos
6. ⏳ Configurar autenticación para producción

## Soporte y Documentación

- **Documentación oficial**: https://docs.n8n.io/
- **Comunidad**: https://community.n8n.io/
- **GitHub**: https://github.com/n8n-io/n8n
- **Ejemplos de flujos**: https://n8n.io/workflows/

---

**Fecha de configuración**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Configurado por**: Sistema automatizado
**Versión de n8n**: 1.113.3