# systemd-timerctl

Una herramienta simple pero potente para gestionar timers de systemd a nivel de usuario.

## ¿Qué hace?

*timerctl.sh* simplifica las tareas más comunes al trabajar con timers systemd:

- **Activar** un timer (con `daemon-reload` automático)
- **Reiniciar** tras modificar archivos
- **Ver logs** sin recordar comandos de journalctl
- **Consultar estado** de forma rápida
- **Localizar archivos** de servicio y timer

### Uso: timerctl <nombre> [comando]

#### Comandos disponibles:
  - (sin comando)  - Muestra estado y próximas ejecuciones
  - enable         - Activa el timer (enable --now)
  - disable        - Desactiva el timer
  - restart        - Reinicia timer (útil tras modificar archivos)
  - status         - Muestra estado detallado
  - logs [n]       - Muestra últimos n logs (por defecto 20)  
  - path           - Muestra rutas de los archivos .service y .timer

#### Ejemplos:
  - timerctl notify-hour              # Ver estado
  - timerctl notify-hour enable       # Activar
  - timerctl sync-google restart      # Reiniciar tras modificar
  - timerctl notify-hour logs 10      # Últimas 10 líneas
