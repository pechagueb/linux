#!/bin/bash

########################################################
# Script de limpieza automática inspirado en Stacer 
# (Optimizado para Arch Linux)
# Autor: Patricio Echagüe Ballesteros
# Calcula espacio liberado y notifica en GB
# logs con: journalctl -t syscleaner
########################################################

# Función para obtener espacio usado en GB
get_used_space() {
    df / | awk 'NR==2 {print $3}' | awk '{printf "%.0f", $1/1024/1024}'
}

# Calcular espacio inicial
SPACE_BEFORE=$(get_used_space)

# Variables para contar elementos eliminados
DELETED_ITEMS=0

# echo "Iniciando limpieza del sistema..."
# echo "Espacio usado antes: ${SPACE_BEFORE} GB"

# 1. Package Caches (Pacman y AUR)
if [ -x "$(command -v paccache)" ]; then
    # echo "Limpiando caché de pacman..."
    # Contar paquetes antes
    PKGS_BEFORE=$(find /var/cache/pacman/pkg -type f | wc -l)
    
    paccache -r -k 2  # Mantiene 2 versiones
    paccache -ruk1    # Remove unused packages, keep 1
    
    # Limpieza del caché de Yay (AUR)
    if [ -d "/home/patricioeb/.cache/yay" ]; then
        paccache -r -c /home/patricioeb/.cache/yay -k 1
    fi
    
    PKGS_AFTER=$(find /var/cache/pacman/pkg -type f | wc -l)
    DELETED_ITEMS=$((DELETED_ITEMS + PKGS_BEFORE - PKGS_AFTER))
fi

