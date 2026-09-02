# Zen Browser Linux Optimizer

Script interactivo en Bash diseñado para maximizar el rendimiento, la aceleración por hardware y la gestión de recursos de **Zen Browser** en Linux mediante la creación de un archivo de configuración `user.js` optimizado.

### Características Principales
* **Detección automática:** Localiza de forma precisa el directorio activo de perfiles en `~/.config/zen`.
* **Control interactivo:** Permite aplicar o descartar mejoras específicas mediante consultas modulares.
* **Aceleración por hardware:** Habilita WebGPU, capas avanzadas de WebRender y decodificación de vídeo por GPU.
* **Ajuste de CPU y hilos:** Adapta la asignación multiproceso según los hilos del procesador
* **Gestión de códecs y caché:** Activa la decodificación VA-API y optimiza las preferencias de memoria y disco.
* **Respaldos automáticos:** Genera una copia de seguridad segura con marca de tiempo antes de sobrescribir configuraciones previas.

### Inicio Rápido
Concede permisos de ejecución y ejecuta el script directamente en tu terminal:
```bash
chmod +x zenBroswer-optimizer.sh
./zenBroswer-optimizer.sh
