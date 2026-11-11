#!/usr/bin/env bash
# Paso 5: Olauncher (F-Droid) con los colores del kamon: texto crema y acento rojo.
set -euo pipefail
source "$(dirname "$0")/lib.sh"
cargar_programas
paso "5/7 Olauncher"
D="$TRABAJO/olauncher"; rm -rf "$D"; mkdir -p "$D"
"$JAVA" -jar "$HERR/apktool.jar" d -q -f -o "$D/src" "$HERR/olauncher.apk" -p "$D/fw"
"$PYTHON" "$RAIZ/build/colores_olauncher.py" "$D/src" "$COLOR_CREMA" "$COLOR_ROJO"
"$JAVA" -jar "$HERR/apktool.jar" b -q -o "$D/sin-firma.apk" "$D/src" -p "$D/fw"
firmar_apk testkey "$D/sin-firma.apk" "$TRABAJO/Olauncher.apk"
info "listo"
