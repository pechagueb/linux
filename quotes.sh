#!/bin/bash

#Nombre: quotes.sh
#Autor: Patricio Echagüe Ballesteros (YAPA Design)
#WEB: https://pechagueb.odoo.com/
#Descripción: Muestra una frase extraída al azar de un fichero de texto

# Verifica que se haya proporcionado un archivo como argumento
if [ "$#" -ne 1 ]; then
    echo "Uso: $0 archivo_de_frases.txt"
    exit 1
fi

archivo="$1"

# Verifica que el archivo existe y no está vacío
if [ ! -f "$archivo" ] || [ ! -s "$archivo" ]; then
    echo "El archivo no existe o está vacío."
    exit 1
fi

# Cuenta el número de líneas en el archivo
num_lineas=$(wc -l < "$archivo")

# Genera un número aleatorio entre 1 y el número de líneas
linea_aleatoria=$((RANDOM % num_lineas + 1))

# Extrae y muestra la línea aleatoria
frase=$(sed -n "${linea_aleatoria}p" "$archivo")
echo "$frase"
