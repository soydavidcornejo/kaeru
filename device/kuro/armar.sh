#!/usr/bin/env bash
# Arma Kuro: una app de un solo uso que pone negro el fondo de inicio y de bloqueo.
# Necesita el Android SDK con build-tools (d8, aapt2) y una plataforma android-24 o mas nueva.
set -euo pipefail
source "$(dirname "$0")/../../build/lib.sh"
cargar_programas
SDK="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
BT="$(dirname "$ZIPALIGN")"
JAR="$(ls -d "$SDK"/platforms/android-2[4-9]/android.jar "$SDK"/platforms/android-3*/android.jar 2>/dev/null | head -1 || true)"
[ -n "$JAR" ] && [ -x "$BT/d8" ] && [ -x "$BT/aapt2" ] || { echo "   Kuro: falta el Android SDK (android.jar, d8, aapt2). Se omite."; exit 0; }
K="$RAIZ/device/kuro"; T="$TRABAJO/kuro"; rm -rf "$T"; mkdir -p "$T/clases"
"$JAVAC" -nowarn -source 8 -target 8 -bootclasspath "$JAR" -d "$T/clases" "$K/src/kuro/Kuro.java" 2>&1 | grep -v 'warning' || true
"$BT/d8" --min-api 24 --lib "$JAR" --output "$T" "$T/clases/kuro/Kuro.class"
"$BT/aapt2" link -I "$JAR" --manifest "$K/AndroidManifest.xml" -o "$T/kuro-sin-dex.apk"
cp "$T/kuro-sin-dex.apk" "$T/kuro-sin-firma.apk"
(cd "$T" && zip -q -X kuro-sin-firma.apk classes.dex)
mkdir -p "$DIST"
firmar_apk testkey "$T/kuro-sin-firma.apk" "$DIST/kuro.apk"
echo "   listo: $DIST/kuro.apk"
