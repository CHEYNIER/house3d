#!/usr/bin/env bash
set -e
OUT="$1"; CKPT="$2"
if [ -z "$OUT" ] || [ -z "$CKPT" ]; then
  echo "Usage: $0 <processed_dir> <checkpoint_dir>"; exit 1
fi
ns-train splatfacto --data "$OUT" --load-dir "$CKPT"
