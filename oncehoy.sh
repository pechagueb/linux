#! /bin/bash

fecha=$(date)

echo "Número de la ONCE para hoy: $fecha"
echo "------------"

# sleep 5

echo $(printf "%05d" $(( $RANDOM % 100000 )))
echo "------------"
