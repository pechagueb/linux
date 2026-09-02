#!/bin/bash

#######################################################
#   ____  _____ ____  
#  |  _ \| ____| __ )  Autor: 
#  | |_) |  _| |  _ \  Patricio Echagüe Ballesteros
#  |  __/| |___| |_) | Descripción:
#  |_|   |_____|____/  Script de configuración de Zen Browser para Linux
#
#######################################################

# 

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
    echo -e "${CYAN}Buscando perfil en $HOME/.zen...${NC}"
    
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
    
    echo "// Configuración de $BROWSER_NAME - ~/.zen" > "$USER_JS"
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
        echo -e "${CYAN}Aplicando parámetros de GPU...${NC}"
        agregar_parametros "$USER_JS" \
            "// Parámetros de GPU" \
            'user_pref("dom.webgpu.enabled", true);' \
            'user_pref("gfx.webgpu.ignore-blocklist", true);' \
            'user_pref("gfx.webrender.wait-gpu-finished.disabled", true);' \
            'user_pref("layers.gpu-process.crash-also-crashes-browser", true);' \
            'user_pref("layers.gpu-process.enabled", true);' \
            'user_pref("layers.gpu-process.force-enabled", true);' \
            'user_pref("media.gpu-process-decoder", true);' \
            'user_pref("media.gpu-process-encoder", true);' \
            'user_pref("media.hardware-video-decoding.force-enabled", true);' \
            ""
        echo -e "${GREEN}✓ Parámetros de GPU aplicados${NC}"
        echo ""
    fi
    
    # 3. Parámetros de WebRender (WebGL)
    if preguntar "¿Aplicar cambios a los parámetros de WebRender (WebGL)?"; then
        echo ""
        echo -e "${CYAN}Aplicando parámetros de WebRender...${NC}"
        agregar_parametros "$USER_JS" \
            "// Parámetros de WebRender (WebGL)" \
            'user_pref("layers.acceleration.force-enabled", true);' \
            'user_pref("layers.acceleration.disabled", false);' \
            'user_pref("webgl.force-enabled", true);' \
            'user_pref("gfx.canvas.azure.accelerated", true);' \
            'user_pref("gfx.webrender.all", true);' \
            'user_pref("gfx.webrender.compositor", true);' \
            'user_pref("gfx.webrender.compositor.force-enabled", true);' \
            'user_pref("gfx.webrender.debug.slow-cpu-frame-threshold", 0);' \
            'user_pref("gfx.webrender.layer-compositor", true);' \
            'user_pref("gfx.webrender.wait-gpu-finished.disabled", true);' \
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
    
    # 5. Parámetros de códec de vídeo
    if preguntar "¿Aplicar cambios a los parámetros de códec de vídeo?"; then
        echo ""
        echo -e "${CYAN}Aplicando parámetros de códec de vídeo...${NC}"
        agregar_parametros "$USER_JS" \
            "// Parámetros de códec de vídeo" \
            'user_pref("media.av1.enabled", false);' \
            'user_pref("media.ffvpx.enabled", false);' \
            'user_pref("media.ffmpeg.vaapi.enabled", true);' \
            ""
        echo -e "${GREEN}✓ Parámetros de códec de vídeo aplicados${NC}"
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
    
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}           ¡Configuración completada con éxito!${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Archivo generado: ${WHITE}$USER_JS${NC}"
    echo -e "${WHITE}• Reinicia Zen Browser para aplicar los cambios.${NC}"
    echo ""
}

main