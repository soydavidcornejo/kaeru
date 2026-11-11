<p align="center"><img src="assets/kamon.png" width="200" alt="Kamon de Kaeru: una rana crema dentro de un anillo, sobre negro"></p>

<h1 align="center">Kaeru 蛙</h1>

<p align="center">Un firmware minimal para el reproductor <b>FiiO M9</b>. Se arma desde el firmware oficial de FiiO, en tu computador, con un comando.</p>

<p align="center"><a href="README.md">English</a> · <a href="docs/es/instalar.md">Guía de instalación</a> · <a href="CONTRIBUTING.md">Cómo aportar</a></p>

---

El FiiO M9 usa Android 7.0 con muchas apps que no necesitas. Kaeru las quita, arregla la rueda de volumen y le da al reproductor un solo estilo tranquilo: negro, crema y un sello rojo.

## Qué cambia Kaeru

| Área | Cambio |
|---|---|
| Apps | Quita 36 apps de sistema: teclados chino y coreano, AirPlay, impresión, apps de demostración, respaldos y más. |
| Lanzador | Cambia Launcher3 por [Olauncher](https://github.com/tanujnotes/Olauncher) (solo texto), en crema y rojo. |
| Rueda de volumen | Ignora los pasos extra que manda una rueda gastada (el volumen salta dos pasos o se devuelve). |
| Estilo | Pantalla de inicio y de bloqueo negras. Animación de arranque nueva con el kamon de Kaeru. |
| Archivos | Quita los audios de demostración de FiiO. |
| No cambia | El kernel, el recovery, el bootloader y los drivers de audio quedan iguales a los de FiiO. Tu música y tus ajustes se quedan en el equipo. |

Opcional, después de flashear: desactivar más apps y las animaciones, e instalar Spotify (ver la [guía](docs/es/instalar.md)).

## Antes de empezar

> [!WARNING]
> Flasheas Kaeru bajo tu propio riesgo. Kaeru no es de FiiO y FiiO no le da soporte.
> Deja el firmware oficial de FiiO en tu microSD. Es tu camino de vuelta (ver [Rescate](docs/es/instalar.md#rescate)).

Necesitas:

- Un FiiO M9 (probado con el firmware 1.0.7).
- Una microSD con al menos 2 GB libres.
- Un computador con macOS o Linux, Java 11+, Python 3, `e2fsprogs` y las build-tools del Android SDK (`zipalign`, `apksigner`).
- Opcional: `adb` (Android platform-tools) para los pasos después de instalar.

## Inicio rápido

1. Descarga el código:
   ```sh
   git clone https://github.com/soydavidcornejo/kaeru && cd kaeru
   ```
2. Arma el firmware. El script descarga el firmware de FiiO y las herramientas, y revisa cada archivo con SHA-256:
   ```sh
   ./kaeru.sh build
   ```
3. Copia `dist/kaeru-m9-1.0.zip` a tu microSD.
4. Flashéalo con el actualizador de FiiO. Sigue la [guía de instalación](docs/es/instalar.md).

## Por qué lo armas tú

Kaeru parte del firmware de FiiO, y ese firmware es de FiiO. Este repositorio **no tiene firmware, ni APKs, ni llaves privadas**. Tiene solo scripts, arte propio e instrucciones. Cada persona arma su copia desde el archivo oficial.

## Cómo funciona

1. **Conseguir el firmware.** El script descarga `m9-ota-1.0.7.zip` del servidor de actualizaciones de FiiO y revisa su SHA-256.
2. **Abrir la imagen del sistema.** `sdat2img` convierte `system.new.dat` en una imagen ext4. `debugfs` edita la imagen. No hace falta montarla ni tener root.
3. **Parchar la rueda de volumen.** El código del volumen está en `SystemUI.odex`. `baksmali` lo convierte en smali. Un parche pequeño ignora un paso que llega muy pronto después del anterior (140 ms en la misma dirección, 300 ms en la dirección contraria). `smali` arma un `classes.dex` nuevo.
4. **Cambiar el estilo.** Los fondos de `framework-res.apk` quedan negros. Olauncher recibe los colores del kamon.
5. **Quitar apps.** La lista está en [`build/eliminar.txt`](build/eliminar.txt).
6. **Empaquetar y firmar.** `img2sdat` arma un `system.new.dat` nuevo. El script lo pone en una copia del zip de FiiO y firma el zip.

FiiO firmó el firmware del M9 con las llaves públicas de prueba de AOSP (`test-keys`). El recovery del M9 acepta un paquete firmado con esas llaves. Kaeru usa las mismas llaves públicas. No rompe ninguna seguridad del equipo.

## Estructura

```
kaeru.sh            build | post | spotify | revertir | limpiar
build/              pasos 01-07, lista de apps a quitar, parches
device/             scripts después de instalar (ADB), Kuro (fondo negro), script de Spotify
assets/             animación de arranque y kamon (arte propio, MIT)
docs/en, docs/es    guía de instalación
pruebas/            pruebas (corren en CI)
```

## Aportar

Kaeru es pequeño a propósito. Buenos aportes: probar en un M9 real, reportar un problema, traducir, mejorar la guía. Lee [CONTRIBUTING.md](CONTRIBUTING.md).

## Licencia

Código y arte de Kaeru: [MIT](LICENSE). Firmware: propiedad de FiiO. Olauncher: GPL-3.0, de sus autores. Las herramientas que descarga el build mantienen sus licencias.
