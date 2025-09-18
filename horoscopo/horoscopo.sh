#!/usr/bin/env bash

# Nombre: horoscopo.sh
# Autor: Patricio Echagüe Ballesteros (YAPA Design)
# WEB: https://pechagueb.odoo.com/
# Nivel: medio/avanzado
# 
# Descripción:
# Consulta el horóscopo diario usando API Ninjas.
#
# Uso: ./horoscopo.sh
#
# Requisitos:
# - curl
# - jq (recomendado, para parsear JSON)
# - translate-shell (para traducción)
#
# Configura tu API Key antes de usar (https://api-ninjas.com/)

set -euo pipefail #aborta en caso de error

API_KEY="TU_CLAVE_API"   # <--- Cambia esto por tu clave real de API Ninjas (https://api-ninjas.com/)
SIGN="pisces" # Indicar signo zodiacal en inglés (ejemplo: pisces)
ENDPOINT="https://api.api-ninjas.com/v1/horoscope"
OUT_DIR="${HOME}/horoscopos"
OUT_FILE="${OUT_DIR}/pisces_ninjas_$(date +%F).txt"
TMP_JSON="$(mktemp)"

mkdir -p "${OUT_DIR}"

# Llamada a API Ninjas
http_code=$(curl -s -w "%{http_code}" -H "X-Api-Key: ${API_KEY}" "${ENDPOINT}?zodiac=${SIGN}" -o "${TMP_JSON}" )

if [ "${http_code}" != "200" ]; then
  echo "Error: API Ninjas devolvió código HTTP ${http_code}." >&2
  cat "${TMP_JSON}" >&2
  rm -f "${TMP_JSON}"
  exit 1
fi

# Parseo con jq
if command -v jq >/dev/null 2>&1; then
  date_resp=$(jq -r '.date' "${TMP_JSON}")
  horoscope=$(jq -r '.horoscope' "${TMP_JSON}")
  zodiac_resp=$(jq -r '.zodiac' "${TMP_JSON}")
else
  # fallback simple si no tienes jq
  date_resp=$(grep -oP '"date"\s*:\s*"\K([^"]*)' "${TMP_JSON}" || echo "N/A")
  horoscope=$(grep -oP '"horoscope"\s*:\s*"\K([^"]*)' "${TMP_JSON}" | sed 's/\\n/ /g' || echo "Descripción no disponible")
  zodiac_resp=$(grep -oP '"zodiac"\s*:\s*"\K([^"]*)' "${TMP_JSON}" || echo "N/A")
fi

rm -f "${TMP_JSON}"

# Traduce al español (es)
if command -v trans >/dev/null 2>&1; then
  horoscope_es=$(echo "$horoscope" | trans -b :es)
else
  horoscope_es="(No se pudo traducir automáticamente, instala 'translate-shell')"
fi


# Guarda en ~/horoscopos/ (opcional)
: '
timestamp="$(date '+%F %T %Z')"
cat > "${OUT_FILE}" <<EOF
Horóscopo para PISCIS — Diario (${timestamp})
---------------------------------------------------------
Fecha (API): ${date_resp}
Signo: ${zodiac_resp}

Horóscopo:
${horoscope_es}

---------------------------------------------------------
(Fuente: API Ninjas)
EOF

echo "Guardado en: ${OUT_FILE}"
echo
sed -n '1,200p' "${OUT_FILE}"
'

# Muestra como notificacion (opcional)
: '
if command -v notify-send >/dev/null 2>&1; then
  notify-send "Horóscopo Piscis" "$(echo "${horoscope_es}" | cut -c1-200)" -i face-smile || true
fi
'

# Muestra en terminal (por defecto)
echo
echo "Horoscopo PISCIS $(date)"
echo 
echo ${horoscope_es}
echo

exit 0

