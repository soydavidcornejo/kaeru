#!/usr/bin/env bash
# Deshace post-instalacion.sh: reactiva las apps y vuelve a encender las animaciones.
# (Para volver por completo al sistema de FiiO, flashea el firmware oficial: ver la guia.)
set -uo pipefail
AQUI="$(cd "$(dirname "$0")" && pwd)"
ADB="${ADB:-$(command -v adb || echo "$HOME/Library/Android/sdk/platform-tools/adb")}"
while read -r p; do
  case "$p" in ''|'#'*) continue;; esac
  "$ADB" shell pm path "$p" </dev/null 2>/dev/null | grep -q package: || continue
  printf '   %-45s ' "$p"; "$ADB" shell pm enable "$p" </dev/null 2>&1 | tail -1 | tr -d '\r'
done < "$AQUI/desactivar.txt"
for k in window_animation_scale transition_animation_scale animator_duration_scale; do
  "$ADB" shell settings put global "$k" 1 </dev/null
done
echo "Listo."
