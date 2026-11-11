#!/usr/bin/env bash
# Paso 7: system.img -> system.new.dat, armar el zip OTA y firmarlo con la testkey de AOSP.
set -euo pipefail
source "$(dirname "$0")/lib.sh"
cargar_programas
paso "7/7 Paquete OTA"
info "imagen sparse"
"$PYTHON" "$RAIZ/build/raw2simg.py" "$TRABAJO/system.img" "$TRABAJO/system.sparse.img" >/dev/null
info "system.new.dat (puede tardar unos minutos)"
rm -rf "$TRABAJO/dat"; mkdir -p "$TRABAJO/dat"
# img2sdat usa el modulo "imp", que ya no existe desde Python 3.12. Se reemplaza por uno vacio (no se usa en este camino).
"$PYTHON" -c 'import sys, types, runpy
try:
    import imp
except ImportError:
    sys.modules["imp"] = types.ModuleType("imp")
sys.path.insert(0, sys.argv[1]); sys.argv = sys.argv[2:]
runpy.run_path(sys.argv[0], run_name="__main__")' "$HERR/img2sdat" "$HERR/img2sdat/img2sdat.py" \
  "$TRABAJO/system.sparse.img" -o "$TRABAJO/dat" -v 4 -p system >/dev/null
rm -f "$TRABAJO/system.sparse.img"
info "zip"
SIN="$TRABAJO/kaeru-sin-firma.zip"
cp "$TRABAJO/m9-ota-$FW_VERSION.zip" "$SIN"
# solo se quitan la firma vieja y las piezas de system; kernel, recovery y bootloader quedan iguales a los de FiiO
zip -q -d "$SIN" META-INF/CERT.RSA META-INF/CERT.SF META-INF/MANIFEST.MF META-INF/com/android/otacert >/dev/null || true
(cd "$TRABAJO/dat" && zip -q -X -0 "$SIN" system.transfer.list system.patch.dat && zip -q -X "$SIN" system.new.dat)
info "firma"
mkdir -p "$DIST"
SAL="$DIST/kaeru-m9-$KAERU_VERSION.zip"
"$JAVA" -Xmx2g -cp "$HERR/signapk:$HERR/bcprov.jar:$HERR/bcpkix.jar" com.android.signapk.SignApk -w \
  "$HERR/llaves/testkey.x509.pem" "$HERR/llaves/testkey.pk8" "$SIN" "$SAL"
rm -f "$SIN"
(cd "$DIST" && printf "%s  %s\n" "$(sha256 "$(basename "$SAL")")" "$(basename "$SAL")" > "$(basename "$SAL").sha256")
info "listo: $SAL"
info "sha256: $(cat "$SAL.sha256")"
