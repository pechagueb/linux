#!/bin/bash

# Nombre: instala_pakGUI.sh
# Autor: Patricio Echagüe Ballesteros (YAPA Design)
# WEB: https://pechagueb.odoo.com/
# Descripción: Instala paquetes en Linux ~DEBIAN con interfaz gráfica (Zenity)
#              Alternativa GUI a instala_pak.sh

# Archivo donde guardaremos la lista de paquetes
LISTA_APPS="lista_pak.txt"

# Si el archivo no existe, se crea con algunos ejemplos
if [ ! -f "$LISTA_APPS" ]; then
    echo "# Agrega aquí más paquetes, uno por línea. Las líneas que empiezan con # serán ignoradas." >> "$LISTA_APPS"
    echo "preload" >> "$LISTA_APPS"
    echo "git" >> "$LISTA_APPS"
    echo "curl" >> "$LISTA_APPS"
    echo "wget" >> "$LISTA_APPS"
    echo "nala" >> "$LISTA_APPS"
fi

# Función para contar paquetes válidos
contar_paquetes() {
    local count=0
    while IFS= read -r app; do
        [[ -z "$app" || "$app" =~ ^# ]] && continue
        ((count++))
    done < "$LISTA_APPS"
    echo "$count"
}

# Función para mostrar la interfaz de selección
seleccionar_aplicaciones() {
    # Leer paquetes del archivo, ignorando comentarios y líneas vacías
    local paquetes=()
    while IFS= read -r app; do
        [[ -z "$app" || "$app" =~ ^# ]] && continue
        paquetes+=("$app" "$app" "off")
    done < "$LISTA_APPS"

    # Mostrar checklist de Zenity
    local seleccionados=$(zenity --list \
        --title="Seleccionar aplicaciones para instalar" \
        --text="Selecciona las aplicaciones que deseas instalar:" \
        --checklist \
        --column="Instalar" \
        --column="Paquete" \
        --column="Nombre" \
        --width=600 \
        --height=400 \
        "${paquetes[@]}")

    echo "$seleccionados"
}

# Función para editar la lista de paquetes
editar_lista() {
    zenity --question \
        --title="Editar lista de paquetes" \
        --text="¿Deseas editar la lista de paquetes disponibles?\n\nArchivo: $LISTA_APPS" \
        --width=400

    if [ $? -eq 0 ]; then
        # Intentar usar el editor gráfico primero, luego nano como fallback
        # Optimizado para Debian, cambiar parámetros según necesidades
        if command -v kate &> /dev/null; then
            kate "$LISTA_APPS"
        elif command -v gedit &> /dev/null; then
            gedit "$LISTA_APPS"
        else
            #xterm -e "nano $LISTA_APPS"
            konsole "nano $LISTA_APPS"
        fi
    fi
}

# Función principal de instalación
instalar_paquetes() {
    local paquetes_seleccionados="$1"

    if [ -z "$paquetes_seleccionados" ]; then
        zenity --warning \
            --text="No se seleccionó ningún paquete para instalar." \
            --width=300
        return 1
    fi

    # Convertir la selección (separada por |) en array
    IFS='|' read -ra paquetes <<< "$paquetes_seleccionados"

    # Mostrar resumen de instalación
    local resumen="Paquetes seleccionados para instalar:\n\n"
    for pkg in "${paquetes[@]}"; do
        resumen+="• $pkg\n"
    done

    zenity --question \
        --title="Confirmar instalación" \
        --text="$resumen\n¿Continuar con la instalación?" \
        --width=500 \
        --ok-label="Instalar" \
        --cancel-label="Cancelar"

    if [ $? -ne 0 ]; then
        zenity --info --text="Instalación cancelada." --width=300
        return 1
    fi

    # Actualizar repositorios
    (
        echo "10" ; sleep 1
        echo "# Actualizando lista de paquetes..." ; sleep 1
        if ! sudo apt update; then
            zenity --error --text="Error al actualizar los repositorios." --width=400
            exit 1
        fi
        echo "30" ; sleep 1

        # Instalar cada paquete
        local total=${#paquetes[@]}
        local progreso=30
        local incremento=$((70 / total))

        for ((i=0; i<total; i++)); do
            local pkg="${paquetes[$i]}"
            local porcentaje_actual=$((progreso + (i * incremento) / total))

            echo "$porcentaje_actual"
            echo "# Instalando: $pkg ($((i+1))/$total)"

            if ! sudo apt install -y "$pkg" 2>&1; then
                zenity --error --text="Error al instalar: $pkg" --width=400
                exit 1
            fi

            sleep 1
        done

        echo "100"
        echo "# Instalación completada"
        sleep 1

    ) | zenity --progress \
        --title="Instalando paquetes" \
        --text="Preparando instalación..." \
        --percentage=0 \
        --auto-close \
        --width=400

    if [ $? -eq 0 ]; then
        zenity --info \
            --text="Instalación completada exitosamente!" \
            --width=300
    else
        zenity --error \
            --text="Ocurrió un error durante la instalación." \
            --width=400
    fi
}

# Función para instalar todos los paquetes
instalar_todos() {
    local total_paquetes=$(contar_paquetes)

    if [ "$total_paquetes" -eq 0 ]; then
        zenity --warning \
            --text="No hay paquetes válidos en la lista para instalar.\n\nRevisa el archivo: $LISTA_APPS" \
            --width=400
        return 1
    fi

    # Obtener lista de paquetes para mostrar
    local paquetes=($(obtener_paquetes))
    local resumen="Se instalarán TODOS los paquetes de la lista:\n\n"
    for pkg in "${paquetes[@]}"; do
        resumen+="• $pkg\n"
    done
    resumen+="\nTotal: $total_paquetes paquetes"

    zenity --question \
        --title="Instalar TODOS los paquetes" \
        --text="$resumen\n\n¿Continuar con la instalación completa?" \
        --width=500 \
        --ok-label="Instalar Todo" \
        --cancel-label="Cancelar"

    if [ $? -ne 0 ]; then
        zenity --info --text="Instalación cancelada." --width=300
        return 1
    fi

    # Actualizar repositorios e instalar todos los paquetes
    (
        echo "10" ; sleep 1
        echo "# Actualizando lista de paquetes..." ; sleep 1
        if ! sudo apt update 2>/dev/null; then
            zenity --error --text="Error al actualizar los repositorios." --width=400
            exit 1
        fi
        echo "30" ; sleep 1

        # Instalar todos los paquetes en un solo comando (más eficiente)
        local paquetes_para_instalar=($(obtener_paquetes))

        echo "50"
        echo "# Instalando todos los paquetes..."

        if ! sudo apt install -y "${paquetes_para_instalar[@]}" 2>/dev/null; then
            zenity --error --text="Error durante la instalación de paquetes." --width=400
            exit 1
        fi

        echo "100"
        echo "# Instalación completada"
        sleep 1

    ) | zenity --progress \
        --title="Instalando TODOS los paquetes" \
        --text="Preparando instalación completa..." \
        --percentage=0 \
        --auto-close \
        --width=400

    if [ $? -eq 0 ]; then
        zenity --info \
            --text="¡Instalación completa finalizada exitosamente!\n\nSe instalaron $total_paquetes paquetes." \
            --width=400
    else
        zenity --error \
            --text="Ocurrió un error durante la instalación." \
            --width=400
    fi
}

# Función para mostrar el menú principal
menu_principal() {
    while true; do
        local total_paquetes=$(contar_paquetes)
        local opcion=$(zenity --list \
            --title="Instalador de Paquetes ($total_paquetes paquetes en lista)" \
            --text="Selecciona una opción:" \
            --radiolist \
            --column="Seleccionar" \
            --column="Opción" \
            --column="Descripción" \
            TRUE "Seleccionar" "Elegir aplicaciones específicas para instalar" \
            FALSE "Instalar Todo" "Instalar TODOS los paquetes de la lista" \
            FALSE "Editar lista" "Modificar lista de paquetes disponibles" \
            FALSE "Salir" "Cerrar el programa" \
            --width=600 \
            --height=250)

        case "$opcion" in
            "Seleccionar")
                local seleccion=$(seleccionar_aplicaciones)
                instalar_paquetes "$seleccion"
                ;;
            "Instalar Todo")
                instalar_todos
                ;;
            "Editar lista")
                editar_lista
                ;;
            "Salir"|"")
                zenity --info --text="¡Hasta luego!" --width=200
                exit 0
                ;;
        esac
    done
}

# Verificar si zenity está instalado
if ! command -v zenity &> /dev/null; then
    echo "Zenity no está instalado. Instalando..."
    sudo apt update && sudo apt install -y zenity
    if [ $? -ne 0 ]; then
        echo "Error: No se pudo instalar Zenity."
        exit 1
    fi
fi

# Ejecutar menú principal
menu_principal
