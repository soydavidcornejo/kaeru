#!/usr/bin/env bash
# Ajustes despues de flashear Kaeru (por ADB, sin root):
#  - desactiva apps de FiiO y de Android que no se usan (lista en desactivar.txt)
#  - apaga las animaciones
#  - pone negro el fondo de inicio y de bloqueo (con Kuro, si esta armada)
# Todo se puede deshacer con device/revertir.sh.
set -uo pipefail
AQUI="$(cd "$(dirname "$0")" && pwd)"
ADB="${ADB:-$(command -v adb || echo "$HOME/Library/Android/sdk/platform-tools/adb")}"
[ -x "$ADB" ] || { echo "No encuentro adb. Instala Android platform-tools."; exit 1; }
"$ADB" get-state >/dev/null 2>&1 || { echo "No hay equipo conectado por ADB (activa la depuracion USB y acepta el aviso)."; exit 1; }
modelo="$("$ADB" shell getprop ro.product.model </dev/null | tr -d '\r')"
case "$modelo" in *M9*) ;; *) echo "Este equipo es '$modelo', no un FiiO M9. Me detengo."; exit 1;; esac

echo "== Desactivando apps"
while read -r p; do
  case "$p" in ''|'#'*) continue;; esac
  [ "$p" = com.android.statementservice ] && continue   # nunca: provoca bootloop
  "$ADB" shell pm path "$p" </dev/null 2>/dev/null | grep -q package: || continue   # ya no esta en el sistema
  printf '   %-45s ' "$p"
  "$ADB" shell pm disable-user --user 0 "$p" </dev/null 2>&1 | tail -1 | tr -d '\r'
done < "$AQUI/desactivar.txt"

echo "== Animaciones apagadas"
for k in window_animation_scale transition_animation_scale animator_duration_scale; do
  "$ADB" shell settings put global "$k" 0 </dev/null
done

KURO="$AQUI/../dist/kuro.apk"
if [ -f "$KURO" ]; then
  echo "== Fondo negro (Kuro)"
  "$ADB" install -r "$KURO" </dev/null >/dev/null && \
  "$ADB" shell am start -W -n app.kuro/kuro.Kuro </dev/null >/dev/null && sleep 2
  "$ADB" uninstall app.kuro </dev/null >/dev/null
else
  echo "== Kuro no esta armada (dist/kuro.apk): el fondo actual se mantiene. Ver la guia."
fi
echo "Listo."
