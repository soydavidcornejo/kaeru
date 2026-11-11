#!/usr/bin/env bash
# Paso 2: conseguir el firmware oficial y convertir system.new.dat en system.img (ext4).
set -euo pipefail
source "$(dirname "$0")/lib.sh"
cargar_programas
paso "2/7 Firmware oficial $FW_VERSION"
FW="$TRABAJO/m9-ota-$FW_VERSION.zip"
if [ -n "${KAERU_FIRMWARE:-}" ]; then
  [ "$(sha256 "$KAERU_FIRMWARE")" = "$FW_SHA256" ] || falla "KAERU_FIRMWARE no es el firmware oficial $FW_VERSION (sha256 distinto)"
  cp "$KAERU_FIRMWARE" "$FW"
else
  descargar "$FW" "$FW_URL" "$FW_SHA256"
fi
rm -rf "$TRABAJO/stock"; mkdir -p "$TRABAJO/stock"
unzip -q -o "$FW" system.new.dat system.transfer.list system.patch.dat -d "$TRABAJO/stock"
info "system.new.dat -> system.img"
rm -f "$TRABAJO/system.img"
"$PYTHON" "$HERR/sdat2img.py" "$TRABAJO/stock/system.transfer.list" "$TRABAJO/stock/system.new.dat" "$TRABAJO/system.img" >/dev/null
rm -rf "$TRABAJO/stock"
info "system.img listo ($(du -h "$TRABAJO/system.img" | cut -f1))"
