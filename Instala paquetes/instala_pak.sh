#!/bin/bash

#Nombre: instala_pak.sh
#Autor: Patricio Echagüe Ballesteros (YAPA Design)
#WEB: https://pechagueb.odoo.com/
#Descripción: Instala paquetes en Linux ~DEBIAN

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

# Editar lista
sudo nano "$LISTA_APPS"

# Actualizar repositorios
echo "Actualizando lista de paquetes en: $LISTA_APPS "

sudo apt update

# Leer archivo línea por línea e instalar paquetes
while IFS= read -r app; do
    
    # Ignorar líneas vacías y comentarios
    [[ -z "$app" || "$app" =~ ^# ]] && continue
    
    
    echo "Instalando $app..."
    sudo apt install -y "$app"

done < "$LISTA_APPS"

echo "=== Instalación finalizada ==="

