#!/usr/bin/env bash
set -euo pipefail

# --------------------------------------------
# rotate.sh  – Rotación y compresión de logs
# Juan Manuel Bengolea – Día 1 del sprint
# --------------------------------------------

# Valores por defecto
LOG_FILE="app.log"   # archivo a vigilar
MAX_MB=5             # umbral de rotación en MB
KEEP=5               # cuántos históricos .gz conservar

usage() {
  echo "Uso: $0 [-f archivo_log] [-s max_mb] [-k keep]"
  exit 1
}

# Parseo de flags
while getopts "f:s:k:h" opt; do
  case "$opt" in
    f) LOG_FILE="$OPTARG" ;;
    s) MAX_MB="$OPTARG" ;;
    k) KEEP="$OPTARG" ;;
    h|*) usage ;;
  esac
done

# Validaciones
[[ -f "$LOG_FILE" ]] || { echo "❌ Log no encontrado: $LOG_FILE"; exit 1; }

BYTES=$(stat --printf="%s" "$LOG_FILE")
LIMIT=$(( MAX_MB * 1024 * 1024 ))

# ¿Hace falta rotar?
if (( BYTES < LIMIT )); then
  echo "ℹ️  $LOG_FILE pesa menos de ${MAX_MB} MB. Sin rotación."
  exit 0
fi

echo "⚠️  Rotando $LOG_FILE (size: $((BYTES/1024/1024)) MB > ${MAX_MB} MB)"

# Desplaza históricos existentes: .5.gz ← .4.gz ← … ← .1.gz
for (( i=KEEP; i>=1; i-- )); do
  if [[ -f "${LOG_FILE}.${i}.gz" ]]; then
    j=$(( i + 1 ))
    [[ $j -le $KEEP ]] && mv "${LOG_FILE}.${i}.gz" "${LOG_FILE}.${j}.gz"
  fi
done

# Renombra log actual a .1, comprime y crea uno nuevo
mv "$LOG_FILE" "${LOG_FILE}.1"
gzip -9 "${LOG_FILE}.1"
touch "$LOG_FILE"

echo "✅ Rotación completada. Históricos conservados: $KEEP"
exit 0
chmod +x scripts/rotate.sh
