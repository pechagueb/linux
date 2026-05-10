#!/bin/bash

# ============================================
# Multi-Pak Installer v2.0 - Versión Monospace
# Autor: Patricio Echagüe Ballesteros (YAPA Design)
# WEB: ...en construccion (@yapadesign - Facebook)
# Descripción: Instalador universal de paquetes a partir de archivo ".txt"
# ============================================

# Colores para interfaz (compatibles con todas las terminales)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Variables globales
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LISTA_APPS="$SCRIPT_DIR/lista_pak.txt"
DISTRO=""
PACKAGE_MANAGER=""
INSTALL_CMD=""
UPDATE_CMD=""
SEARCH_CMD=""
SIMULATION_MODE=false

# ============================================
# FUNCIONES DE INTERFAZ (SIN CARACTERES UNICODE)
# ============================================

print_header() {
    clear
    echo -e "${CYAN}====================================================================${NC}"
    echo -e "${CYAN}     Multi-Pak Installer v2.0 - Instalador Universal${NC}"
    echo -e "${CYAN}     ${PURPLE}YAPA Design - Patricio Echague B.${NC}"
    echo -e "${CYAN}====================================================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}[OK] $1${NC}"
}

print_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

print_info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[WARN] $1${NC}"
}

print_step() {
    echo -e "${CYAN}[>>] $1${NC}"
}

show_menu() {
    echo ""
    echo -e "${BOLD}--------------------------------------------------------------------${NC}"
    echo -e "${BOLD}                         MENU PRINCIPAL${NC}"
    echo -e "${BOLD}--------------------------------------------------------------------${NC}"
    echo -e "  ${GREEN}1)${NC} Detectar distribucion y gestor de paquetes"
    echo -e "  ${GREEN}2)${NC} Editar lista de paquetes"
    echo -e "  ${GREEN}3)${NC} Instalar paquetes desde la lista"
    echo -e "  ${GREEN}4)${NC} Actualizar sistema completo"
    echo -e "  ${GREEN}5)${NC} Buscar y agregar nuevo paquete"
    echo -e "  ${GREEN}6)${NC} Ver lista actual de paquetes"
    echo -e "  ${GREEN}7)${NC} Limpiar cache y paquetes obsoletos"
    echo -e "  ${GREEN}8)${NC} MODO SIMULACION - Ver que se instalara"
    echo -e "  ${RED}9)${NC} Salir"
    echo -e "${BOLD}--------------------------------------------------------------------${NC}"
    echo ""
    echo -ne "${BOLD}Selecciona una opcion [1-9]: ${NC}"
}

# ============================================
# FUNCIONES DE DETECCION
# ============================================

detect_distro() {
    print_step "Detectando distribucion Linux..."
    sleep 1
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        print_success "Distribucion detectada: ${BOLD}$NAME${NC}"
    else
        print_error "No se pudo detectar la distribucion"
        DISTRO="unknown"
    fi
    
    # Detectar gestor de paquetes
    if command -v apt &> /dev/null; then
        PACKAGE_MANAGER="apt"
        INSTALL_CMD="sudo apt install -y"
        UPDATE_CMD="sudo apt update"
        SEARCH_CMD="apt search"
        print_success "Gestor de paquetes: APT (Debian/Ubuntu)"
    elif command -v dnf &> /dev/null; then
        PACKAGE_MANAGER="dnf"
        INSTALL_CMD="sudo dnf install -y"
        UPDATE_CMD="sudo dnf check-update"
        SEARCH_CMD="dnf search"
        print_success "Gestor de paquetes: DNF (Fedora/RHEL)"
    elif command -v pacman &> /dev/null; then
        PACKAGE_MANAGER="pacman"
        INSTALL_CMD="sudo pacman -S --noconfirm"
        UPDATE_CMD="sudo pacman -Sy"
        SEARCH_CMD="pacman -Ss"
        print_success "Gestor de paquetes: PACMAN (Arch/Manjaro/XeroLinux)"
    elif command -v zypper &> /dev/null; then
        PACKAGE_MANAGER="zypper"
        INSTALL_CMD="sudo zypper install -y"
        UPDATE_CMD="sudo zypper refresh"
        SEARCH_CMD="zypper search"
        print_success "Gestor de paquetes: Zypper (openSUSE)"
    elif command -v apk &> /dev/null; then
        PACKAGE_MANAGER="apk"
        INSTALL_CMD="sudo apk add"
        UPDATE_CMD="sudo apk update"
        SEARCH_CMD="apk search"
        print_success "Gestor de paquetes: APK (Alpine)"
    else
        print_error "No se detecto ningun gestor de paquetes conocido"
        return 1
    fi
    
    return 0
}

