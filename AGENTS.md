# Kaeru: guía para personas e IAs

Kaeru convierte el firmware oficial del FiiO M9 (Android 7.0, FW 1.0.7) en un firmware minimal. El repo tiene scripts, arte y guías. El firmware lo arma cada persona en su computador.

## Principios que no se negocian

1. **Nada propietario en el repo.** Nunca subir firmware de FiiO, APKs (Spotify, Olauncher, apps de FiiO), imágenes de sistema ni llaves que no sean públicas. Todo se descarga con su sha256 (`build/config.sh`).
2. **El rescate siempre funciona.** Solo se cambia la partición system. Kernel, recovery, bootloader, ldfw, efs y nvp quedan iguales a los de FiiO. La guía siempre explica cómo volver al firmware oficial.
3. **Nunca desactivar ni quitar `com.android.statementservice`** (`/priv-app/StatementService`): Android 7 entra en bootloop. Nunca desactivar `com.android.fiioupdate`: sirve para flashear.
4. **Mínimo y coherente.** Estilo: negro, crema `#E8E0CC`, rojo `#B22824`, kamon de rana. Nada caricaturesco.
5. **Documentación en inglés y español**, ~80% ASD-STE100 (frases cortas, voz activa, un paso por acción).

## Mapa del repo

| Ruta | Qué es |
|---|---|
| `kaeru.sh` | Entrada: `build`, `post`, `spotify`, `revertir`, `limpiar` |
| `build/config.sh` | Versiones, URLs y sha256 de todo lo que se descarga |
| `build/lib.sh` | Funciones comunes: descargar y verificar, buscar programas, debugfs, firmar APKs |
| `build/01..07-*.sh` | Pasos del build, en orden. Cada uno se puede correr solo |
| `build/eliminar.txt` | Apps de sistema que se quitan (carpeta dentro de /system) |
| `build/parchar_systemui.py` | Parche smali de la rueda (`VolumeControlActivityForM9.onKeyDown`) |
| `build/fondo_negro.py`, `build/colores_olauncher.py`, `build/raw2simg.py` | Ayudantes sin dependencias |
| `device/` | Scripts por ADB después de flashear, Kuro (fondo negro), Spotify |
| `assets/` | `bootanimation.zip` y kamon (arte propio). `assets/kamon/` los regenera |
| `docs/en`, `docs/es` | Guía de instalación |
| `pruebas/correr.sh` | Pruebas (corren en CI) |
| `herramientas/revisar_privacidad.sh` | Revisión de datos privados antes de cada commit |

## Cómo se conectan las piezas

1. `01` descarga herramientas y llaves públicas de AOSP, compila SignApk (lollipop + BouncyCastle 1.50; la 1.52 falla).
2. `02` descarga el firmware y saca `system.img` con sdat2img.
3. `03` deodexa SystemUI con baksmali (necesita `/framework/arm/boot*.oat` de la imagen), parcha, arma `classes.dex`, firma con la llave **platform**.
4. `04` cambia 5 PNG de `framework-res.apk` por negros del mismo tamaño (sin compresión), firma con **platform**.
5. `05` decodifica Olauncher con apktool, cambia colores, firma con **testkey**.
6. `06` aplica todo a `system.img` con `debugfs -w` (rutas sin el prefijo `/system`) y corre `e2fsck -fy`.
7. `07` raw → sparse → `img2sdat -v 4`, copia el zip oficial sin su firma, reemplaza `system.*`, firma con SignApk `-w` y testkey.

El recovery del M9 acepta testkey porque FiiO firmó con `test-keys` (huella SHA-256 `A4:0D:A8:0A:…:F5:DC`).

## Reglas

- Bash 3.2 compatible (macOS trae esa versión). `set -euo pipefail` en cada paso.
- Cada descarga nueva va en `build/config.sh` con su sha256.
- Mensajes y comentarios en español. Guías en los dos idiomas: si cambias una, cambia la otra.
- Si cambias la lista de apps, prueba en un M9 real antes de juntar.

## Pruebas

```sh
bash pruebas/correr.sh
```

Revisa sintaxis de bash y python, shellcheck (si está), que el parche de la rueda sea correcto sobre un smali de ejemplo, que `fondo_negro.py` haga PNG válidos, que no haya binarios propietarios y la privacidad.

## Privacidad

Antes de cada commit: `bash herramientas/revisar_privacidad.sh`. Busca correos, rutas `/Users/…` y los términos de `.terminos-privados` (archivo local, nunca versionado). Ejemplos solo con datos ficticios.
