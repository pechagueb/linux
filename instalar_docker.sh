#!/bin/bash

#Nombre: setup_docker-deb.sh
#Autor: Patricio Echagüe Ballesteros (YAPA Design)
#WEB: https://pechagueb.odoo.com/
#Descripción: Instala docker en Linux DEBIAN
#Fuente: https://docs.docker.com/engine/install/debian/

# Verificar si se está ejecutando como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root o usando sudo."
  exit 1
fi

# Actualizar el sistema
echo "Actualizando el sistema..."
apt-get update -y && apt-get upgrade -y

# Instalar dependencias necesarias
echo "Instalando dependencias necesarias..."
apt-get install ca-certificates curl

# Agregar la clave GPG de Docker
echo "Agregando la clave GPG de Docker..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Agregar el repositorio de Docker
echo "Agregando el repositorio de Docker..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Actualizar los paquetes del repositorio
echo "Actualizando los paquetes del repositorio..."
apt-get update -y

# Instalar Docker Engine
echo "Instalando Docker Engine..."
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verificar la instalación de Docker
echo "Verificando la instalación de Docker..."
docker --version

# Habilitar y arrancar el servicio Docker
echo "Habilitando y arrancando el servicio Docker..."
systemctl enable docker
systemctl start docker

# Confirmar que Docker está funcionando
echo "Verificando que Docker se está ejecutando..."
systemctl status docker --no-pager

# Agregar el usuario actual al grupo docker (opcional)
read -p "¿Deseas agregar el usuario actual al grupo 'docker'? Esto permite usar Docker sin sudo. [s/N]: " respuesta
if [[ "$respuesta" =~ ^[Ss]$ ]]; then
  usermod -aG docker $SUDO_USER
  echo "Usuario agregado al grupo 'docker'. Por favor, cierra y vuelve a iniciar sesión para que los cambios surtan efecto."
fi

echo "Instalación de Docker completada."
