# ⚡ ZenFlash

**ZenFlash** es un creador minimalista de discos USB booteables para Linux con una interfaz gráfica moderna de estilo oscuro (`Adwaita:dark`) impulsada por **Zenity**, optimizada bajo el capó con la potencia y velocidad bruta del comando `dd`.

Diseñado para ser rápido, seguro y libre de complicaciones, cuenta con un filtro inteligente para detectar únicamente unidades extraíbles y evitar accidentes con tus discos del sistema.

---

## 🚀 Requisitos y Dependencias

Antes de ejecutar la herramienta, asegúrate de tener instaladas las siguientes dependencias esenciales en tu sistema:

* `zenity` (Interfaz gráfica)
* `lsblk` (Detección de bloques y dispositivos)
* `dd` (Motor de escritura de bajo nivel)
* `pkexec` (Elevación segura de privilegios para el proceso de escritura)
* `pv` *(Opcional)*: Muy recomendado para visualizar una barra de progreso con porcentaje real de escritura.

---

## 📦 Descarga e Instalación

1. **Clona o descarga** el repositorio en tu directorio local de scripts (por ejemplo, `~/.local/bin/`):
   ```bash
   git clone https://github.com/tu-usuario/zenflash.git
   cd zenflash
   ```

2. **Dale permisos de ejecución** al script principal:
   ```bash
   chmod +x zenflash.sh
   ```

---

## 💻 Ejecución

Ejecuta el script directamente desde tu terminal o entorno gráfico:

```bash
./zenflash.sh
```

> ⚠️ **Precaución:** El script solicitará permisos de administrador (`pkexec`) exclusivamente en el momento de realizar la escritura para interactuar con la unidad de bloques. Asegúrate de seleccionar el pendrive correcto, ya que **todos los datos anteriores en el destino se eliminarán permanentemente**.
