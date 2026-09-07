# 🌐 Browser Selector (PyQt6)

Un selector de navegadores moderno, elegante y minimalista diseñado en **Python (PyQt6)** con una estética de gamas de azules oscuros (modificable en script). Inspirado en el comportamiento clásico de un menú GRUB, permite la selección interactiva de tu navegador predeterminado con un temporizador de arranque automático.

---

## ✨ Características Principales

- **🎨 Diseño Moderno & Elegante:** Interfaz limpia con paleta de azules oscuros inspirada en temas modernos de Linux (estilo Nord / Dark Blue).
- **⏱️ Temporizador Estilo GRUB:** Cuenta regresiva automática configurable que lanza el navegador por defecto si no hay interacción.
- **⏸️ Pausa Inteligente:** El temporizador se detiene automáticamente en cuanto mueves el ratón, haces clic o presionas cualquier tecla.
- **⚙️ Configuración Dinámica (`JSON`):** Añade, elimina o modifica navegadores y comandos fácilmente sin tocar el código fuente.
- **⌨️ Atajos de Teclado:** Soporte completo para navegación mediante teclado (`Enter` para iniciar, `Esc` para salir).
- **🚀 Ligero y Rápido:** Construido con PyQt6, ideal para entornos de escritorio ligeros y gestores de ventanas en Wayland (como Hyprland).

---

## 📂 Estructura de Archivos

```text
~/.local/bin/
├── browser_selector.py    # Script principal con la interfaz gráfica
└── browsers.json          # Archivo de configuración de navegadores
```

---

## ⚙️ Configuración (`browsers.json`)

El archivo de configuración permite definir el tiempo de espera, la opción por defecto y la lista de navegadores disponibles:

```json
{
    "timeout": 5,
    "default_index": 0,
    "browsers": [
        {
            "name": "Google Chrome",
            "command": "/usr/bin/google-chrome-stable %U"
        },
        {
            "name": "LibreWolf",
            "command": "/usr/lib/librewolf/librewolf %u"
        },
        {
            "name": "Zen Browser",
            "command": "/opt/zen-browser-bin/zen-bin %u"
        }
    ]
}
```

- **`timeout`**: Segundos de cuenta regresiva antes de iniciar el navegador por defecto.
- **`default_index`**: Posición en la lista (comenzando desde `0`) del navegador que se seleccionará por defecto.
- **`browsers`**: Lista de objetos con el nombre visible y el comando ejecutable.

---

## 🚀 Instalación y Uso

### 1. Requisitos previos
Asegúrate de tener Python 3 y la librería PyQt6 instalada en tu sistema:
```bash
# En Arch Linux / CachyOS
sudo pacman -S python-pyqt6
```

### 2. Ejecución
Coloca `browser_selector.py` y `browsers.json` en tu directorio de ejecutables (por ejemplo, `~/.local/bin/`) y ejecútalo con:
```bash
python browser_selector.py
```

También puedes asignarlo como un atajo de teclado en tu entorno de escritorio o gestor de ventanas favorito.