# 2. Crash Reports
if [ -d "/var/crash" ] && [ "$(ls -A /var/crash 2>/dev/null)" ]; then
    CRASH_FILES=$(find /var/crash -type f | wc -l)
    rm -rf /var/crash/*
    DELETED_ITEMS=$((DELETED_ITEMS + CRASH_FILES))
fi

if [ -d "/var/metrics" ] && [ "$(ls -A /var/metrics 2>/dev/null)" ]; then
    METRICS_FILES=$(find /var/metrics -type f | wc -l)
    rm -rf /var/metrics/*
    DELETED_ITEMS=$((DELETED_ITEMS + METRICS_FILES))
fi

# 3. Application Logs
# echo "Limpiando logs del sistema..."
LOGS_BEFORE=$(du -sb /var/log 2>/dev/null | cut -f1)

journalctl --vacuum-time=2d 2>/dev/null

find /var/log -type f -name "*.log" -exec truncate -s 0 {} + 2>/dev/null
find /var/log -type f -name "*.gz" -delete 2>/dev/null
find /var/log -type f -name "*.[0-9]" -delete 2>/dev/null

LOGS_AFTER=$(du -sb /var/log 2>/dev/null | cut -f1)
if [ "$LOGS_BEFORE" -gt "$LOGS_AFTER" ]; then
    DELETED_ITEMS=$((DELETED_ITEMS + 1))
fi

# 4. Application Caches
# echo "Limpiando cachés de aplicaciones..."

# Root cache
if [ -d "/root/.cache" ]; then
    ROOT_CACHE_SIZE=$(du -sb /root/.cache 2>/dev/null | cut -f1)
    rm -rf /root/.cache/* 2>/dev/null
    if [ "$ROOT_CACHE_SIZE" -gt 0 ]; then
        DELETED_ITEMS=$((DELETED_ITEMS + 1))
    fi
fi

# User caches
for user_dir in /home/*; do
    if [ -d "$user_dir/.cache" ]; then
        USER_CACHE_SIZE=$(du -sb "$user_dir/.cache" 2>/dev/null | cut -f1)
        rm -rf "$user_dir/.cache"/* 2>/dev/null
        
        # Thumbnails
        if [ -d "$user_dir/.cache/thumbnails" ]; then
            rm -rf "$user_dir/.cache/thumbnails"/* 2>/dev/null
        fi
        
        if [ "$USER_CACHE_SIZE" -gt 0 ]; then
            DELETED_ITEMS=$((DELETED_ITEMS + 1))
        fi
    fi
    
    # Browser caches
    if [ -d "$user_dir/.mozilla" ]; then
        find "$user_dir/.mozilla" -type d -name "cache*" -exec rm -rf {} + 2>/dev/null
        find "$user_dir/.mozilla" -type d -name "Cache" -exec rm -rf {} + 2>/dev/null
        DELETED_ITEMS=$((DELETED_ITEMS + 1))
    fi
    
    if [ -d "$user_dir/.config/google-chrome" ]; then
        find "$user_dir/.config/google-chrome" -type d -name "Cache*" -exec rm -rf {} + 2>/dev/null
        find "$user_dir/.config/google-chrome" -type d -name "Code Cache" -exec rm -rf {} + 2>/dev/null
        DELETED_ITEMS=$((DELETED_ITEMS + 1))
    fi
    
    if [ -d "$user_dir/.config/chromium" ]; then
        find "$user_dir/.config/chromium" -type d -name "Cache*" -exec rm -rf {} + 2>/dev/null
        DELETED_ITEMS=$((DELETED_ITEMS + 1))
    fi
done

# 5. Trash (Papelera)
# echo "Vacíando papelera..."

# Root trash
if [ -d "/root/.local/share/Trash/files" ]; then
    TRASH_ROOT=$(find /root/.local/share/Trash/files -type f 2>/dev/null | wc -l)
    rm -rf /root/.local/share/Trash/* 2>/dev/null
    DELETED_ITEMS=$((DELETED_ITEMS + TRASH_ROOT))
fi

# User trash
for user_dir in /home/*; do
    if [ -d "$user_dir/.local/share/Trash/files" ]; then
        TRASH_USER=$(find "$user_dir/.local/share/Trash/files" -type f 2>/dev/null | wc -l)
        rm -rf "$user_dir/.local/share/Trash"/* 2>/dev/null
        DELETED_ITEMS=$((DELETED_ITEMS + TRASH_USER))
    fi
done

# 6. Limpiezas adicionales
# echo "Realizando limpiezas adicionales..."

# Archivos temporales del sistema
if [ -d "/tmp" ]; then
    find /tmp -type f -atime +7 -delete 2>/dev/null
    DELETED_ITEMS=$((DELETED_ITEMS + 1))
fi

# Pacman orphan packages
if [ -x "$(command -v pacman)" ]; then
    # echo "Eliminando paquetes huérfanos..."
    pacman -Rns --noconfirm $(pacman -Qtdq) 2>/dev/null
    DELETED_ITEMS=$((DELETED_ITEMS + 1))
fi

# Docker (si está instalado)
if [ -x "$(command -v docker)" ]; then
    # echo "Limpiando Docker..."
    docker system prune -af 2>/dev/null
    DELETED_ITEMS=$((DELETED_ITEMS + 1))
fi

# Flatpak unused
if [ -x "$(command -v flatpak)" ]; then
    # echo "Limpiando Flatpak..."
    flatpak uninstall --unused -y 2>/dev/null
    DELETED_ITEMS=$((DELETED_ITEMS + 1))
fi

# Calcular espacio final
SPACE_AFTER=$(get_used_space)
SPACE_FREED=$((SPACE_BEFORE - SPACE_AFTER))

# Si el cálculo es negativo (por variaciones del sistema), ajustar a 0
if [ "$SPACE_FREED" -lt 0 ]; then
    SPACE_FREED=0
fi

# echo "Espacio usado después: ${SPACE_AFTER} GB"
# echo "Espacio liberado: ${SPACE_FREED} GB"
# echo "Elementos limpiados: ${DELETED_ITEMS}"

# Notificación con espacio liberado
if [ "$SPACE_FREED" -gt 0 ]; then
    MESSAGE="Limpieza completada\n\nEspacio liberado: ${SPACE_FREED} GB\nElementos: ${DELETED_ITEMS}"
else
    MESSAGE="Limpieza completada\n\nNo se liberó espacio significativo\nElementos: ${DELETED_ITEMS}"
fi

/usr/bin/notify-send -u critical "Sys Cleaner" "$MESSAGE"

################
# Log en el journal del sistema
logger -t syscleaner "Limpieza completada. Espacio liberado: ${SPACE_FREED} GB. Elementos limpiados: ${DELETED_ITEMS}"
