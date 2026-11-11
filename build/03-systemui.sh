#!/usr/bin/env bash
# Paso 3: SystemUI con filtro de rebote para la rueda de volumen.
# La app viene "odexada": el codigo esta en SystemUI.odex. Se pasa a smali, se parcha y se arma un classes.dex nuevo.
set -euo pipefail
source "$(dirname "$0")/lib.sh"
cargar_programas
paso "3/7 SystemUI (rueda de volumen)"
D="$TRABAJO/systemui"; rm -rf "$D"; mkdir -p "$D"
sacar /priv-app/SystemUI/SystemUI.apk systemui/SystemUI.apk
sacar /priv-app/SystemUI/oat/arm/SystemUI.odex systemui/SystemUI.odex
# boot.oat y compania: baksmali los necesita para resolver las clases del sistema
(cd "$TRABAJO" && "$DEBUGFS" -R "rdump /framework/arm systemui" system.img) >/dev/null 2>&1
[ -f "$D/arm/boot.oat" ] || falla "no se encontro /framework/arm/boot.oat"
info "deodex"
"$JAVA" -jar "$HERR/baksmali.jar" deodex "$D/SystemUI.odex" -d "$D/arm" -o "$D/smali"
"$PYTHON" "$RAIZ/build/parchar_systemui.py" "$D/smali/com/android/systemui/fiio/volume/VolumeControlActivityForM9.smali" "$DBNC_MISMA_MS" "$DBNC_REVERSA_MS"
info "armando classes.dex"
"$JAVA" -jar "$HERR/smali.jar" assemble --api 24 "$D/smali" -o "$D/classes.dex"
cp "$D/SystemUI.apk" "$D/sin-firma.apk"
(cd "$D" && { zip -q -d sin-firma.apk 'META-INF/*' >/dev/null 2>&1 || true; } && zip -q -X sin-firma.apk classes.dex)
firmar_apk platform "$D/sin-firma.apk" "$TRABAJO/SystemUI.apk"
info "listo: SystemUI.apk firmado con la llave platform"
