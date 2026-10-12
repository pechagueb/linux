#!/bin/bash

#######################################################
#   ____  _____ ____  
#  |  _ \| ____| __ )  Autor: 
#  | |_) |  _| |  _ \  Patricio Echagüe Ballesteros
#  |  __/| |___| |_) | Descripción:
#  |_|   |_____|____/  Muestra notificación con frase de ARCHIVO
#
# Versión: 2.0 (Optimizado para systemd --user)
#######################################################

ARCHIVO="/home/patricioeb/.local/bin/quotes.txt"
HORA=$(date +%H:%M)

# Seleccionar línea aleatoria
total=$(grep -c '".*"\.' "$ARCHIVO")
random_line=$((RANDOM % total + 1))
linea=$(grep '".*"\.' "$ARCHIVO" | sed -n "${random_line}p")

# Extraer frase (lo que está entre la primera comilla doble y la siguiente)
frase=$(echo "$linea" | grep -oP '(?<=")[^"]+(?=")')

# Extraer autor (lo que está después de ". " hasta el final, quitando el último punto)
autor=$(echo "$linea" | sed -E 's/.*"\.\s+(.*)\.$/\1/')

# Si autor está vacío o contiene parte de la frase, usar método alternativo
if [[ -z "$autor" || "$autor" == *"\""* ]]; then
    autor=$(echo "$linea" | awk -F'"' '{print $NF}' | sed -E 's/^\.\s+//;s/\.$//')
fi

[[ -z "$autor" ]] && autor="Anónimo"

# Mostrar notificación (mismo código de división...)
if [[ ${#frase} -le 30 ]]; then
    /usr/bin/notify-send -u critical "$HORA - $autor" "$frase"
else
    corte=30
    while [[ $corte -gt 0 && "${frase:$corte:1}" != " " ]]; do
        ((corte--))
    done
    [[ $corte -eq 0 ]] && corte=40
    
    primera="${frase:0:$corte}"
    segunda="${frase:$corte}"
    segunda="${segunda# }"
    
    /usr/bin/notify-send -u critical "$HORA - $autor" "${primera}"$'\n'"${segunda}"
fi