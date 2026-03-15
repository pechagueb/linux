#!/bin/bash

# Este script acepta el Título y el Cuerpo del mensaje como argumentos.
# Uso: /ruta/al/script "Título del Mensaje" "Cuerpo del Mensaje"

# -----------------------------------------------
# 1. Validación de Argumentos
# -----------------------------------------------

# Verifica si se proporcionaron al menos dos argumentos (Título y Cuerpo)
if [ $# -lt 2 ]; then
    echo "[$(date)] ERROR: Faltan argumentos. Uso: $0 \"TITULO\" \"CUERPO\"" >> ~/cron_notify_error.log
    exit 1
fi

# Asigna los argumentos a variables legibles
NOTIFY_TITLE="$1"
NOTIFY_BODY="$2"
# Puedes añadir un tercer argumento para el icono, por ejemplo: NOTIFY_ICON="$3"

# -----------------------------------------------
# 2. Búsqueda de la Configuración de Sesión (DBUS)
# -----------------------------------------------

# NOTA: Asegúrate de que el usuario de cron es el mismo que tiene la sesión gráfica activa.
USER_ID=$(id -u)

# Intenta obtener la variable DBUS_SESSION_BUS_ADDRESS de la sesión activa
# Esto busca la variable en los procesos de la sesión de systemd/gnome.
DBUS_ADDRESS=unix:path=/run/user/1000/bus


# -----------------------------------------------
# 3. Ejecución del Comando de Notificación
# -----------------------------------------------

if [ -n "$DBUS_ADDRESS" ]; then
    export DISPLAY=:0
    export DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDRESS"

    # Ejecuta la notificación usando las variables de argumentos
    /usr/bin/notify-send "$NOTIFY_TITLE" "$NOTIFY_BODY"
    /usr/bin/aplay ufo-sound-effect-240256.wav
else
    # Escribe un mensaje en un log si no encuentra el Bus.
    echo "[$(date)] ERROR: No se encontró DBUS_SESSION_BUS_ADDRESS. Mensaje: $NOTIFY_TITLE - $NOTIFY_BODY" >> ~/cron_notify_error.log
fi

exit 0
