# 🔮 horoscopo.sh

> **Script en Bash para consultar el horóscopo diario desde la terminal.**  
> Obtén la predicción astrológica del día, tradúcela automáticamente, guárdala en un registro local o recíbela como una notificación de escritorio.

---

## 🌟 Características

* 📡 **Consulta en tiempo real:** Utiliza la API de **API Ninjas** para obtener la predicción diaria.
* 🌐 **Traducción automática:** Traduce la predicción al español al instante (requiere `translate-shell`).
* 📁 **Guardado automático:** Crea un historial organizado por fecha en `~/horoscopos/`.
* 🔔 **Notificaciones de escritorio:** Compatible con `notify-send` para alertas integradas en tu entorno Linux.
* ⚙️ **Personalizable:** Configurado por defecto para **Piscis**, pero ampliable a cualquier signo zodiacal.

---

## 📊 Ficha Técnica

| Parámetro | Detalle |
| :--- | :--- |
| **Nombre del script** | `horoscopo.sh` |
| **Nivel** | 🟨 Medio / Avanzado |
| **Lenguaje** | 🐚 Bash |
| **API Backend** | [API Ninjas - Zodiac HTTP API](https://api-ninjas.com/) |

---

## 🛠️ Requisitos e Instalación

### Requisitos base
* **`bash`** (incluido por defecto en la mayoría de distribuciones Linux)
* **`curl`** (para realizar las peticiones HTTP a la API)

### Dependencias recomendadas
* **`jq`** — Procesador JSON para parsear la respuesta de la API de forma limpia.
* **`translate-shell`** (`trans`) — Herramienta de terminal para traducir la predicción al español.
* **`libnotify`** (`notify-send`) — Para mostrar notificaciones en el escritorio Linux.

### 📦 Instalación de dependencias (Debian / Ubuntu y derivados)

```bash
sudo apt update
sudo apt install curl jq translate-shell libnotify-bin
