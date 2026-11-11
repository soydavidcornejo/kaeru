#!/usr/bin/env bash
# Paso 1: descargar y verificar herramientas, compilar el firmador SignApk.
set -euo pipefail
source "$(dirname "$0")/lib.sh"
cargar_programas
paso "1/7 Herramientas"
for linea in "${HERRAMIENTAS[@]}"; do
  IFS='|' read -r nombre url hash <<< "$linea"
  descargar "$HERR/$nombre" "$url" "$hash"
done
for linea in "${FUENTES_AOSP[@]}"; do
  IFS='|' read -r nombre url hash <<< "$linea"
  descargar "$HERR/$nombre" "$url" "$hash" aosp
done
if [ ! -f "$HERR/signapk/com/android/signapk/SignApk.class" ]; then
  info "compilando SignApk (AOSP lollipop, BouncyCastle 1.50)"
  mkdir -p "$HERR/signapk"
  "$JAVAC" -nowarn -encoding UTF-8 -cp "$HERR/bcprov.jar:$HERR/bcpkix.jar" -d "$HERR/signapk" "$HERR/SignApk.java" 2>&1 | grep -v '^Note:' || true
  [ -f "$HERR/signapk/com/android/signapk/SignApk.class" ] || falla "no se pudo compilar SignApk"
fi
info "listo"
