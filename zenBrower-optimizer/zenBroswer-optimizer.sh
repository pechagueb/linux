#!/bin/bash

#######################################################
#   ____  _____ ____  
#  |  _ \| ____| __ )  Autor: 
#  | |_) |  _| |  _ \  Patricio Echagüe Ballesteros
#  |  __/| |___| |_) | Descripción:
#  |_|   |_____|____/  Script de configuración de Zen Browser para Linux
#
#######################################################

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
ORANGE='\033[38;5;208m'  # Naranja brillante
ORANGE2='\033[38;5;214m' # Naranja claro
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # Sin color

# Banner
mostrar_logo() {
    clear
    echo -e "${ORANGE}"
    echo "═══════════════════════════════════════════════════════════════"
    echo -e "${ORANGE2}"
    echo "  ███████╗██╗         ██████╗ ██╗███╗   ██╗ ██████╗ ██████╗ ███╗   ██╗"
    echo "  ██╔════╝██║         ██╔══██╗██║████╗  ██║██╔════╝██╔═══██╗████╗  ██║"
    echo "  █████╗  ██║         ██████╔╝██║██╔██╗ ██║██║     ██║   ██║██╔██╗ ██║"
    echo "  ██╔══╝  ██║         ██╔══██╗██║██║╚██╗██║██║     ██║   ██║██║╚██╗██║"
    echo "  ███████╗███████╗    ██║  ██║██║██║ ╚████║╚██████╗╚██████╔╝██║ ╚████║"
    echo "  ╚══════╝╚══════╝    ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝"
    echo ""
    echo "  ███████╗███████╗███╗   ██╗    ██████╗ ██████╗  ██████╗ ██╗    ██╗███████╗███████╗██████╗ "
    echo "  ╚══███╔╝██╔════╝████╗  ██║    ██╔══██╗██╔══██╗██╔═══██╗██║    ██║██╔════╝██╔════╝██╔══██╗"
    echo "    ███╔╝ █████╗  ██╔██╗ ██║    ██████╔╝██████╔╝██║   ██║██║ █╗ ██║███████╗███████╗██████╔╝"
    echo "   ███╔╝  ██╔══╝  ██║╚██╗██║    ██╔══██╗██╔══██╗██║   ██║██║███╗██║╚════██║╚════██║██╔══██╗"
    echo "  ███████╗███████╗██║ ╚████║    ██████╔╝██║  ██║╚██████╔╝╚███╔███╔╝███████║███████║██║  ██║"
    echo "  ╚══════╝╚══════╝╚═╝  ╚═══╝    ╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚══╝╚══╝ ╚══════╝╚══════╝╚═╝  ╚═╝"
    echo -e "${ORANGE}"
    echo "═══════════════════════════════════════════════════════════════"
    echo -e "${WHITE}           Configurador de Parámetros para Zen Browser${NC}"
    echo -e "${ORANGE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Función para preguntar al usuario
preguntar() {
    local pregunta="$1"
    local respuesta
    echo -e "${YELLOW}${pregunta}${NC}"
    echo -e "${GREEN}Presiona ENTER o ingresa 'y' para continuar, o 'n' para cancelar:${NC} "
    read -r respuesta
    respuesta=$(echo "$respuesta" | tr '[:upper:]' '[:lower:]')
    if [[ -z "$respuesta" || "$respuesta" == "y" || "$respuesta" == "yes" ]]; then
        return 0
    else
        return 1
    fi
}

# Función para encontrar el perfil exclusivamente en ~/.config/zen
encontrar_perfil() {
    local browser_dir="$HOME/.config/zen"
    
    if [[ ! -d "$browser_dir" ]]; then
        echo -e "${RED}Error: No se encontró el directorio $browser_dir${NC}"
        exit 1
    fi
    
    local perfil
    perfil=$(find "$browser_dir" -maxdepth 1 -type d -name "*Default*" | head -n 1)
    
    if [[ -z "$perfil" ]]; then
        echo -e "${RED}Error: No se encontró ningún perfil en $browser_dir${NC}"
        exit 1
    fi
    
    echo "$perfil"
}

# Función para agregar parámetros al user.js
agregar_parametros() {
    local archivo="$1"
    shift
    local parametros=("$@")
    
    for param in "${parametros[@]}"; do
        echo "$param" >> "$archivo"
    done
}

# Función principal
main() {
    mostrar_logo
    
    if [[ "$(uname)" != "Linux" ]]; then
        echo -e "${RED}Este script solo funciona en Linux${NC}"
        exit 1
    fi
    
    local BROWSER_NAME="Zen Browser"
    
    echo -e "${WHITE}Navegador configurado: ${WHITE}$BROWSER_NAME${NC}"
    echo -e "${CYAN}Buscando perfil en $HOME/.config/zen...${NC}"
    
    PERFIL=$(encontrar_perfil)
    USER_JS="$PERFIL/user.js"
    
    echo -e "${GREEN}Perfil encontrado: $PERFIL${NC}"
    echo ""
    
    if [[ -f "$USER_JS" ]]; then
        BACKUP="$USER_JS.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$USER_JS" "$BACKUP"
        echo -e "${YELLOW}Backup creado: $BACKUP${NC}"
        echo ""
    fi
    
    echo "// Configuración de $BROWSER_NAME - ~/.config/zen" > "$USER_JS"
    echo "// Fecha: $(date)" >> "$USER_JS"
    echo "" >> "$USER_JS"
    
    # 1. Parámetros del compositor
    if preguntar "¿Aplicar cambios a los parámetros del compositor?"; then
        echo ""
        echo -e "${CYAN}Aplicando parámetros del compositor...${NC}"
        agregar_parametros "$USER_JS" \
            "// Parámetros del compositor" \
            'user_pref("toolkit.cosmeticAnimations.enabled", false);' \
            ""
        echo -e "${GREEN}✓ Parámetros del compositor aplicados${NC}"
        echo ""
    fi
    
    # 2. Parámetros de GPU 
    if preguntar "¿Aplicar cambios a los parámetros de GPU?"; then
        echo ""
        echo -e "${CYAN}Aplicando parámetros de GPU seguros...${NC}"
        agregar_parametros "$USER_JS" \
            "// Parámetros de GPU" \
            'user_pref("dom.webgpu.enabled", true);' \
            'user_pref("layers.gpu-process.enabled", true);' \
            'user_pref("media.gpu-process-decoder", false);' \
            'user_pref("media.hardware-video-decoding.force-enabled", false);' \
            ""
        echo -e "${GREEN}✓ Parámetros de GPU aplicados${NC}"
        echo ""
    fi
    
    # 3. Parámetros de WebRender (WebGL seguro)
    if preguntar "¿Aplicar cambios a los parámetros de WebRender (WebGL)?"; then
        echo ""
        echo -e "${CYAN}Aplicando parámetros de WebRender seguros...${NC}"
        agregar_parametros "$USER_JS" \
            "// Parámetros de WebRender" \
            'user_pref("webgl.force-enabled", true);' \
            'user_pref("gfx.webrender.all", false);' \
            'user_pref("gfx.webrender.compositor", false);' \
            ""
        echo -e "${GREEN}✓ Parámetros de WebRender aplicados${NC}"
        echo ""
    fi
    
    # 4. Parámetros de CPU
    if preguntar "¿Aplicar cambios a los parámetros de CPU?"; then
        echo -e "${CYAN}Configurando parámetros de CPU...${NC}"
        echo -e "${YELLOW}Ingresa el número de hilos de tu procesador (ej. ejecuta nproc):${NC} "
        read -r num_hilos
        
        if [[ ! "$num_hilos" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}Error: Número no válido. Saltando...${NC}"
        else
            agregar_parametros "$USER_JS" \
                "// Parámetros de CPU" \
                "user_pref(\"javascript.options.concurrent_multiprocess_gcs.cpu_divisor\", $num_hilos);" \
                "user_pref(\"dom.ipc.processCount\", $num_hilos);" \
                'user_pref("media.ffmpeg.encoder.cpu-used", 0);' \
                ""
            echo -e "${GREEN}✓ Parámetros de CPU aplicados (hilos: $num_hilos)${NC}"
        fi
        echo ""
    fi
    
    # 5. Parámetros de códec de vídeo y aceleración Wayland
    if preguntar "¿Aplicar cambios a los parámetros de códec de vídeo y corrección de color?"; then
        echo ""
        echo -e "${CYAN}Aplicando parámetros de códec y solución de tinte rojo...${NC}"
        agregar_parametros "$USER_JS" \
            "// Parámetros de códec de vídeo y Wayland" \
            'user_pref("media.av1.enabled", false);' \
            'user_pref("media.ffvpx.enabled", false);' \
            'user_pref("media.ffmpeg.vaapi.enabled", false);' \
            'user_pref("widget.dmabuf-textured-video.enabled", false);' \
            ""
        echo -e "${GREEN}✓ Parámetros de códec aplicados${NC}"
        echo ""
    fi

    # 6. Parámetros de la memoria caché
    if preguntar "¿Aplicar cambios a los parámetros de la memoria caché?"; then
        echo ""
        echo -e "${CYAN}Aplicando parámetros de caché...${NC}"
        agregar_parametros "$USER_JS" \
            "// Parámetros de la memoria cache" \
            'user_pref("browser.cache.memory.enable", false);' \
            'user_pref("browser.cache.disk.enable", false);' \
            ""
        echo -e "${GREEN}✓ Parámetros de memoria caché aplicados${NC}"
        echo ""
    fi

    # 7. Automatización de limpieza de caché y parcheo directo en prefs.js
    echo -e "${CYAN}Ejecutando limpieza profunda y forzando correcciones de color...${NC}"
    
    if [[ -d "$PERFIL/startupCache" ]]; then
        rm -rf "$PERFIL/startupCache"
        echo -e "${YELLOW}• Caché de inicio eliminada.${NC}"
    fi
    
    if [[ -d "$PERFIL/cache2" ]]; then
        rm -rf "$PERFIL/cache2"
        echo -e "${YELLOW}• Caché web eliminada.${NC}"
    fi
    
    if [[ -f "$PERFIL/prefs.js" ]]; then
        sed -i '/widget\.dmabuf-textured-video\.enabled/d' "$PERFIL/prefs.js"
        echo 'user_pref("widget.dmabuf-textured-video.enabled", false);' >> "$PERFIL/prefs.js"
        
        sed -i '/media\.ffmpeg\.vaapi\.enabled/d' "$PERFIL/prefs.js"
        echo 'user_pref("media.ffmpeg.vaapi.enabled", false);' >> "$PERFIL/prefs.js"
        
        sed -i '/gfx\.webrender\.all/d' "$PERFIL/prefs.js"
        echo 'user_pref("gfx.webrender.all", false);' >> "$PERFIL/prefs.js"
        
        echo -e "${GREEN}✓ prefs.js parcheado directamente con éxito.${NC}"
    fi
    
    # 8. Corrección forzada para el bug de decodificación de vídeo en Intel/Wayland (Tinte rojo)
    echo -e "${CYAN}Aplicando parche definitivo para el bug de color en Intel UHD...${NC}"
    agregar_parametros "$USER_JS" \
        "// Corrección bug de color Intel/Wayland" \
        'user_pref("media.hardware-video-decoding.enabled", false);' \
        'user_pref("media.rdd-process.enabled", false);' \
        'user_pref("gfx.color_management.native_sRGB", false);' \
        ""
        
    if [[ -f "$PERFIL/prefs.js" ]]; then
        sed -i '/media\.hardware-video-decoding\.enabled/d' "$PERFIL/prefs.js"
        echo 'user_pref("media.hardware-video-decoding.enabled", false);' >> "$PERFIL/prefs.js"
        
        sed -i '/media\.rdd-process\.enabled/d' "$PERFIL/prefs.js"
        echo 'user_pref("media.rdd-process.enabled", false);' >> "$PERFIL/prefs.js"
    fi
    echo -e "${GREEN}✓ Parche de color aplicado en user.js y prefs.js${NC}"
    echo ""

    
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}           ¡Configuración completada con éxito!${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Archivo generado: ${WHITE}$USER_JS${NC}"
    echo -e "${WHITE}• Cierra por completo Zen Browser y vuelve a abrirlo.${NC}"
    echo ""

}


main