# ============================================
# FUNCIONES DE INSTALACION
# ============================================

create_default_list() {
    if [ ! -f "$LISTA_APPS" ]; then
        print_info "Creando archivo de lista por defecto..."
        cat > "$LISTA_APPS" << 'EOF'
# ============================================
# Lista de paquetes a instalar
# Las lineas que empiezan con # son ignoradas
# Agrega un paquete por linea
# ============================================

# Paquetes esenciales
git
curl
wget
htop
neofetch

# Desarrollo
base-devel
gcc
make
python3
python-pip

# Multimedia
ffmpeg
vlc

# Utilidades
btop
p7zip
EOF
        print_success "Archivo de lista creado: $LISTA_APPS"
    fi
}

edit_package_list() {
    print_step "Abriendo editor para modificar la lista de paquetes..."
    sleep 1
    
    if command -v nano &> /dev/null; then
        nano "$LISTA_APPS"
    elif command -v vim &> /dev/null; then
        vim "$LISTA_APPS"
    elif command -v vi &> /dev/null; then
        vi "$LISTA_APPS"
    else
        print_error "No se encontro un editor de texto (nano, vim, vi)"
        print_info "Instalando nano..."
        sudo pacman -S --noconfirm nano
        nano "$LISTA_APPS"
    fi
    print_success "Lista actualizada"
}

check_system_updates() {
    print_step "Verificando actualizaciones del sistema..."
    
    echo -e "${YELLOW}"
    $UPDATE_CMD
    echo -e "${NC}"
    
    if [ $? -eq 0 ]; then
        print_success "Repositorios actualizados correctamente"
    else
        print_error "Error al actualizar repositorios"
        return 1
    fi
    
    # Actualizar paquetes del sistema
    echo ""
    read -p "Deseas actualizar todos los paquetes del sistema? (s/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        print_step "Actualizando paquetes del sistema..."
        case $PACKAGE_MANAGER in
            apt)
                sudo apt upgrade -y
                sudo apt autoremove -y
                ;;
            dnf)
                sudo dnf upgrade -y
                sudo dnf autoremove -y
                ;;
            pacman)
                sudo pacman -Su --noconfirm
                ;;
            zypper)
                sudo zypper update -y
                ;;
        esac
        print_success "Sistema actualizado"
    fi
}

# ============================================
# MODO SIMULACION - SEGURO Y SIN CAMBIOS
# ============================================

