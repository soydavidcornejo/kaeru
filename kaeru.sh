#!/usr/bin/env bash
# Kaeru: firmware minimal para el FiiO M9.
#   ./kaeru.sh build      arma dist/kaeru-m9-<version>.zip a partir del firmware oficial de FiiO
#   ./kaeru.sh post       ajustes por ADB despues de flashear (apps, animaciones, fondo)
#   ./kaeru.sh spotify    instala Spotify (opcional; se descarga y se verifica, no viene con Kaeru)
#   ./kaeru.sh revertir   deshace "post"
#   ./kaeru.sh limpiar    borra la carpeta trabajo/
set -euo pipefail
AQUI="$(cd "$(dirname "$0")" && pwd)"
case "${1:-}" in
  build)
    for p in "$AQUI"/build/0[1-7]-*.sh; do bash "$p"; done
    bash "$AQUI/device/kuro/armar.sh"
    echo; echo "Paquete listo en dist/. Siguiente paso: docs/es/instalar.md (o docs/en/install.md)."
    ;;
  post)     bash "$AQUI/device/post-instalacion.sh" ;;
  spotify)  bash "$AQUI/device/spotify.sh" ;;
  revertir) bash "$AQUI/device/revertir.sh" ;;
  limpiar)  rm -rf "$AQUI/trabajo"; echo "trabajo/ borrado" ;;
  *) sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac
