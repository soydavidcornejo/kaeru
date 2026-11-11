<p align="center"><img src="assets/kamon.png" width="200" alt="Kaeru kamon: a cream frog inside a ring, on black"></p>

<h1 align="center">Kaeru 蛙</h1>

<p align="center">A minimal firmware for the <b>FiiO M9</b> music player. Built from FiiO's own firmware, on your computer, in one command.</p>

<p align="center"><a href="README.es.md">Español</a> · <a href="docs/en/install.md">Install guide</a> · <a href="CONTRIBUTING.md">Contribute</a></p>

---

The FiiO M9 runs Android 7.0 with many apps you do not need. Kaeru removes them, fixes the volume wheel, and gives the player one quiet look: black, cream and one red seal.

## What Kaeru changes

| Area | Change |
|---|---|
| Apps | Removes 36 system apps: Chinese and Korean keyboards, AirPlay, print service, demo apps, backup tools and more. |
| Launcher | Replaces Launcher3 with [Olauncher](https://github.com/tanujnotes/Olauncher) (text only), in cream and red. |
| Volume wheel | Ignores the extra steps that a worn wheel sends (the volume jumps two steps or goes back). |
| Look | Black home and lock screen. New boot animation with the Kaeru kamon. |
| Media | Removes FiiO's demo audio files. |
| Not changed | Kernel, recovery, bootloader and audio drivers stay identical to FiiO's. Your music and settings stay on the player. |

Optional, after you flash: turn off more apps and animations, and install Spotify (see the [install guide](docs/en/install.md)).

## Before you start

> [!WARNING]
> You flash Kaeru at your own risk. Kaeru is not made or supported by FiiO.
> Keep the official FiiO firmware on your microSD card. It is your way back (see [Rescue](docs/en/install.md#rescue)).

You need:

- A FiiO M9 (tested with firmware 1.0.7).
- A microSD card with at least 2 GB free.
- A computer with macOS or Linux, Java 11+, Python 3, `e2fsprogs`, and Android SDK build-tools (`zipalign`, `apksigner`).
- Optional: `adb` (Android platform-tools) for the post-install steps.

## Quick start

1. Get the code:
   ```sh
   git clone https://github.com/soydavidcornejo/kaeru && cd kaeru
   ```
2. Build the firmware. The script downloads FiiO's firmware and the tools, and checks each file with SHA-256:
   ```sh
   ./kaeru.sh build
   ```
3. Copy `dist/kaeru-m9-1.0.zip` to your microSD card.
4. Flash it with FiiO's updater. Follow the [install guide](docs/en/install.md).

## Why you build it yourself

Kaeru starts from FiiO's firmware, and that firmware is FiiO's property. This repository has **no firmware, no APKs and no private keys**. It has only scripts, our own art, and the instructions. Each person builds their own copy from the official file.

## How it works

1. **Get the firmware.** The script downloads `m9-ota-1.0.7.zip` from FiiO's update server and checks its SHA-256.
2. **Open the system image.** `sdat2img` turns `system.new.dat` into an ext4 image. `debugfs` edits the image. No mount and no root are necessary.
3. **Patch the volume wheel.** The volume code is in `SystemUI.odex`. `baksmali` turns it into smali. A small patch ignores a step that arrives too soon after the step before it (140 ms in the same direction, 300 ms in the other direction). `smali` builds a new `classes.dex`.
4. **Change the look.** The wallpapers in `framework-res.apk` become black. Olauncher gets the kamon colors.
5. **Remove apps.** The list is in [`build/eliminar.txt`](build/eliminar.txt).
6. **Pack and sign.** `img2sdat` makes a new `system.new.dat`. The script puts it in a copy of FiiO's zip and signs the zip.

FiiO signed the M9 firmware with the public AOSP test keys (`test-keys`). The M9 recovery accepts a package signed with these keys. Kaeru uses the same public keys. It does not break any security on the player.

## Project layout

```
kaeru.sh            build | post | spotify | revertir | limpiar
build/              build steps 01-07, removal list, patches
device/             post-install scripts (ADB), Kuro (black wallpaper app), Spotify script
assets/             boot animation and kamon (our own art, MIT)
docs/en, docs/es    install guide
pruebas/            tests (run in CI)
```

## Contribute

Kaeru is small on purpose. Good contributions: test on a real M9, report a problem, translate, improve the guide. Read [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Kaeru code and art: [MIT](LICENSE). FiiO firmware: property of FiiO. Olauncher: GPL-3.0, by its authors. Tools that the build downloads keep their own licenses.
