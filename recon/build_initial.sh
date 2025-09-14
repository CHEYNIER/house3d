#!/usr/bin/env bash
set -e
DATA="$1"; OUT="$2"
if [ -z "$DATA" ] || [ -z "$OUT" ]; then
  echo "Usage: $0 <data_images_dir> <output_processed_dir>"; exit 1
fi
ns-process-data images --data "$DATA" --output-dir "$OUT"
ns-train splatfacto --data "$OUT"
