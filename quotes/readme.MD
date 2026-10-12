# 💡 notify-quotes.sh

Un script en **Bash** ligero y eficiente que envía notificaciones de escritorio con frases motivacionales aleatorias desde un archivo `.txt` personalizable. 🚀

## ✨ Características

* 🎲 **Citas Aleatorias:** Selecciona frases e identifica automáticamente a los autores.
* 🔔 **Notificaciones de Escritorio:** Integración directa usando `notify-send`.
* ⚙️ **Optimizado para Systemd:** Diseñado para ejecutarse fácilmente como servicio de usuario (`systemd --user`).
* 📜 **Formato Inteligente:** Divide textos largos para garantizar una lectura cómoda en pantalla.

## 🚀 Uso Rápido

1. Clona el repositorio e otorga permisos de ejecución:
   ```bash
   chmod +x notify-quotes.sh
   ```
2. Asegúrate de definir la ruta correcta de tu archivo de frases (`quotes.txt`) dentro del script.
3. Ejecuta el script manualmente o agrégalo a tu **crontab** o **timer de systemd** para recibir motivación diaria. 🎯

---
¡Dale un empujón de energía a tu flujo de trabajo diario! 💻✨
