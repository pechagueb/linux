#!/bin/bash

#######################################################
#   ____  _____ ____  
#  |  _ \| ____| __ )  Autor: 
#  | |_) |  _| |  _ \  Patricio Echagüe Ballesteros
#  |  __/| |___| |_) | Descripción:
#  |_|   |_____|____/  Creador de USB Booteables con Zenity y dd
#
# Uso: zenflash.sh
#######################################################

# ==============================================================================
# Estilo Dark / Minimalista (Compatible con Wayland/X11)
# ==============================================================================

# Forzar tema oscuro en GTK
export GTK_THEME=${GTK_THEME:-Adwaita:dark}

# 1. Verificar dependencias esenciales (como usuario normal)
for cmd in zenity lsblk dd blockdev; do
    if ! command -v "$cmd" &> /dev/null; then
        zenity --error --text="Falta el comando necesario: $cmd. Por favor instálalo." --title="ZenFlash - Error"
        exit 1
    fi
done

HAS_PV=0
if command -v pv &> /dev/null; then
    HAS_PV=1
fi

# 2. Selección de la imagen ISO (ejecutándose en la sesión gráfica del usuario)
ISO_PATH=$(zenity --file-selection \
    --title="ZenFlash ➔ Selecciona la imagen ISO" \
    --file-filter="Archivos ISO (*.iso) | *.iso")

if [ -z "$ISO_PATH" ]; then
    exit 0
fi

# 3. Detección automática de unidades USB extraíbles (RM=1)
USB_LIST=()
while IFS="|" read -r name size model; do
    name=$(echo "$name" | xargs)
    size=$(echo "$size" | xargs)
    model=$(echo "$model" | xargs)
    
    if [ -n "$name" ]; then
        USB_LIST+=("/dev/$name" "$model ($size)")
    fi
done < <(lsblk -d -o NAME,SIZE,MODEL,RM | awk '$4==1 {print $1 "|" $2 "|" $3}')

if [ ${#USB_LIST[@]} -eq 0 ]; then
    zenity --error \
        --text="No se detectaron unidades USB extraíbles.\nConecta un pendrive e inténtalo de nuevo." \
        --title="ZenFlash - Sin dispositivos"
    exit 1
fi

TARGET_USB=$(zenity --list \
    --title="ZenFlash ➔ Seleccionar Destino" \
    --text="⚠️ ADVERTENCIA: Se borrarán todos los datos del dispositivo seleccionado." \
    --column="Dispositivo" --column="Modelo y Capacidad" \
    "${USB_LIST[@]}" \
    --width=600 --height=320)

if [ -z "$TARGET_USB" ]; then
    exit 0
fi

# 4. Confirmación de seguridad final
ISO_NAME=$(basename "$ISO_PATH")
zenity --question \
    --title="ZenFlash ➔ ¿Confirmar grabado?" \
    --text="Estás a punto de escribir:\n\n📄 ISO: $ISO_NAME\n🎯 Destino: $TARGET_USB\n\n🔥 ¡TODOS LOS DATOS ANTERIORES SE PERDERÁN!\n¿Deseas continuar?" \
    --width=450

if [ $? -ne 0 ]; then
    exit 0
fi

# 5. Proceso de flasheo: pkexec solo envuelve el motor de escritura
ISO_SIZE=$(stat -c%s "$ISO_PATH")

if [ $HAS_PV -eq 1 ]; then
    (
        pkexec bash -c "pv -n -s '$ISO_SIZE' '$ISO_PATH' | dd of='$TARGET_USB' bs=4M status=none conv=fsync"
        echo 100
    ) 2>&1 | zenity --progress \
        --title="ZenFlash ➔ Quemando USB" \
        --text="Escribiendo $ISO_NAME en $TARGET_USB...\nIntroduce tu contraseña en el diálogo emergente." \
        --percentage=0 --auto-close --width=480
else
    (
        pkexec bash -c "dd if='$ISO_PATH' of='$TARGET_USB' bs=4M status=progress conv=fsync"
    ) | zenity --progress \
        --title="ZenFlash ➔ Quemando USB" \
        --text="Escribiendo $ISO_NAME en $TARGET_USB...\n(Tip: instala 'pv' para ver el porcentaje exacto)" \
        --pulsate --auto-close --width=480
fi

# 6. Notificación de resultado
if [ ${PIPESTATUS[0]} -eq 0 ] || [ $? -eq 0 ]; then
    zenity --info \
        --title="ZenFlash ➔ ¡Éxito!" \
        --text="¡El disco booteable se ha creado correctamente en $TARGET_USB!\nYa puedes extraer la unidad con seguridad." \
        --width=400
else
    zenity --error \
        --title="ZenFlash ➔ Error" \
        --text="Ocurrió un error durante la escritura en $TARGET_USB." \
        --width=400
fi