# 🖥️ instala_pak.sh

Como profesional que navega frecuentemente entre diferentes distribuciones Linux (Debian, Arch, Fedora, openSUSE), identifiqué una necesidad recurrente: mantener un flujo de trabajo consistente para la instalación de paquetes sin recordar comandos específicos de cada gestor.

Preparé un script en Bash que automatiza la instalación de paquetes a partir de una lista guardada en un archivo de texto. 

Este enfoque simplifica la configuración de entornos, ahorra tiempo y asegura que el proceso sea repetible y confiable.

## ¿Cómo funciona?

☑️ Ejecutar el script.
☑️ Edita la lista (⚠️) *Haz una copia del .txt para futuras instalaciones.
☑️ El script instala cada elemento de la lista sin intervención manual.

Este tipo de automatización es especialmente útil al migrar a un nuevo equipo, configurar servidores o mantener entornos consistentes en proyectos colaborativos.

✴️ Disponible versión 2.0 ✴️
- Multidistro (detecta manejador de paquetería)
- Actualización sistema
- Simula instalación (para verificación)
- Limpia caché o obsoletos

### Ejecutar normalmente
./instala_pak.sh (dar permisos de ejecutable)

### Flujo recomendado:
1. Opción 1 - Detectar sistema
2. Opción 8 - Simular antes de instalar
3. Opción 3 - Instalar si todo está bien

## 🇪🇺 (En breve estarán disponibles traducciones)

# Continuando con la exploración del potencial de 'bash', he agregado una versión del script anterior con una interfaz gráfica (Zenity) facilitando la experiencia del usuario.

✴️ NOTA: instala_pakGUI.sh
👾 GUI (beta) 🤓
👷🏽 En desarrollo 🔧

