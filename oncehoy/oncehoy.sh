#! /bin/bash

#Nombre: oncehoy.sh
#Autor: Patricio Echagüe Ballesteros (YAPA Design)
#WEB: https://pechagueb.odoo.com/
#Descripción: Genera número aleatorio de 5 digitos.

fecha=$(date)

echo "Número de la ONCE para hoy: $fecha"
echo "------------"

# sleep 5

echo $(printf "%05d" $(( $RANDOM % 100000 )))
echo "------------"
