#!/bin/bash

# Copias a unidad externa antes de cerrar sesión
rsync -a --delete ~/Imágenes/ /mnt/0416CE2846AE4C1D/docs/Imágenes
rsync -a --delete ~/Documentos/ /mnt/0416CE2846AE4C1D/docs/Documentos
rsync -a --delete ~/Vídeos/ /mnt/0416CE2846AE4C1D/docs/Vídeos
rsync -a --delete ~/Descargas/ /mnt/0416CE2846AE4C1D/docs/Descargas
