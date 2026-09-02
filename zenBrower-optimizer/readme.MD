# Zen Browser Linux Optimizer

Script interactivo en Bash diseñado para maximizar el rendimiento, la aceleración por hardware y la gestión de recursos de **Zen Browser** en Linux mediante la creación de un archivo de configuración `user.js` optimizado[cite: 2].

### Características Principales
* **Detección automática:** Localiza de forma precisa el directorio activo de perfiles en `~/.config/zen`[cite: 2].
* **Control interactivo:** Permite aplicar o descartar mejoras específicas mediante consultas modulares[cite: 2].
* **Aceleración por hardware:** Habilita WebGPU, capas avanzadas de WebRender y decodificación de vídeo por GPU[cite: 2].
* **Ajuste de CPU y hilos:** Adapta la asignación multiproceso según los hilos del procesador[cite: 2].
* **Gestión de códecs y caché:** Activa la decodificación VA-API y optimiza las preferencias de memoria y disco[cite: 2].
* **Respaldos automáticos:** Genera una copia de seguridad segura con marca de tiempo antes de sobrescribir configuraciones previas.

### Inicio Rápido
Concede permisos de ejecución y ejecuta el script directamente en tu terminal[cite: 2]:
```bash
chmod +x zenBroswer-optimizer.sh
./zenBroswer-optimizer.sh
