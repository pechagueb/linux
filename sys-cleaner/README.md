# sys-cleaner

Bash script de limpieza de sistema inspirado en la aplicación Stacer con algunos agregados para ser ejecutado periódicamente mediante un timer de systemd (.timer y .service incluídos)

## ¿Qué hace?

1. Package Caches (Pacman y AUR)
  Limpieza del caché de Yay (AUR)
3. Crash Reports
4. Application Logs
5. Application Caches
6. Trash (Papelera)
7. Limpiezas adicionales:
  Archivos temporales del sistema
  Pacman orphan packages
  Docker (si está instalado)
  Flatpak unused
