#!/bin/bash

# ============================================
# timerctl.sh  
# Autor: Patricio Echagüe Ballesteros (YAPA Design)
# Asistido por Deep Seek AI
# WEB: ...en construccion (@yapadesign - Facebook)
# Descripción: Gestor de timers systemd para usuario
# Uso: timerctl <nombre> [enable|disable|status|restart|logs|path]
# ============================================

# Colores para output (opcional, mejora legibilidad)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar argumentos
if [ $# -lt 1 ]; then
    echo "Uso: timerctl <nombre> [comando]"
    echo ""
    echo "Comandos disponibles:"
    echo "  (sin comando)  - Muestra estado y próximas ejecuciones"
    echo "  enable         - Activa el timer (enable --now)"
    echo "  disable        - Desactiva el timer"
    echo "  restart        - Reinicia timer (útil tras modificar archivos)"
    echo "  status         - Muestra estado detallado"
    echo "  logs [n]       - Muestra últimos n logs (por defecto 20)"
    echo "  path           - Muestra rutas de los archivos .service y .timer"
    echo ""
    echo "Ejemplos:"
    echo "  timerctl notify-hour              # Ver estado"
    echo "  timerctl notify-hour enable       # Activar"
    echo "  timerctl sync-google restart      # Reiniciar tras modificar"
    echo "  timerctl notify-hour logs 10      # Últimas 10 líneas"
    exit 1
fi

NOMBRE="$1"
COMANDO="${2:-status}"
SERVICE_FILE="$HOME/.config/systemd/user/${NOMBRE}.service"
TIMER_FILE="$HOME/.config/systemd/user/${NOMBRE}.timer"

# Función para verificar si existe el timer
timer_exists() {
    systemctl --user list-timers --all | grep -q "${NOMBRE}.timer"
}

# Función para recargar systemd
reload_systemd() {
    echo -e "${YELLOW}→ Recargando systemd --user...${NC}"
    systemctl --user daemon-reload
}

case "$COMANDO" in
    enable)
        echo -e "${YELLOW}→ Activando timer: ${NOMBRE}${NC}"
        
        # Verificar que existan los archivos
        if [ ! -f "$SERVICE_FILE" ]; then
            echo -e "${RED}✗ Error: No existe $SERVICE_FILE${NC}"
            exit 1
        fi
        if [ ! -f "$TIMER_FILE" ]; then
            echo -e "${RED}✗ Error: No existe $TIMER_FILE${NC}"
            exit 1
        fi
        
        reload_systemd
        systemctl --user enable --now "${NOMBRE}.timer"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Timer ${NOMBRE} activado correctamente${NC}"
            echo ""
            systemctl --user list-timers | grep -E "(${NOMBRE}|NEXT)"
        else
            echo -e "${RED}✗ Error al activar${NC}"
            exit 1
        fi
        ;;
    
    disable)
        echo -e "${YELLOW}→ Desactivando timer: ${NOMBRE}${NC}"
        systemctl --user disable --now "${NOMBRE}.timer" 2>/dev/null
        echo -e "${GREEN}✓ Timer desactivado${NC}"
        ;;
    
    restart)
        echo -e "${YELLOW}→ Reiniciando timer: ${NOMBRE}${NC}"
        
        if [ ! -f "$TIMER_FILE" ]; then
            echo -e "${RED}✗ Error: No existe $TIMER_FILE${NC}"
            exit 1
        fi
        
        reload_systemd
        
        # Si está activo, lo reinicia; si no, lo activa
        if systemctl --user is-active --quiet "${NOMBRE}.timer"; then
            systemctl --user restart "${NOMBRE}.timer"
            echo -e "${GREEN}✓ Timer reiniciado${NC}"
        else
            systemctl --user enable --now "${NOMBRE}.timer"
            echo -e "${GREEN}✓ Timer activado (no estaba corriendo)${NC}"
        fi
        
        echo ""
        systemctl --user list-timers | grep -E "(${NOMBRE}|NEXT)"
        ;;
    
    status)
        echo -e "${YELLOW}=== Estado del timer: ${NOMBRE} ===${NC}"
        echo ""
        
        if timer_exists; then
            systemctl --user status "${NOMBRE}.service" --no-pager -l
            echo ""
            systemctl --user status "${NOMBRE}.timer" --no-pager -l
        else
            echo -e "${RED}✗ Timer ${NOMBRE} no encontrado${NC}"
            echo "¿Has creado los archivos?"
            echo "  $SERVICE_FILE"
            echo "  $TIMER_FILE"
            exit 1
        fi
        ;;
    
    logs)
        # Número de líneas a mostrar (por defecto 20)
        LINES="${3:-20}"
        echo -e "${YELLOW}=== Últimas $LINES líneas de ${NOMBRE} ===${NC}"
        journalctl --user -u "${NOMBRE}.service" -u "${NOMBRE}.timer" -n "$LINES" --no-pager
        ;;
    
    path)
        echo -e "${YELLOW}=== Rutas de los archivos ===${NC}"
        echo "Servicio: $SERVICE_FILE"
        echo "Timer:    $TIMER_FILE"
        echo ""
        if [ -f "$SERVICE_FILE" ]; then
            echo -e "${GREEN}✓ Servicio existe${NC}"
        else
            echo -e "${RED}✗ Servicio NO existe${NC}"
        fi
        if [ -f "$TIMER_FILE" ]; then
            echo -e "${GREEN}✓ Timer existe${NC}"
        else
            echo -e "${RED}✗ Timer NO existe${NC}"
        fi
        ;;
    
    *)
        echo -e "${RED}Comando desconocido: $COMANDO${NC}"
        exit 1
        ;;
esac
