#!/bin/bash

#Nombre: setup_docker-deb.sh
#Autor: Patricio Echagüe Ballesteros (YAPA Design)
#WEB: 
#Descripción: Activa y desactiva Docker y servicios relacionados
#Asistido por Deep Seek

# Colores para output más legible
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar ayuda
show_help() {
    echo -e "${BLUE}Docker Service Manager${NC}"
    echo "Uso: $0 [opción]"
    echo ""
    echo "Opciones:"
    echo "  disable  - Desactivar Docker completamente (no inicia al arrancar)"
    echo "  enable   - Activar Docker (inicia automáticamente al arrancar)"
    echo "  stop     - Detener Docker ahora mismo"
    echo "  start    - Iniciar Docker ahora mismo"
    echo "  status   - Ver estado actual de Docker"
    echo "  remove   - Desinstalar Docker y containerd por completo"
    echo "  help     - Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0 disable  # Apagado rápido"
    echo "  $0 start    # Usar Docker temporalmente"
    echo "  $0 enable   # Revertir cambios"
}

# Función para verificar si se ejecuta como root
check_root() {
    if [ "$EUID" -ne 0 ]; then 
        echo -e "${RED}Por favor ejecuta como root (usa sudo)${NC}"
        exit 1
    fi
}

# Función para desactivar Docker
disable_docker() {
    echo -e "${YELLOW}🛑 Desactivando Docker y containerd...${NC}"
    
    # Detener servicios si están activos
    systemctl stop docker containerd docker.socket 2>/dev/null
    
    # Deshabilitar servicios
    systemctl disable docker containerd docker.socket 2>/dev/null
    
    # Aplicar mask (capas extra de seguridad)
    systemctl mask docker containerd docker.socket 2>/dev/null
    
    echo -e "${GREEN}✓ Docker desactivado completamente${NC}"
    echo -e "${YELLOW}Nota: Tus contenedores, imágenes y volúmenes permanecen intactos en /var/lib/docker${NC}"
    echo -e "${BLUE}Para usarlos temporalmente: sudo $0 start${NC}"
    echo -e "${BLUE}Para reactivar permanentemente: sudo $0 enable${NC}"
}

# Función para activar Docker
enable_docker() {
    echo -e "${YELLOW}🔄 Activando Docker y containerd...${NC}"
    
    # Deshacer mask
    systemctl unmask docker containerd docker.socket 2>/dev/null
    
    # Habilitar servicios para inicio automático
    systemctl enable docker containerd
    
    # Iniciar servicios
    systemctl start docker containerd
    
    echo -e "${GREEN}✓ Docker activado correctamente${NC}"
    systemctl status docker --no-pager | head -5
}

# Función para detener Docker (manteniendo habilitado)
stop_docker() {
    echo -e "${YELLOW}⏸️  Deteniendo Docker y containerd...${NC}"
    systemctl stop docker containerd docker.socket
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Servicios detenidos${NC}"
    else
        echo -e "${RED}✗ Error al detener servicios${NC}"
    fi
}

# Función para iniciar Docker
start_docker() {
    echo -e "${YELLOW}▶️  Iniciando Docker y containerd...${NC}"
    systemctl start docker containerd
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Servicios iniciados${NC}"
        echo -e "${BLUE}Estado actual:${NC}"
        systemctl status docker --no-pager | grep -E "Active:|Loaded:"
    else
        echo -e "${RED}✗ Error al iniciar servicios${NC}"
    fi
}

# Función para ver estado
show_status() {
    echo -e "${BLUE}📊 Estado de servicios Docker:${NC}"
    echo "-----------------------------------"
    for service in docker containerd; do
        echo -n "$service: "
        if systemctl is-active --quiet $service; then
            echo -e "${GREEN}Activo ✓${NC}"
        elif systemctl is-enabled --quiet $service 2>/dev/null; then
            echo -e "${YELLOW}Detenido pero habilitado ⏸️${NC}"
        else
            echo -e "${RED}Deshabilitado/Detenido ✗${NC}"
        fi
    done
    
    echo -e "\n${BLUE}Contenedores en el sistema:${NC}"
    docker ps -a 2>/dev/null | tail -n +2 | wc -l | xargs echo "  Total:"
    
    if [ $(docker ps -a 2>/dev/null | tail -n +2 | wc -l) -gt 0 ]; then
        echo -e "${YELLOW}  (Contenedores detenidos, no afectan el apagado)${NC}"
    fi
}

# Función para desinstalar completamente (⚠️ PELIGROSO)
remove_docker() {
    echo -e "${RED}⚠️  ADVERTENCIA: Esto ELIMINARÁ Docker y TODOS tus contenedores, imágenes y volúmenes${NC}"
    echo -e "${RED}⚠️  Esta acción es IRREVERSIBLE${NC}"
    echo -n "¿Estás absolutamente seguro? (escribe 'ELIMINAR' para continuar): "
    read confirmation
    
    if [ "$confirmation" != "ELIMINAR" ]; then
        echo -e "${YELLOW}Operación cancelada${NC}"
        return
    fi
    
    echo -e "${RED}🗑️  Eliminando Docker permanentemente...${NC}"
    
    # Detener y deshabilitar
    systemctl stop docker containerd docker.socket 2>/dev/null
    systemctl disable docker containerd docker.socket 2>/dev/null
    systemctl mask docker containerd docker.socket 2>/dev/null
    
    # Eliminar paquetes (para Arch/XeroLinux)
    pacman -Rns --noconfirm docker docker-compose containerd 2>/dev/null
    
    # Eliminar datos
    rm -rf /var/lib/docker
    rm -rf /var/lib/containerd
    rm -rf /etc/docker
    rm -rf ~/.docker
    
    echo -e "${GREEN}✓ Docker completamente eliminado${NC}"
}

# Menú principal
case "$1" in
    disable)
        check_root
        disable_docker
        ;;
    enable)
        check_root
        enable_docker
        ;;
    stop)
        check_root
        stop_docker
        ;;
    start)
        check_root
        start_docker
        ;;
    status)
        # No necesita root para status
        show_status
        ;;
    remove)
        check_root
        remove_docker
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Opción no válida: $1${NC}"
        show_help
        exit 1
        ;;
esac
