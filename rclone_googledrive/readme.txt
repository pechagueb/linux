#################################
- Script para montar Google Drive a directorio local 

- Ejecutar como script al inicio de sesión

- Mantiene el remoto y el directorio local sincronizados durante la sesión
#################################

NOTA:
Crear y Configurar Directorio de Caché 
*(para ejecutar sólo una vez en caso de tener problemas de sicronización)

# Crear directorio de caché manualmente
mkdir -p /home/patricioeb/.cache/rclone/vfs

# Verificar/crear directorio específico del remote
mkdir -p ~/.cache/rclone/vfs/GDrive

# Asignar permisos correctos
chmod 755 ~/.cache/rclone
chmod 755 ~/.cache/rclone/vfs
chmod 755 ~/.cache/rclone/vfs/GDrive

# Asegurar propiedad (reemplazar "usuario" con el nombre del usuario real)
chown -R usuario:usuario ~/.cache/rclone
