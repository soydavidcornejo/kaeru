#!/usr/bin/env bash
# Instala Spotify en el M9 (opcional). Kaeru NO distribuye Spotify: este script lo descarga
# con apkeep (https://github.com/EFForg/apkeep) y verifica que el certificado sea el de Spotify antes de instalar.
# Necesita: apkeep, unzip, apksigner (Android SDK) y adb.
set -euo pipefail
source "$(dirname "$0")/../build/lib.sh"
# Huella SHA-256 del certificado oficial de Spotify (comprobada en Exodus Privacy)
SPOTIFY_CERT="6505b181933344f93893d586e399b94616183f04349cb572a9e81a3335e28ffd"
ADB="${ADB:-$(command -v adb || echo "$HOME/Library/Android/sdk/platform-tools/adb")}"
APKEEP="$(command -v apkeep || echo "$HOME/.cargo/bin/apkeep")"
[ -x "$APKEEP" ] || falla "falta apkeep: cargo install apkeep (o descargalo de su pagina)"
local_bt="${ANDROID_HOME:-$HOME/Library/Android/sdk}/build-tools/*"
APKSIGNER="$(buscar apksigner "$local_bt/apksigner")" || falla "falta apksigner"
D="$TRABAJO/spotify"; rm -rf "$D"; mkdir -p "$D"
paso "Descargando Spotify (armeabi-v7a)"
"$APKEEP" -a com.spotify.music -d apk-pure -o 'acknowledge_dangers=true,arch=armeabi-v7a' "$D"
X="$(ls "$D"/*.xapk 2>/dev/null | head -1 || true)"
if [ -n "$X" ]; then unzip -q -o "$X" -d "$D/x"; else mkdir -p "$D/x"; cp "$D"/*.apk "$D/x/"; fi
cd "$D/x"
BASE="com.spotify.music.apk"; [ -f "$BASE" ] || BASE="$(ls -S ./*.apk | head -1)"
paso "Verificando el certificado"
huella="$("$APKSIGNER" verify --print-certs "$BASE" 2>/dev/null | grep -m1 'SHA-256 digest' | awk '{print $NF}')"
[ "$huella" = "$SPOTIFY_CERT" ] || falla "el certificado no es el de Spotify ($huella). No se instala."
info "certificado correcto"
PARTES=("$BASE")
for p in config.armeabi_v7a.apk config.xhdpi.apk config.es.apk config.en.apk; do [ -f "$p" ] && PARTES+=("$p"); done
paso "Instalando (${#PARTES[@]} partes)"
"$ADB" install-multiple -r "${PARTES[@]}"
info "listo. Abre Spotify con Wi-Fi y entra con correo y contrasena (el boton de Google no funciona sin servicios de Google)."