simulate_installation() {
    print_header
    echo -e "${YELLOW}====================================================================${NC}"
    echo -e "${YELLOW}                    MODO SIMULACION ACTIVADO${NC}"
    echo -e "${YELLOW}           NO se realizaran cambios en tu sistema${NC}"
    echo -e "${YELLOW}====================================================================${NC}"
    echo ""
    
    if [ ! -f "$LISTA_APPS" ]; then
        print_error "No se encuentra el archivo de lista: $LISTA_APPS"
        print_info "Puedes crear una lista usando la opcion 2 del menu"
        echo ""
        read -p "Presiona Enter para continuar..."
        return
    fi
    
    if [ -z "$PACKAGE_MANAGER" ]; then
        print_warning "Primero detecta tu distribucion (Opcion 1)"
        echo ""
        read -p "Presiona Enter para continuar..."
        return
    fi
    
    echo -e "${BOLD}====================================================================${NC}"
    echo -e "${BOLD}ANALISIS DE PAQUETES EN: ${CYAN}$LISTA_APPS${NC}"
    echo -e "${BOLD}====================================================================${NC}"
    echo ""
    
    local total=0
    local installed=0
    local pending=0
    local not_available=0
    
    # Mostrar paquetes con su estado
    while IFS= read -r app; do
        [[ -z "$app" || "$app" =~ ^# ]] && continue
        
        ((total++))
        
        # Verificar si el paquete ya esta instalado segun el gestor
        local status=""
        local pkg_name="$app"
        
        # Adaptar nombres segun el gestor
        case $PACKAGE_MANAGER in
            pacman)
                if pacman -Q "$app" &>/dev/null 2>&1; then
                    status="${GREEN}[INSTALADO]${NC}"
                    ((installed++))
                else
                    # Verificar si existe en repositorios
                    if pacman -Si "$app" &>/dev/null 2>&1; then
                        status="${YELLOW}[PENDIENTE]${NC}"
                        ((pending++))
                    else
                        status="${RED}[NO DISPONIBLE]${NC}"
                        ((not_available++))
                    fi
                fi
                ;;
            apt)
                if dpkg -l | grep -q "^ii  $app "; then
                    status="${GREEN}[INSTALADO]${NC}"
                    ((installed++))
                else
                    if apt-cache show "$app" &>/dev/null 2>&1; then
                        status="${YELLOW}[PENDIENTE]${NC}"
                        ((pending++))
                    else
                        status="${RED}[NO DISPONIBLE]${NC}"
                        ((not_available++))
                    fi
                fi
                ;;
            dnf)
                if rpm -q "$app" &>/dev/null 2>&1; then
                    status="${GREEN}[INSTALADO]${NC}"
                    ((installed++))
                else
                    if dnf list "$app" &>/dev/null 2>&1; then
                        status="${YELLOW}[PENDIENTE]${NC}"
                        ((pending++))
                    else
                        status="${RED}[NO DISPONIBLE]${NC}"
                        ((not_available++))
                    fi
                fi
                ;;
            *)
                status="${YELLOW}[DESCONOCIDO]${NC}"
                ((pending++))
                ;;
        esac
        
        echo -e "  ${CYAN}>${NC} ${BOLD}$app${NC} - $status"
    done < "$LISTA_APPS"
    
    echo ""
    echo -e "${BOLD}====================================================================${NC}"
    echo -e "${CYAN}RESUMEN DE LA SIMULACION:${NC}"
    echo -e "${BOLD}====================================================================${NC}"
    echo -e "${GREEN}[INSTALADO]${NC}    Paquetes ya instalados: $installed"
    echo -e "${YELLOW}[PENDIENTE]${NC}   Paquetes por instalar: $pending"
    echo -e "${RED}[NO DISPONIBLE]${NC} Paquetes no disponibles: $not_available"
    echo -e "${CYAN}[TOTAL]${NC}        Total de paquetes en lista: $total"
    echo ""
    echo -e "${YELLOW}IMPORTANTE:${NC}"
    echo -e "  * ${BLUE}Ningun cambio${NC} se ha aplicado a tu sistema"
    echo -e "  * Los paquetes '${RED}NO DISPONIBLES${NC}' necesitan nombres alternativos"
    echo -e "  * Usa la ${GREEN}Opcion 5 (Buscar paquete)${NC} para encontrar nombres correctos"
    echo ""
    
    if [ $pending -gt 0 ]; then
        echo -e "${GREEN}[SUGERENCIA] Si ejecutas la instalacion real (Opcion 3), se instalaran $pending paquetes${NC}"
    fi
    
    if [ $not_available -gt 0 ]; then
        echo -e "${RED}[SUGERENCIA] Los $not_available paquetes no disponibles necesitan atencion${NC}"
    fi
    
    echo ""
    read -p "Presiona Enter para continuar..."
}

