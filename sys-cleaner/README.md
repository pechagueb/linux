# sys-cleaner

Bash script de limpieza de sistema inspirado en la aplicación Stacer con algunos agregados para ser ejecutado periódicamente mediante un timer de systemd (.timer y .service incluídos)

## ¿Qué hace?

- Package Caches (Pacman y AUR)  
  - Limpieza del caché de Yay (AUR)
    
- Crash Reports
  
- Application Logs
  
- Application Caches
  
- Trash (Papelera)
  
- Limpiezas adicionales:
  - Archivos temporales del sistema
  - Pacman orphan packages
  - Docker (si está instalado)
  - Flatpak unused
