¡Hola, navegante de la terminal! 🐧 ¿Cansado de instalar Docker a mano y que se te olvide un paso? ¡Este script es tu nuevo mejor amigo! 🤖

**instalar_docker.sh** viene al rescate 🦸‍♂️. Con solo un comando, seguirá **AUTOMÁGICAMENTE** la guía oficial de Docker para preparar tu Debian.

¿Qué hace esta joya? ✨:
- Limpia restos de instalaciones viejas 🧹
- Añade los repositorios oficiales 🔑
- Instala todos los componentes necesarios 📦
- Y todo con estilo y logs coloridos 🌈

¡Ejecuta `./instalar_docker.sh` y prepárate para la magia! 🎩🐇 Tu futuro con contenedores está a un script de distancia. ¡Let's go! 🚀

**PD:** Como todo gran poder, requiere responsabilidad... y `sudo` 😉.

**docker_toggler**
Uso: ./docker_toggler.sh [opción]

Opciones:
  disable  - Desactivar Docker completamente (no inicia al arrancar)
  enable   - Activar Docker (inicia automáticamente al arrancar)
  stop     - Detener Docker ahora mismo
  start    - Iniciar Docker ahora mismo
  status   - Ver estado actual de Docker
  remove   - Desinstalar Docker y containerd por completo
  help     - Mostrar esta ayuda

Ejemplos:
  ./docker_toggler.sh disable  # Apagado rápido
  ./docker_toggler.sh start    # Usar Docker temporalmente
  ./docker_toggler.sh enable   # Revertir cambios

