# Funciones comunes. Se carga con: source build/lib.sh
# shellcheck shell=bash

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TRABAJO="${KAERU_TRABAJO:-$RAIZ/trabajo}"
HERR="$TRABAJO/herramientas"
DIST="$RAIZ/dist"; export DIST
export DEBUGFS_PAGER=__none__   # que debugfs no abra un paginador
# shellcheck source=build/config.sh
source "$RAIZ/build/config.sh"

paso() { printf '\n\033[1m== %s\033[0m\n' "$*"; }
info() { printf '   %s\n' "$*"; }
falla() { printf '\033[31mERROR: %s\033[0m\n' "$*" >&2; exit 1; }

sha256() {
  if command -v sha256sum >/dev/null; then sha256sum "$1" | cut -d' ' -f1
  else shasum -a 256 "$1" | cut -d' ' -f1; fi
}

# descargar <destino> <url> <sha256> [aosp]
descargar() {
  local destino="$1" url="$2" esperado="$3" modo="${4:-}"
  if [ -f "$destino" ] && [ "$(sha256 "$destino")" = "$esperado" ]; then return 0; fi
  mkdir -p "$(dirname "$destino")"
  info "descargando $(basename "$destino")"
  if [ "$modo" = aosp ]; then
    curl -fsSL "$url" | base64 --decode > "$destino.tmp" || falla "no se pudo descargar $url"
  else
    curl -fsSL -o "$destino.tmp" "$url" || falla "no se pudo descargar $url"
  fi
  local real; real="$(sha256 "$destino.tmp")"
  [ "$real" = "$esperado" ] || { rm -f "$destino.tmp"; falla "sha256 no coincide en $(basename "$destino") (esperado $esperado, real $real)"; }
  mv "$destino.tmp" "$destino"
}

# Busca un programa en el PATH o en rutas conocidas (Homebrew, Android SDK).
buscar() {
  local nombre="$1"; shift
  if command -v "$nombre" >/dev/null 2>&1; then command -v "$nombre"; return 0; fi
  local p
  for p in "$@"; do
    # shellcheck disable=SC2086
    for f in $p; do [ -x "$f" ] && { echo "$f"; return 0; }; done
  done
  return 1
}

cargar_programas() {
  DEBUGFS="$(buscar debugfs /opt/homebrew/opt/e2fsprogs/sbin/debugfs /usr/local/opt/e2fsprogs/sbin/debugfs /sbin/debugfs /usr/sbin/debugfs)" || falla "falta debugfs (macOS: brew install e2fsprogs; Linux: apt install e2fsprogs)"
  E2FSCK="$(buscar e2fsck /opt/homebrew/opt/e2fsprogs/sbin/e2fsck /usr/local/opt/e2fsprogs/sbin/e2fsck /sbin/e2fsck /usr/sbin/e2fsck)" || falla "falta e2fsck"
  local bt="${ANDROID_HOME:-$HOME/Library/Android/sdk}/build-tools/*"
  ZIPALIGN="$(buscar zipalign "$bt/zipalign" "$HOME/Android/Sdk/build-tools/*/zipalign")" || falla "falta zipalign (Android SDK build-tools)"
  APKSIGNER="$(buscar apksigner "$bt/apksigner" "$HOME/Android/Sdk/build-tools/*/apksigner")" || falla "falta apksigner (Android SDK build-tools)"
  PYTHON="$(buscar python3)" || falla "falta python3"
  JAVA="$(buscar java)" || falla "falta java (11 o mas nuevo)"
  JAVAC="$(buscar javac)" || falla "falta javac (JDK 11 o mas nuevo)"
  command -v zip >/dev/null && command -v unzip >/dev/null || falla "faltan zip y unzip"
  export DEBUGFS E2FSCK ZIPALIGN APKSIGNER PYTHON JAVA JAVAC
}

# Ejecuta un archivo de comandos de debugfs contra system.img (rutas relativas a $TRABAJO).
debugfs_cmds() {
  (cd "$TRABAJO" && "$DEBUGFS" -w -f "$1" system.img) 2>&1 | grep -vE '^debugfs [0-9]|^$|already exists' || true
}

# Saca un archivo de system.img: sacar </ruta/en/system> <destino>
sacar() {
  (cd "$TRABAJO" && "$DEBUGFS" -R "dump -p $1 $2" system.img) >/dev/null 2>&1
  [ -s "$TRABAJO/$2" ] || falla "no se pudo sacar $1 de system.img"
}

firmar_apk() { # firmar_apk <llave: platform|testkey> <entrada> <salida>
  local llave="$1" ent="$2" sal="$3"
  "$ZIPALIGN" -f -p 4 "$ent" "$sal.al"
  "$APKSIGNER" sign --key "$HERR/llaves/$llave.pk8" --cert "$HERR/llaves/$llave.x509.pem" \
    --min-sdk-version 24 --out "$sal" "$sal.al"
  rm -f "$sal.al" "$sal.idsig"
}
