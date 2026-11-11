# Instalar Kaeru en el FiiO M9

[English](../en/install.md)

Esta guía tiene cinco partes: [armar](#1-armar), [flashear](#2-flashear), [después de flashear](#3-después-de-flashear), [rescate](#rescate) y [problemas](#problemas).

> [!WARNING]
> Flashear cambia el sistema de tu reproductor. Haz los pasos en orden. No apagues el reproductor mientras instala.
> Kaeru mantiene tu música y tus ajustes, pero antes copia tus archivos importantes.

## 1. Armar

### Instalar las herramientas

**macOS** (con [Homebrew](https://brew.sh)):

```sh
brew install e2fsprogs openjdk python
```

Instala [Android Studio](https://developer.android.com/studio) o el SDK de línea de comandos. Necesitas `build-tools` (para `zipalign` y `apksigner`) y `platform-tools` (para `adb`). Para la app opcional Kuro, también necesitas una plataforma, `android-24` o más nueva.

**Debian o Ubuntu:**

```sh
sudo apt install e2fsprogs default-jdk python3 zip unzip curl apksigner zipalign adb
```

Si el SDK no está en `~/Library/Android/sdk` (macOS) o `~/Android/Sdk` (Linux), define `ANDROID_HOME`.

### Correr el build

```sh
git clone https://github.com/soydavidcornejo/kaeru
cd kaeru
./kaeru.sh build
```

El build tarda entre 5 y 15 minutos. Usa unos 4 GB de disco en `trabajo/`.

El build hace estos pasos. Cada uno se detiene con un error si algo está mal:

1. Descarga las herramientas y revisa cada archivo con SHA-256.
2. Descarga el firmware 1.0.7 de FiiO (526 MB) y lo revisa con SHA-256.
3. Parcha la rueda de volumen en SystemUI.
4. Deja los fondos en negro.
5. Cambia los colores de Olauncher.
6. Aplica todos los cambios a la imagen del sistema.
7. Empaqueta y firma el resultado.

El resultado queda en `dist/`:

- `kaeru-m9-1.0.zip`: el firmware para flashear.
- `kaeru-m9-1.0.zip.sha256`: su suma de verificación.
- `kuro.apk`: solo si tienes una plataforma de Android instalada (ver [después de flashear](#3-después-de-flashear)).

Si ya tienes el zip oficial, úsalo para no descargarlo de nuevo:

```sh
KAERU_FIRMWARE=/ruta/a/m9-ota-1.0.7.zip ./kaeru.sh build
```

## 2. Flashear

### Preparar la microSD

1. Pon la microSD en el reproductor. Si el reproductor lo pide, formatea la tarjeta en el reproductor.
2. Conecta el reproductor al computador, o pon la tarjeta en el computador.
3. Copia `dist/kaeru-m9-1.0.zip` a la raíz de la tarjeta.
4. Copia también el firmware oficial `trabajo/m9-ota-1.0.7.zip` a la tarjeta, con el nombre `STOCK-1.0.7.zip`. Es tu archivo de rescate.
5. Crea esta carpeta en la tarjeta: `Android/data/com.android.fiioupdate/files`.

> [!NOTE]
> El actualizador de FiiO no muestra la tarjeta si falta la carpeta del paso 5.
> Con ADB, la puedes crear así: `adb shell mkdir -p /storage/external_sd/Android/data/com.android.fiioupdate/files`

### Instalar

1. Carga el reproductor al menos al 50%.
2. Abre el actualizador de FiiO. Con ADB, ejecuta:
   ```sh
   adb shell am start -n com.android.fiioupdate/.activity.OtaUpdateActivity
   ```
   Sin computador, abre la app **Technical Support** (Soporte técnico) en el reproductor.
3. Toca **Local**.
4. Toca **TF card**.
5. Elige `kaeru-m9-1.0.zip`.
6. Confirma. El reproductor se reinicia e instala el paquete. Tarda unos 5 minutos.
7. Espera la animación de Kaeru (un anillo, después una rana, después 侍蛙). El primer arranque tarda más que lo normal.

Si el actualizador dice que el paquete no es válido, no pruebes otros archivos. Lee [problemas](#problemas).

## 3. Después de flashear

Estos pasos son opcionales. Usan ADB y no necesitan root.

### Activar la depuración USB

1. Abre **Ajustes → Información del dispositivo**.
2. Toca **Número de compilación** 7 veces.
3. Abre **Ajustes → Opciones de desarrollador**.
4. Activa **Depuración USB**.
5. Conecta el reproductor al computador. En el reproductor, acepta el mensaje.

Revisa la conexión:

```sh
adb devices
```

### Aplicar los ajustes extra

```sh
./kaeru.sh post
```

Este comando:

- desactiva apps que Kaeru mantiene pero que casi nadie usa (las apps de streaming de FiiO y la galería). La lista está en [`device/desactivar.txt`](../../device/desactivar.txt).
- apaga las animaciones.
- deja negro el fondo actual. Si usabas otro fondo antes de Kaeru, Android lo mantiene. La app pequeña Kuro (`dist/kuro.apk`) lo cambia a negro, y después el script desinstala Kuro.

Para deshacerlo:

```sh
./kaeru.sh revertir
```

### Instalar Spotify (opcional)

Kaeru no incluye Spotify. El script lo descarga con [apkeep](https://github.com/EFForg/apkeep), revisa que Spotify lo firmó y después lo instala.

1. Instala apkeep: `cargo install apkeep`.
2. Ejecuta:
   ```sh
   ./kaeru.sh spotify
   ```
3. En el reproductor, activa el Wi-Fi.
4. Abre Spotify. Entra con tu correo y tu contraseña.

> [!NOTE]
> El M9 no tiene servicios de Google. El botón "Continuar con Google" de Spotify no funciona. Usa tu correo.
> YouTube Music no funciona en el M9: necesita Android 8 y servicios de Google.

## Ajustar la rueda de volumen

Kaeru ignora un paso de volumen que llega muy pronto después del anterior:

| Propiedad | Por defecto | Significado |
|---|---|---|
| `persist.kaeru.dbnc_same` | 140 ms | Pasos en la misma dirección |
| `persist.kaeru.dbnc_rev` | 300 ms | Un paso en la dirección contraria |

Cambia un valor con ADB. El cambio funciona al tiro y se mantiene después de reiniciar:

```sh
adb shell setprop persist.kaeru.dbnc_same 160
adb shell setprop persist.kaeru.dbnc_rev 350
```

Mira qué pasos ignora Kaeru:

```sh
adb logcat -s KaeruDbnc
```

- Si el volumen todavía salta, sube los valores.
- Si los giros rápidos se sienten lentos, baja `persist.kaeru.dbnc_same`.

## El LED

El LED no está malo si está apagado. El sistema de FiiO enciende el LED solo en estos casos:

- la batería está baja,
- el reproductor está cargando,
- el Bluetooth está emparejando o conectado,
- suena música (el color depende del tipo de archivo).

Cuando la batería está llena, el LED se apaga. Kaeru no cambia el LED.

## Rescate

Usa el firmware oficial para volver al sistema de FiiO.

**Si el reproductor arranca:**

1. Abre el actualizador de FiiO (ver [instalar](#instalar)).
2. Toca **Local → TF card**.
3. Elige `STOCK-1.0.7.zip`.

**Si el reproductor no arranca:**

1. Apaga el reproductor. Si es necesario, mantén el botón de encendido 10 segundos.
2. Mantén **Subir volumen** y **Encendido** juntos hasta que aparezca el menú de recovery.
3. Elige la actualización desde la tarjeta externa y elige `STOCK-1.0.7.zip`.

> [!NOTE]
> Todavía no necesitamos el menú de recovery. Si estas teclas no lo abren en tu reproductor, abre un issue.

## Problemas

| Problema | Qué hacer |
|---|---|
| El build se detiene con "sha256 no coincide" | Una descarga está rota o cambió. Borra `trabajo/herramientas` y corre el build de nuevo. Si falla el firmware, revisa que el archivo sea el 1.0.7 de FiiO. |
| El build dice que falta una herramienta (`falta …`) | Instala la herramienta que nombra el mensaje. |
| El actualizador no muestra la tarjeta | Crea la carpeta `Android/data/com.android.fiioupdate/files` en la tarjeta. |
| El actualizador no abre | Ejecuta `adb shell pm enable com.android.fiioupdate`. |
| El paquete no es válido | Revisa el archivo con `shasum -a 256 -c kaeru-m9-1.0.zip.sha256` (en `dist/`). Cópialo de nuevo. |
| El reproductor se reinicia sin parar | Haz el [rescate](#rescate). Después abre un issue con la salida del build. |
| El volumen todavía salta | [Ajusta la rueda de volumen](#ajustar-la-rueda-de-volumen). |
| Spotify no entra | Activa el Wi-Fi. Usa correo y contraseña, no Google. |

No desactives `com.android.statementservice`. Sin esa app, Android 7 no arranca.
