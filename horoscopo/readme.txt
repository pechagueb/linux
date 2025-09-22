# Nombre: horoscopo.sh
# Autor: Patricio Echagüe Ballesteros (YAPA Design)
# WEB: https://pechagueb.odoo.com/
# Nivel: medio/avanzado

Este script en Bash consulta el horóscopo diario de Piscis usando la API de API Ninjas
y lo muestra por terminal.

Opcionalmente lo puede guardar en un archivo de texto y puede mostrarte una notificación en tu escritorio.
Además, incluye la opción de traducir el texto automáticamente al español.

REQUISITOS
----------
- bash (ya viene en la mayoría de sistemas Linux)
- curl (para conectarse a la API)
- Recomendado:
  - jq → para parsear JSON de forma limpia
  - translate-shell (comando "trans") → para traducir el horóscopo al español

INSTALACIÓN DE DEPENDENCIAS
---------------------------
En Debian/Ubuntu:
    sudo apt update
    sudo apt install curl jq translate-shell

OBTENER API KEY
---------------
1. Regístrate gratis en https://api-ninjas.com/
2. Obtén tu API Key.
3. Edita el script horoscopo_piscis_ninjas.sh y reemplaza la línea:

   API_KEY="AQUI_TU_API_KEY"

USO
---
Ejecuta el script:
    ./horoscopo.sh

Mostrará el horóscopo por terminal (por defecto)

Opcionalmente:
Generará un archivo con el horóscopo del día en:
    ~/horoscopos/pisces_ninjas_YYYY-MM-DD.txt

El archivo contiene:
- Fecha y signo
- Horóscopo en inglés
- Horóscopo traducido al español (si tienes translate-shell instalado)

Mostrará el horóscopo en una notificación de escritorio:
- En Linux: requiere "notify-send"

AUTOMATIZACIÓN CON CRON
-----------------------
Para recibir tu horóscopo cada mañana automáticamente,
ejemplo todos los días a las 8:00 AM:

    0 8 * * * /ruta/completa/horoscopo_piscis_ninjas.sh >/dev/null 2>&1

TRADUCCIÓN AL ESPAÑOL
---------------------
Si instalaste translate-shell, el script traducirá el horóscopo al español.
Si no, mostrará solo el original en inglés.

NOTAS FINALES
-------------
- El script está configurado para Piscis, pero puedes cambiar la variable SIGN
  por otro signo zodiacal.
- Ten en cuenta que las APIs pueden cambiar o caerse.
- El horóscopo es solo entretenimiento, ¡no lo tomes demasiado en serio!
