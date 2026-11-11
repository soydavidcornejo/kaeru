#!/usr/bin/env bash
# Paso 6: aplicar todos los cambios a system.img con debugfs (sin montar la imagen).
set -euo pipefail
source "$(dirname "$0")/lib.sh"
cargar_programas
paso "6/7 Cambios en system.img"
cp "$RAIZ/assets/bootanimation.zip" "$TRABAJO/bootanimation.zip"
CMD="$TRABAJO/debugfs.txt"
existe() { local r; r="$(cd "$TRABAJO" && "$DEBUGFS" -R "stat $1" system.img 2>&1 || true)"; case "$r" in *Inode:*) return 0;; *) return 1;; esac; }
# poner <archivo-local> <ruta-en-system>
poner() { printf 'rm %s\nwrite %s %s\nsif %s mode 0100644\nsif %s uid 0\nsif %s gid 0\n' "$2" "$1" "$2" "$2" "$2" "$2"; }
{
  n=0
  while read -r carpeta; do
    case "$carpeta" in ''|'#'*) continue;; esac
    nombre="$(basename "$carpeta")"
    printf 'rm %s/%s.apk\nrm %s/oat/arm/%s.odex\n' "$carpeta" "$nombre" "$carpeta" "$nombre"
    n=$((n + 1))
  done < "$RAIZ/build/eliminar.txt"
  # Launcher3 -> Olauncher
  printf 'rm /app/Launcher3/Launcher3.apk\nrm /app/Launcher3/oat/arm/Launcher3.odex\n'
  # mkdir sobre una carpeta que ya existe deja un inodo huerfano en debugfs: solo se crea si falta
  existe /app/Olauncher || printf 'mkdir /app/Olauncher\nsif /app/Olauncher mode 040755\n'
  poner Olauncher.apk /app/Olauncher/Olauncher.apk
  # SystemUI parchada: el .odex viejo se borra para que Android use el classes.dex nuevo
  poner SystemUI.apk /priv-app/SystemUI/SystemUI.apk
  printf 'rm /priv-app/SystemUI/oat/arm/SystemUI.odex\n'
  poner framework-res.apk /framework/framework-res.apk
  poner bootanimation.zip /media/bootanimation.zip
  # audios de demostracion de FiiO
  printf 'rm /media/Epic_Trailer_Theme.flac\nrm /media/03-WAV-0-level-48K-24.wav\n'
  echo quit
} > "$CMD"
info "$(grep -c '^rm ' "$CMD") borrados, $(grep -c '^write ' "$CMD") archivos nuevos"
debugfs_cmds debugfs.txt | grep -vE '^debugfs: |^Allocated inode|File not found by ext2_lookup' || true
"$E2FSCK" -fy "$TRABAJO/system.img" >/dev/null 2>&1 || [ $? -le 1 ] || falla "e2fsck encontro errores graves en system.img"
# comprobacion: los archivos nuevos estan y lo borrado no
for f in /app/Olauncher/Olauncher.apk /priv-app/SystemUI/SystemUI.apk /framework/framework-res.apk /media/bootanimation.zip /priv-app/StatementService; do
  existe "$f" || falla "falta $f en system.img"
done
existe /app/Launcher3/Launcher3.apk && falla "Launcher3 sigue en system.img"
existe /priv-app/SystemUI/oat/arm/SystemUI.odex && falla "el odex viejo de SystemUI sigue en system.img"
info "listo"
