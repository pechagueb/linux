# systemd-timerctl

Una herramienta simple pero potente para gestionar timers de systemd a nivel de usuario.

## ¿Qué hace?

*timerctl.sh* simplifica las tareas más comunes al trabajar con timers systemd:

- **Activar** un timer (con `daemon-reload` automático)
- **Reiniciar** tras modificar archivos
- **Ver logs** sin recordar comandos de journalctl
- **Consultar estado** de forma rápida
- **Localizar archivos** de servicio y timer

### Ejemplos:

  - timerctl notify-hour
  - timerctl notify-hour enable       # Activar"
  - timerctl sync-google restart      # Reiniciar tras modificar"
  - timerctl notify-hour logs 10      # Últimas 10 líneas"
