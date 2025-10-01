# Configuración de n8n para APIS_v2.3

## Descripción
n8n es una herramienta de automatización de flujos de trabajo que permite conectar diferentes servicios y APIs de manera visual. Esta instalación está configurada localmente para integrarse con el proyecto APIS_v2.3.

## Requisitos del Sistema
- **Node.js**: Versión 20.19 - 24.x (Actualmente instalado: v22.20.0)
- **npm**: Versión 9.x o superior (Actualmente instalado: v9.7.2)
- **Sistema Operativo**: Windows 10/11

## Instalación Local Realizada

### 1. Verificación de Compatibilidad
```bash
node --version  # v22.20.0 ✅
npm --version   # v9.7.2 ✅
```

### 2. Instalación Local (No Global)
```bash
cd C:\APIS_v2.3\n8n
npm init -y
npm install n8n
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