#!/usr/bin/env bash
# Paso 4: framework-res.apk con fondos negros (inicio y bloqueo).
set -euo pipefail
source "$(dirname "$0")/lib.sh"
cargar_programas
paso "4/7 framework-res (fondos negros)"
D="$TRABAJO/framework"; rm -rf "$D"; mkdir -p "$D"
sacar /framework/framework-res.apk framework/framework-res.apk
FONDOS=(
  res/drawable-nodpi-v4/default_lock_wallpaper.png
  res/drawable-nodpi-v4/default_wallpaper.png
  res/drawable-nodpi-v4/default_wallpaper_new.png
  res/drawable-sw600dp-nodpi-v13/default_wallpaper.png
  res/drawable-sw720dp-nodpi-v13/default_wallpaper.png
)
(cd "$D" && unzip -q -o framework-res.apk "${FONDOS[@]}")
for f in "${FONDOS[@]}"; do "$PYTHON" "$RAIZ/build/fondo_negro.py" "$D/$f"; done
cp "$D/framework-res.apk" "$D/sin-firma.apk"
(cd "$D" && { zip -q -d sin-firma.apk 'META-INF/*' >/dev/null 2>&1 || true; } && zip -q -X -0 sin-firma.apk "${FONDOS[@]}")
firmar_apk platform "$D/sin-firma.apk" "$TRABAJO/framework-res.apk"
info "listo: ${#FONDOS[@]} fondos en negro"
