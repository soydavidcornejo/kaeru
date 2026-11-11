#!/usr/bin/env bash
# Busca datos privados en los archivos del repo: correos, rutas personales
# y los terminos de .terminos-privados (archivo local, nunca versionado; un termino por linea).
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
ARCHIVOS="$(git ls-files 2>/dev/null || find . -type f -not -path './.git/*' -not -path './trabajo/*' -not -path './dist/*')"
[ -z "$ARCHIVOS" ] && ARCHIVOS="$(find . -type f -not -path './.git/*' -not -path './trabajo/*' -not -path './dist/*')"
HALLAZGOS=0
revisar() { # revisar <descripcion> <regex>
  local r
  # shellcheck disable=SC2086
  r="$(echo "$ARCHIVOS" | grep -v -E '\.(png|zip|jpg)$|revisar_privacidad\.sh' | xargs grep -n -I -i -E "$2" 2>/dev/null || true)"
  if [ -n "$r" ]; then echo "== $1"; echo "$r"; HALLAZGOS=1; fi
}
revisar "correos" '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[a-z]{2,}' 
revisar "rutas personales" '/Users/[a-z]|/home/[a-z]+/'
if [ -f .terminos-privados ]; then
  while read -r t; do [ -n "$t" ] && revisar "termino privado" "$t"; done < .terminos-privados
fi
[ "$HALLAZGOS" -eq 0 ] && echo "privacidad: ok"
exit "$HALLAZGOS"
