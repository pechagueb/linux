#######################################################
#   ____  _____ ____  
#  |  _ \| ____| __ )  Autor: 
#  | |_) |  _| |  _ \  Patricio Echagüe Ballesteros
#  |  __/| |___| |_) | Descripción:
#  |_|   |_____|____/  Script de selección de navegador a ejecutar
#
########################################################

import sys
import json
import os
import subprocess
from PyQt6.QtWidgets import (
    QApplication, QWidget, QVBoxLayout, QLabel, 
    QPushButton, QListWidget, QListWidgetItem
)
from PyQt6.QtCore import QTimer, Qt
from PyQt6.QtGui import QFont

CONFIG_FILE = os.path.expanduser("~/.config/browser_selector/browsers.json")

# Crear configuración por defecto si no existe (verificar ejecutables)
def load_config():
    default_data = {
        "timeout": 5,
        "default_index": 0,
        "browsers": [
            {"name": "Google Chrome", "command": "/usr/bin/google-chrome-stable %U"},
            {"name": "LibreWolf", "command": "/usr/lib/librewolf/librewolf %u"},
            {"name": "Zen Browser", "command": "/opt/zen-browser-bin/zen-bin %u"}
        ]
    }
    
    # Intentar buscar en directorio local o crear
    path = "browsers.json"
    if not os.path.exists(path):
        os.makedirs(os.path.dirname(path), exist_ok=True) if os.path.dirname(path) else None
        with open(path, "w") as f:
            json.dump(default_data, f, indent=4)
        return default_data
    
    try:
        with open(path, "r") as f:
            return json.load(f)
    except Exception:
        return default_data

class BrowserSelector(QWidget):
    def __init__(self):
        super().__init__()
        self.config = load_config()
        self.timeout = self.config.get("timeout", 5)
        self.default_index = self.config.get("default_index", 0)
        self.browsers = self.config.get("browsers", [])
        
        self.init_ui()
        self.init_timer()

    def init_ui(self):
        self.setWindowTitle("Seleccionar Navegador")
        self.setFixedSize(400, 380)
        self.setWindowFlags(Qt.WindowType.FramelessWindowHint | Qt.WindowType.WindowStaysOnTopHint)
        
        # Tema de gamas de azules oscuros (estilo moderno/Nord/Dark Blue)
        self.setStyleSheet("""
            QWidget {
                background-color: #0f172a;
                color: #e2e8f0;
                font-family: 'Segoe UI', Sans-Serif;
                font-size: 14px;
            }
            QLabel {
                color: #93c5fd;
            }
            QListWidget {
                background-color: #1e293b;
                border: 1px solid #334155;
                border-radius: 8px;
                padding: 5px;
            }
            QListWidget::item {
                background-color: #1e293b;
                color: #f8fafc;
                padding: 12px;
                margin-bottom: 4px;
                border-radius: 6px;
            }
            QListWidget::item:selected {
                background-color: #2563eb;
                color: #ffffff;
            }
            QListWidget::item:hover {
                background-color: #334155;
            }
            QPushButton {
                background-color: #1d4ed8;
                color: #ffffff;
                border: none;
                border-radius: 6px;
                padding: 10px;
                font-weight: bold;
            }
            QPushButton:hover {
                background-color: #2563eb;
            }
            QPushButton:pressed {
                background-color: #1e40af;
            }
        """)

        layout = QVBoxLayout()
        layout.setContentsMargins(20, 20, 20, 20)
        layout.setSpacing(15)

        # Título y Contador
        self.title_label = QLabel("¿Qué navegador deseas iniciar?")
        self.title_label.setFont(QFont("Segoe UI", 12, QFont.Weight.Bold))
        layout.addWidget(self.title_label)

        self.timer_label = QLabel(f"Iniciando opción por defecto en {self.timeout}s...")
        self.timer_label.setFont(QFont("Segoe UI", 9))
        layout.addWidget(self.timer_label)

        # Lista de navegadores
        self.list_widget = QListWidget()
        for b in self.browsers:
            item = QListWidgetItem(b["name"])
            self.list_widget.addItem(item)
        
        # Seleccionar el por defecto
        if 0 <= self.default_index < len(self.browsers):
            self.list_widget.setCurrentRow(self.default_index)
            
        self.list_widget.itemDoubleClicked.connect(self.launch_selected)
        layout.addWidget(self.list_widget)

        # Botón de ejecución manual
        self.btn_launch = QPushButton("Iniciar Navegador")
        self.btn_launch.clicked.connect(self.launch_selected)
        layout.addWidget(self.btn_launch)

        self.setLayout(layout)

        # Centrar en pantalla
        self.center_window()

    def center_window(self):
        screen = QApplication.primaryScreen().geometry()
        size = self.geometry()
        self.move((screen.width() - size.width()) // 2, (screen.height() - size.height()) // 2)

    def init_timer(self):
        self.timer = QTimer()
        self.timer.timeout.connect(self.update_countdown)
        self.timer.start(1000)

    def update_countdown(self):
        self.timeout -= 1
        if self.timeout > 0:
            self.timer_label.setText(f"Iniciando opción por defecto en {self.timeout}s...")
        else:
            self.timer.stop()
            self.launch_default()

    def mousePressEvent(self, event):
        # Pausar el temporizador si el usuario hace clic o interactúa
        self.pause_timer()
        super().mousePressEvent(event)

    def keyPressEvent(self, event):
        self.pause_timer()
        if event.key() in (Qt.Key.Key_Return, Qt.Key.Key_Enter):
            self.launch_selected()
        elif event.key() == Qt.Key.Key_Escape:
            sys.exit(0)
        else:
            super().keyPressEvent(event)

    def pause_timer(self):
        if self.timer.isActive():
            self.timer.stop()
            self.timer_label.setText("Temporizador pausado (Interacción detectada)")

    def launch_default(self):
        index = self.default_index if 0 <= self.default_index < len(self.browsers) else 0
        self.execute_browser(index)

    def launch_selected(self):
        self.timer.stop()
        row = self.list_widget.currentRow()
        index = row if row >= 0 else self.default_index
        self.execute_browser(index)

    def execute_browser(self, index):
        browser_data = self.browsers[index]
        cmd = browser_data["command"]
        
        # Reemplazar comodines genéricos si los hay o limpiar variables estilo %u / %U para bash
        # Ejecutamos de forma desacoplada con subprocess
        try:
            # Dividir el comando de manera segura respetando argumentos
            # Limpiamos los especificadores de escritorio (%u, %U) para la ejecución directa
            clean_cmd = cmd.replace("%u", "").replace("%U", "").strip()
            subprocess.Popen(clean_cmd, shell=True)
        except Exception as e:
            print(f"Error al iniciar el navegador: {e}")
        
        sys.exit(0)

if __name__ == "__main__":
    app = QApplication(sys.argv)
    selector = BrowserSelector()
    selector.show()
    sys.exit(app.exec())