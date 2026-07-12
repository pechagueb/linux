# sys-cleaner

Bash script de limpieza de sistema inspirado en la aplicación Stacer con algunos agregados para ser ejecutado periódicamente mediante un timer de systemd (.timer y .service incluídos)

## ¿Qué hace?

1. Package Caches (Pacman y AUR)
    -Limpieza del caché de Yay (AUR)
2. Crash Reports
3. Application Logs
4. Application Caches
5. Trash (Papelera)
6. Limpiezas adicionales:
    -Archivos temporales del sistema
    -Pacman orphan packages
    -Docker (si está instalado)
    -Flatpak unused
