# Install Kaeru on the FiiO M9

[Español](../es/instalar.md)

This guide has five parts: [build](#1-build), [flash](#2-flash), [after you flash](#3-after-you-flash), [rescue](#rescue) and [problems](#problems).

> [!WARNING]
> Flashing changes the system of your player. Do the steps in order. Do not turn off the player while it installs.
> Kaeru keeps your music and settings, but make a copy of your important files first.

## 1. Build

### Install the tools

**macOS** (with [Homebrew](https://brew.sh)):

```sh
brew install e2fsprogs openjdk python
```

Install [Android Studio](https://developer.android.com/studio) or the command-line SDK. You need `build-tools` (for `zipalign` and `apksigner`) and `platform-tools` (for `adb`). For the optional Kuro app, you also need one platform, `android-24` or newer.

**Debian or Ubuntu:**

```sh
sudo apt install e2fsprogs default-jdk python3 zip unzip curl apksigner zipalign adb
```

If the SDK is not in `~/Library/Android/sdk` (macOS) or `~/Android/Sdk` (Linux), set `ANDROID_HOME`.

### Run the build

```sh
git clone https://github.com/soydavidcornejo/kaeru
cd kaeru
./kaeru.sh build
```

The build takes 5 to 15 minutes. It uses about 4 GB of disk in `trabajo/`.

The build does these steps. Each one stops with an error if something is wrong:

1. It downloads the tools and checks each file with SHA-256.
2. It downloads FiiO's firmware 1.0.7 (526 MB) and checks it with SHA-256.
3. It patches the volume wheel in SystemUI.
4. It makes the wallpapers black.
5. It changes the colors of Olauncher.
6. It applies all changes to the system image.
7. It packs and signs the result.

The result is in `dist/`:

- `kaeru-m9-1.0.zip`: the firmware to flash.
- `kaeru-m9-1.0.zip.sha256`: its checksum.
- `kuro.apk`: only if you have an Android platform installed (see [after you flash](#3-after-you-flash)).

If you already have the official zip, use it to skip the download:

```sh
KAERU_FIRMWARE=/path/to/m9-ota-1.0.7.zip ./kaeru.sh build
```

## 2. Flash

### Prepare the microSD card

1. Put the microSD card in the player. If the player asks, format the card on the player.
2. Connect the player to the computer, or put the card in the computer.
3. Copy `dist/kaeru-m9-1.0.zip` to the root of the card.
4. Also copy the official firmware `trabajo/m9-ota-1.0.7.zip` to the card, with the name `STOCK-1.0.7.zip`. This is your rescue file.
5. Make this folder on the card: `Android/data/com.android.fiioupdate/files`.

> [!NOTE]
> FiiO's updater does not show the card if the folder in step 5 is missing.
> With ADB, you can make it with: `adb shell mkdir -p /storage/external_sd/Android/data/com.android.fiioupdate/files`

### Install

1. Charge the player to at least 50%.
2. Open FiiO's updater. With ADB, run:
   ```sh
   adb shell am start -n com.android.fiioupdate/.activity.OtaUpdateActivity
   ```
   Without a computer, open the firmware update entry in the player's settings.
3. Tap **Local**.
4. Tap **TF card**.
5. Select `kaeru-m9-1.0.zip`.
6. Confirm. The player restarts and installs the package. This takes about 5 minutes.
7. Wait for the Kaeru animation (a ring, then a frog, then 侍蛙). The first start takes longer than usual.

If the updater says that the package is not valid, do not try other files. Read [problems](#problems).

## 3. After you flash

These steps are optional. They use ADB and do not need root.

### Turn on USB debugging

1. Open **Settings → About device**.
2. Tap **Build number** 7 times.
3. Open **Settings → Developer options**.
4. Turn on **USB debugging**.
5. Connect the player to the computer. On the player, accept the message.

Check the connection:

```sh
adb devices
```

### Apply the extra settings

```sh
./kaeru.sh post
```

This command:

- turns off apps that Kaeru keeps but that most people do not use (FiiO's streaming apps and the gallery). The list is in [`device/desactivar.txt`](../../device/desactivar.txt).
- turns off the animations.
- makes the current wallpaper black. If you used another wallpaper before Kaeru, Android keeps it. The small app Kuro (`dist/kuro.apk`) changes it to black, and then the script removes Kuro.

To undo it:

```sh
./kaeru.sh revertir
```

### Install Spotify (optional)

Kaeru does not include Spotify. The script downloads it with [apkeep](https://github.com/EFForg/apkeep), checks that Spotify signed it, and then installs it.

1. Install apkeep: `cargo install apkeep`.
2. Run:
   ```sh
   ./kaeru.sh spotify
   ```
3. On the player, turn on Wi-Fi.
4. Open Spotify. Log in with your email and password.

> [!NOTE]
> The M9 has no Google services. The "Continue with Google" button in Spotify does not work. Use your email.
> YouTube Music does not work on the M9: it needs Android 8 and Google services.

## Tune the volume wheel

Kaeru ignores a volume step that comes too soon after the step before it:

| Property | Default | Meaning |
|---|---|---|
| `persist.kaeru.dbnc_same` | 140 ms | Steps in the same direction |
| `persist.kaeru.dbnc_rev` | 300 ms | A step in the other direction |

Change a value with ADB. The change starts at once and stays after a restart:

```sh
adb shell setprop persist.kaeru.dbnc_same 160
adb shell setprop persist.kaeru.dbnc_rev 350
```

See which steps Kaeru ignores:

```sh
adb logcat -s KaeruDbnc
```

- If the volume still jumps, increase the values.
- If fast turns feel slow, decrease `persist.kaeru.dbnc_same`.

## The LED

The LED is not broken if it is off. FiiO's system turns the LED on only for these states:

- the battery is low,
- the player is charging,
- Bluetooth is pairing or connected,
- music plays (color by file type).

When the battery is full, the LED goes off. Kaeru does not change the LED.

## Rescue

Use the official firmware to go back to FiiO's system.

**If the player starts:**

1. Open FiiO's updater (see [install](#install)).
2. Tap **Local → TF card**.
3. Select `STOCK-1.0.7.zip`.

**If the player does not start:**

1. Turn off the player. If necessary, hold the power button for 10 seconds.
2. Hold **Volume up** and **Power** together until the recovery menu shows.
3. Select the update from the external card and select `STOCK-1.0.7.zip`.

> [!NOTE]
> We have not needed the recovery menu yet. If these keys do not open it on your player, open an issue.

## Problems

| Problem | What to do |
|---|---|
| The build stops with "sha256 no coincide" | A download is broken or changed. Delete `trabajo/herramientas` and run the build again. If the firmware fails, check that the file is FiiO's 1.0.7. |
| The build says a tool is missing (`falta …`) | Install the tool that the message names. |
| The updater does not show the card | Make the folder `Android/data/com.android.fiioupdate/files` on the card. |
| The updater does not open | Run `adb shell pm enable com.android.fiioupdate`. |
| The package is not valid | Check the file with `shasum -a 256 -c kaeru-m9-1.0.zip.sha256` (in `dist/`). Copy it again. |
| The player restarts without end | Do the [rescue](#rescue). Then open an issue with the output of the build. |
| The volume still jumps | [Tune the volume wheel](#tune-the-volume-wheel). |
| Spotify does not log in | Turn on Wi-Fi. Use email and password, not Google. |

Do not turn off `com.android.statementservice`. Without it, Android 7 does not start.