install_packages() {
    if [ ! -f "$LISTA_APPS" ]; then
        print_error "No se encuentra el archivo de lista: $LISTA_APPS"
        create_default_list
    fi
    
    print_step "Instalando paquetes desde: $LISTA_APPS"
    echo ""
    
    # Contar paquetes a instalar
    local total_packages=0
    local installed=0
    local failed=0
    local skipped=0
    
    # Primera pasada: contar paquetes pendientes
    while IFS= read -r app; do
        [[ -z "$app" || "$app" =~ ^# ]] && continue
        
        # Verificar si ya esta instalado
        local already_installed=false
        case $PACKAGE_MANAGER in
            pacman)
                if pacman -Q "$app" &>/dev/null 2>&1; then
                    already_installed=true
                fi
                ;;
            apt)
                if dpkg -l | grep -q "^ii  $app "; then
                    already_installed=true
                fi
                ;;
            dnf)
                if rpm -q "$app" &>/dev/null 2>&1; then
                    already_installed=true
                fi
                ;;
        esac
        
        if [ "$already_installed" = false ]; then
            ((total_packages++))
        fi
    done < "$LISTA_APPS"
    
    if [ $total_packages -eq 0 ]; then
        print_warning "No hay paquetes nuevos para instalar (todos ya estan instalados)"
        return
    fi
    
    print_info "Se instalaran $total_packages paquetes nuevos"
    echo ""
    read -p "Deseas continuar con la instalacion? (s/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        print_info "Instalacion cancelada"
        return
    fi
    
    # Instalar paquetes
    while IFS= read -r app; do
        [[ -z "$app" || "$app" =~ ^# ]] && continue
        
        # Verificar si ya esta instalado
        case $PACKAGE_MANAGER in
            pacman)
                if pacman -Q "$app" &>/dev/null 2>&1; then
                    echo -e "${CYAN}[SKIP]${NC} $app ${GREEN}[ya instalado]${NC}"
                    ((skipped++))
                    continue
                fi
                ;;
            apt)
                if dpkg -l | grep -q "^ii  $app "; then
                    echo -e "${CYAN}[SKIP]${NC} $app ${GREEN}[ya instalado]${NC}"
                    ((skipped++))
                    continue
                fi
                ;;
            dnf)
                if rpm -q "$app" &>/dev/null 2>&1; then
                    echo -e "${CYAN}[SKIP]${NC} $app ${GREEN}[ya instalado]${NC}"
                    ((skipped++))
                    continue
                fi
                ;;
        esac
        
        echo -ne "${CYAN}[INST]${NC} $app ... "
        
        # Adaptar nombres de paquetes segun la distribucion
        local pkg_name="$app"
        
        case $PACKAGE_MANAGER in
            pacman)
                [[ "$app" == "build-essential" ]] && pkg_name="base-devel"
                [[ "$app" == "nala" ]] && pkg_name=""
                [[ "$app" == "python3-pip" ]] && pkg_name="python-pip"
                [[ "$app" == "python3" ]] && pkg_name="python"
                ;;
            apt)
                [[ "$app" == "base-devel" ]] && pkg_name="build-essential"
                [[ "$app" == "python-pip" ]] && pkg_name="python3-pip"
                [[ "$app" == "python" ]] && pkg_name="python3"
                ;;
            dnf)
                [[ "$app" == "build-essential" ]] && pkg_name="@development-tools"
                [[ "$app" == "nala" ]] && pkg_name=""
                ;;
        esac
        
        if [ -z "$pkg_name" ]; then
            print_error "Paquete $app no disponible en $PACKAGE_MANAGER"
            ((failed++))
            continue
        fi
        
        # Ejecutar instalacion
        if $INSTALL_CMD "$pkg_name" &> /dev/null; then
            print_success "Instalado"
            ((installed++))
        else
            print_error "Error"
            ((failed++))
        fi
        
        sleep 0.5
    done < "$LISTA_APPS"
    
    echo ""
    echo "===================================================================="
    print_success "Instalacion completada"
    echo -e "${GREEN}Instalados nuevos: $installed${NC}"
    echo -e "${CYAN}Ya estaban instalados: $skipped${NC}"
    echo -e "${RED}Fallidos: $failed${NC}"
    echo "===================================================================="
}

search_and_add_package() {
    print_step "Busqueda de paquetes"
    echo ""
    read -p "Ingresa el nombre del paquete a buscar: " search_term
    
    if [ -z "$search_term" ]; then
        print_error "Termino de busqueda vacio"
        return
    fi
    
    print_info "Buscando en repositorios..."
    echo ""
    
    case $PACKAGE_MANAGER in
        apt)
            apt search "$search_term" 2>/dev/null | head -20
            ;;
        dnf)
            dnf search "$search_term" 2>/dev/null | head -20
            ;;
        pacman)
            pacman -Ss "$search_term" 2>/dev/null | head -20
            ;;
        zypper)
            zypper search "$search_term" 2>/dev/null | head -20
            ;;
    esac
    
    echo ""
    read -p "Deseas agregar algun paquete a la lista? (s/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        read -p "Nombre del paquete a agregar: " new_package
        if [ -n "$new_package" ]; then
            echo "$new_package" >> "$LISTA_APPS"
            print_success "Paquete '$new_package' agregado a la lista"
        fi
    fi
}

show_package_list() {
    print_step "Lista actual de paquetes"
    echo ""
    
    if [ ! -f "$LISTA_APPS" ]; then
        print_error "No existe el archivo de lista"
        return
    fi
    
    echo -e "${BOLD}====================================================================${NC}"
    echo -e "${BOLD}CONTENIDO DE: $LISTA_APPS${NC}"
    echo -e "${BOLD}====================================================================${NC}"
    echo ""
    
    local count=0
    while IFS= read -r line; do
        if [[ ! -z "$line" && ! "$line" =~ ^# ]]; then
            # Verificar si esta instalado
            local installed_mark=""
            if [ -n "$PACKAGE_MANAGER" ]; then
                case $PACKAGE_MANAGER in
                    pacman)
                        if pacman -Q "$line" &>/dev/null 2>&1; then
                            installed_mark="${GREEN}[OK]${NC}"
                        else
                            installed_mark="${YELLOW}[NO]${NC}"
                        fi
                        ;;
                    apt)
                        if dpkg -l | grep -q "^ii  $line "; then
                            installed_mark="${GREEN}[OK]${NC}"
                        else
                            installed_mark="${YELLOW}[NO]${NC}"
                        fi
                        ;;
                esac
            fi
            echo -e "${installed_mark} $line"
            ((count++))
        elif [[ "$line" =~ ^# && ${#line} -gt 1 ]]; then
            echo -e "${CYAN}[#]${NC} ${line:0:70}"
        else
            echo "$line"
        fi
    done < "$LISTA_APPS"
    
    echo ""
    echo -e "${BOLD}====================================================================${NC}"
    echo -e "${CYAN}Total de paquetes activos: $count${NC}"
    echo -e "${GREEN}[OK]${NC} = Instalado  |  ${YELLOW}[NO]${NC} = No instalado"
    echo ""
    read -p "Presiona Enter para continuar..."
}

clean_system() {
    print_step "Limpiando cache y paquetes obsoletos..."
    echo ""
    
    case $PACKAGE_MANAGER in
        apt)
            print_info "Limpiando cache APT..."
            sudo apt autoclean
            sudo apt autoremove -y
            sudo apt clean
            ;;
        dnf)
            print_info "Limpiando cache DNF..."
            sudo dnf clean all
            sudo dnf autoremove -y
            ;;
        pacman)
            print_info "Limpiando cache PACMAN..."
            sudo pacman -Sc --noconfirm
            sudo pacman -Rns $(pacman -Qdtq) 2>/dev/null
            ;;
        zypper)
            print_info "Limpiando cache Zypper..."
            sudo zypper clean
            sudo zypper packages --unneeded
            ;;
    esac
    
    print_success "Limpieza completada"
    
    # Mostrar espacio liberado
    echo ""
    print_info "Espacio en disco:"
    df -h / | tail -1
    echo ""
    read -p "Presiona Enter para continuar..."
}

# ============================================
# FUNCION PRINCIPAL
# ============================================

main() {
    while true; do
        print_header
        
        # Mostrar informacion de distribucion si esta detectada
        if [ -n "$DISTRO" ] && [ -n "$PACKAGE_MANAGER" ]; then
            echo -e "${GREEN}[SISTEMA]${NC} $DISTRO | ${CYAN}[GESTOR]${NC} $PACKAGE_MANAGER"
            echo ""
        fi
        
        show_menu
        read option
        
        case $option in
            1)
                print_header
                detect_distro
                echo ""
                read -p "Presiona Enter para continuar..."
                ;;
            2)
                print_header
                edit_package_list
                echo ""
                read -p "Presiona Enter para continuar..."
                ;;
            3)
                print_header
                if [ -z "$PACKAGE_MANAGER" ]; then
                    print_warning "Primero detecta tu distribucion (Opcion 1)"
                    sleep 2
                    continue
                fi
                install_packages
                echo ""
                read -p "Presiona Enter para continuar..."
                ;;
            4)
                print_header
                if [ -z "$PACKAGE_MANAGER" ]; then
                    print_warning "Primero detecta tu distribucion (Opcion 1)"
                    sleep 2
                    continue
                fi
                check_system_updates
                echo ""
                read -p "Presiona Enter para continuar..."
                ;;
            5)
                print_header
                if [ -z "$PACKAGE_MANAGER" ]; then
                    print_warning "Primero detecta tu distribucion (Opcion 1)"
                    sleep 2
                    continue
                fi
                search_and_add_package
                echo ""
                read -p "Presiona Enter para continuar..."
                ;;
            6)
                print_header
                show_package_list
                ;;
            7)
                print_header
                if [ -z "$PACKAGE_MANAGER" ]; then
                    print_warning "Primero detecta tu distribucion (Opcion 1)"
                    sleep 2
                    continue
                fi
                clean_system
                ;;
            8)
                print_header
                simulate_installation
                ;;
            9)
                print_header
                echo -e "${GREEN}Gracias por usar Multi-Pak Installer!${NC}"
                echo -e "${PURPLE}YAPA Design - Tu aliado en Linux${NC}"
                echo ""
                exit 0
                ;;
            *)
                print_error "Opcion invalida"
                sleep 1
                ;;
        esac
    done
}

# ============================================
# EJECUCION DEL SCRIPT
# ============================================

# Verificar si se ejecuta como root (no recomendado)
if [ "$EUID" -eq 0 ]; then
    print_error "No ejecutes este script como root. Usa tu usuario normal."
    print_info "El script usara 'sudo' cuando sea necesario."
    exit 1
fi

# Crear archivo de lista si no existe
create_default_list

# Ejecutar programa principal
main
