#!/usr/bin/env bash
# Pruebas de Kaeru. Uso: bash pruebas/correr.sh
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
FALLAS=0
ok()   { printf '  \033[32mok\033[0m  %s\n' "$*"; }
mal()  { printf '  \033[31mFALLA\033[0m %s\n' "$*"; FALLAS=$((FALLAS + 1)); }
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT

echo "Sintaxis"
for f in kaeru.sh build/*.sh device/*.sh device/kuro/*.sh pruebas/*.sh herramientas/*.sh; do
  bash -n "$f" && ok "$f" || mal "bash -n $f"
done
for f in build/*.py assets/kamon/*.py; do
  python3 -m py_compile "$f" 2>/dev/null && ok "$f" || mal "python $f"
done
if command -v shellcheck >/dev/null; then
  shellcheck -S warning -x kaeru.sh build/*.sh device/*.sh device/kuro/*.sh pruebas/*.sh herramientas/*.sh && ok shellcheck || mal shellcheck
fi

echo "Parche de la rueda"
cp pruebas/datos/VolumeControlActivityForM9.smali "$T/v.smali"
python3 build/parchar_systemui.py "$T/v.smali" 140 300 >/dev/null || mal "el parche no se aplica"
grep -q '^\.field private static mLastStepTime:J' "$T/v.smali" && grep -q '^\.field private static mLastDir:I' "$T/v.smali" && ok "campos nuevos" || mal "faltan campos"
awk '/^\.method public onKeyDown/{m=1} m&&/\.registers/{print $2; exit}' "$T/v.smali" | grep -qx 11 && ok "registros = 11" || mal "registros"
grep -q 'const/16 v4, 0x8c' "$T/v.smali" && grep -q 'const/16 v4, 0x12c' "$T/v.smali" && ok "140 y 300 ms" || mal "valores por defecto"
grep -q '"persist.kaeru.dbnc_same"' "$T/v.smali" && grep -q '"persist.kaeru.dbnc_rev"' "$T/v.smali" && ok "propiedades" || mal "propiedades"
# el bloque va justo despues de .prologue de onKeyDown, antes del codigo original
awk '/^\.method public onKeyDown/{m=1} m&&/\.prologue/{getline; print; exit}' "$T/v.smali" | grep -q 'getRepeatCount' && ok "posicion del bloque" || mal "posicion del bloque"
python3 build/parchar_systemui.py "$T/v.smali" >/dev/null 2>&1 && mal "parchar dos veces deberia fallar" || ok "no parcha dos veces"
if [ -n "${KAERU_SMALI:-}" ] && [ -f "$KAERU_SMALI" ]; then
  java -jar "$KAERU_SMALI" assemble --api 24 "$T" -o "$T/classes.dex" && ok "smali arma el dex" || mal "smali no arma el dex"
fi

echo "Fondo negro"
python3 - "$T" <<'PY' && ok "PNG negro del mismo tamano" || mal "fondo_negro.py"
import sys, struct, zlib, subprocess
t = sys.argv[1]
sys.path.insert(0, 'build')
import fondo_negro as F
open(t + '/a.png', 'wb').write(F.png_negro(480, 800).replace(b'\x00\x00\x00', b'\x00\x00\x00'))
subprocess.check_call([sys.executable, 'build/fondo_negro.py', t + '/a.png'])
d = open(t + '/a.png', 'rb').read()
assert F.tamano(t + '/a.png') == (480, 800)
i = d.index(b'IDAT'); n = struct.unpack('>I', d[i - 4:i])[0]
raw = zlib.decompress(d[i + 4:i + 4 + n])
assert len(raw) == 800 * (1 + 480 * 3) and set(raw) == {0}
PY

echo "Colores de Olauncher"
mkdir -p "$T/ola/res/values" "$T/ola/res/values-night"
printf '<resources>\n<color name="white">#ffffff</color>\n<color name="whiteTrans50">#80ffffff</color>\n</resources>\n' > "$T/ola/res/values/colors.xml"
printf '<resources><style name="AppTheme"><item name="colorAccent">#ff000000</item></style></resources>\n' > "$T/ola/res/values-night/styles.xml"
python3 build/colores_olauncher.py "$T/ola" e8e0cc b22824 >/dev/null
grep -q '#ffe8e0cc' "$T/ola/res/values/colors.xml" && grep -q '#80e8e0cc' "$T/ola/res/values/colors.xml" && grep -q '#ffb22824' "$T/ola/res/values-night/styles.xml" && ok "crema y rojo" || mal "colores"

echo "Listas"
grep -q 'StatementService' <(grep -v '^#' build/eliminar.txt) && mal "eliminar.txt no puede quitar StatementService" || ok "StatementService se mantiene"
grep -qx 'com.android.statementservice' device/desactivar.txt && mal "desactivar.txt no puede tener statementservice" || ok "statementservice no se desactiva"
grep -qx 'com.android.fiioupdate' device/desactivar.txt && mal "desactivar.txt no puede tener fiioupdate" || ok "fiioupdate queda activo"
[ "$(grep -cE '^  "[^|]+\|[^|]+\|' build/config.sh)" = "$(grep -cE '^  "[^|]+\|[^|]+\|[0-9a-f]{64}"$' build/config.sh)" ] && ok "cada descarga tiene sha256" || mal "descarga sin sha256"

echo "Archivos propietarios"
PROHIBIDOS="$(git ls-files 2>/dev/null | grep -E '\.(apk|xapk|img|dat|odex|oat|pk8|jar)$|m9-ota' || true)"
[ -z "$PROHIBIDOS" ] && ok "sin binarios propietarios" || mal "archivos prohibidos: $PROHIBIDOS"
python3 -c "
import zipfile; z=zipfile.ZipFile('assets/bootanimation.zip')
assert all(i.compress_type==0 for i in z.infolist()), 'comprimido'
assert z.read('desc.txt').startswith(b'480 800')
" && ok "bootanimation.zip sin compresion" || mal "bootanimation.zip"

echo "Privacidad"
bash herramientas/revisar_privacidad.sh >/dev/null && ok "sin datos privados" || mal "revisar_privacidad.sh"

echo
[ "$FALLAS" -eq 0 ] && { echo "Todas las pruebas pasan."; exit 0; } || { echo "$FALLAS pruebas fallan."; exit 1; }
