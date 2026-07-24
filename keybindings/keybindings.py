#!/usr/bin/env python3

########################################################
# Script de Generación de Keybindings Cheat Sheet 
# Autor: Patricio Echagüe Ballesteros
# Genera un PDF con los atajos de teclado en tiempo real
# y visualización con okular.
# (basado en ChachyOS+Hyprland+Noctalia)
# 
# Nota: El script está pensado para ser ejecutado desde
# un atajo del sistema por lo que las notificaciones de
# resultados y errores no se muestran bajo ese contexto.
# se recomienda descomentar línea 156 para ejecutar una 
# prueba.
########################################################

import os
import re
import html
import subprocess

LUA_PATH = os.path.expanduser("~/.config/hypr/config/binds.lua")

def parse_lua_binds():
    if not os.path.exists(LUA_PATH):
        print(f"❌ No se encontró el archivo: {LUA_PATH}")
        return ""

    with open(LUA_PATH, "r", encoding="utf-8") as f:
        lines = f.readlines()

    vars_map = {
        "mainMod": "SUPER",
        "noctCall": "noctalia msg ",
        "launchPrefix": "uwsm app -- ",
        "TERMINAL": "TERMINAL",
        "FILE_MANAGER": "FILE-MANAGER",
        "EDITOR": "EDITOR",
        "CALCULATOR": "CALCULATOR",
        "BROWSER": "BROWSER",
        "MONITOR1": "Monitor 1",
        "MONITOR2": "Monitor 2",
        "MONITOR3": "Monitor 3",
        "NUM_WPM": "9"
    }

    rows_html = ""
    current_comment = ""

    for line in lines:
        raw_line = line.strip()

        # Capturar variables simples
        var_def = re.match(r'^local\s+(\w+)\s*=\s*["\'](.*?)["\']', raw_line)
        if var_def:
            vars_map[var_def.group(1)] = var_def.group(2)
            continue

        # Detectar comentarios / títulos
        if raw_line.startswith("--"):
            clean_comment = raw_line.lstrip("-").strip()
            if clean_comment and not clean_comment.startswith("-"):
                current_comment = clean_comment
            continue

        # Capturar hl.bind(...)
        bind_match = re.search(r'hl\.bind\((.*?),(.*?\))', raw_line)
        if bind_match:
            combo_expr = bind_match.group(1).strip()
            action_expr = bind_match.group(2).strip()

            combo_str = combo_expr
            for var_name, var_val in vars_map.items():
                combo_str = re.sub(r'\b' + var_name + r'\b', var_val, combo_str)
            
            combo_clean = combo_str.replace("..", "").replace('"', '').replace("'", "").strip()
            combo_clean = re.sub(r'\s+', ' ', combo_clean)

            action_clean = action_expr
            for var_name, var_val in vars_map.items():
                action_clean = re.sub(r'\b' + var_name + r'\b', var_val, action_clean)
            
            action_clean = action_clean.replace("hl.dsp.exec_cmd(", "exec: ")
            action_clean = action_clean.replace("hl.dsp.window.", "window.")
            action_clean = action_clean.replace("hl.dsp.", "")
            action_clean = action_clean.replace('"', '').replace("'", "").replace("..", "")
            action_clean = re.sub(r'\s+', ' ', action_clean)

            combo_html = html.escape(combo_clean)
            desc_html = html.escape(current_comment) if current_comment else "Acción de sistema"
            action_html = html.escape(action_clean)

            rows_html += f"""
            <tr>
              <td><span class="mod">{combo_html}</span></td>
              <td><span class="disp">{desc_html}</span></td>
              <td><span class="arg">{action_html}</span></td>
            </tr>
            """
            current_comment = ""

    return rows_html

def generate_pdf():
    rows = parse_lua_binds()
    if not rows:
        print("⚠️ No se pudieron procesar los keybindings desde binds.lua.")
        return

    # Formato apaisado (landscape) con márgenes optimizados
    html_content = f"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<style>
  @page {{ size: A4 landscape; margin: 10mm 12mm; background-color: #1e1e2e; }}
  body {{ font-family: 'Courier New', monospace; background-color: #1e1e2e; color: #cdd6f4; font-size: 8.5pt; }}
  .header {{ border-bottom: 2px solid #89b4fa; padding-bottom: 6px; margin-bottom: 12px; }}
  .header h1 {{ color: #89b4fa; font-size: 15pt; margin: 0; text-transform: uppercase; }}
  .header p {{ color: #a6adc8; font-size: 8pt; margin: 2px 0 0 0; }}
  table {{ width: 100%; border-collapse: collapse; table-layout: fixed; }}
  th {{ background-color: #313244; color: #cba6f7; text-align: left; padding: 6px; font-size: 8pt; text-transform: uppercase; }}
  td {{ padding: 4px 6px; border-bottom: 1px solid #313244; font-size: 8pt; word-wrap: break-word; }}
  tr:nth-child(even) {{ background-color: #181825; }}
  .mod {{ color: #f38ba8; font-weight: bold; }}
  .disp {{ color: #89b4fa; }}
  .arg {{ color: #a6e3a1; }}
</style>
</head>
<body>
  <div class="header">
    <h1>Noctalia Keybindings Cheat Sheet</h1>
    <p>Extraído directamente desde ~/.config/hypr/config/binds.lua</p>
  </div>
  <table>
    <thead>
      <tr>
        <th style="width: 28%;">Combinación</th>
        <th style="width: 25%;">Descripción / Categoría</th>
        <th style="width: 47%;">Función / Comando Ejecutado</th>
      </tr>
    </thead>
    <tbody>
      {rows}
    </tbody>
  </table>
</body>
</html>
"""
    
    with open("/tmp/hypr_keys.html", "w", encoding="utf-8") as f:
        f.write(html_content)
        
    pdf_path = os.path.expanduser("~/hyprland_keybindings.pdf")
    subprocess.run(["weasyprint", "/tmp/hypr_keys.html", pdf_path])
    # print(f"✅ PDF generado con éxito en: {pdf_path}")

    # Abrir directamente en Okular sin bloquear la terminal
    subprocess.Popen(["okular", pdf_path])

if __name__ == "__main__":
    generate_pdf()
