#!/usr/bin/env bash
set -euo pipefail

mkdir -p ../metrics
echo "timestamp,user,system,idle"  > ../metrics/cpu.csv
echo "timestamp,util,await,r/s,w/s" > ../metrics/io.csv

for i in {1..12}; do          # 12 × 5 s = 1 min
  ts=$(date +%s)

  # CPU
  CPU=$(sar -u 1 1 | awk '/Average/ {print $3","$5","$8}')
  echo "$ts,$CPU" >> ../metrics/cpu.csv

  # Disco (toma el primero no loop)
  DEV=$(lsblk -ndo NAME | grep -m1 -v loop)
  IO=$(iostat -dx 1 1 $DEV | awk "NR==7 {print \$12\",\"\$10\",\"\$4\",\"\$5}")
  echo "$ts,$IO" >> ../metrics/io.csv

  sleep 4     # ya consumimos 1 s con sar/iostat
done
echo "✅ Métricas guardadas en metrics/"
