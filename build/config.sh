# Configuracion de Kaeru. Todas las descargas se verifican con sha256.
# shellcheck shell=bash disable=SC2034

KAERU_VERSION="1.0"

# Firmware oficial de FiiO (no se guarda en el repo: se descarga del servidor de FiiO).
FW_VERSION="1.0.7"
FW_URL="http://m9pack.fiio.net/1.0.6/m9-ota-1.0.7.zip"
FW_SHA256="20ca2efa0c388c40483ab0b406d485bcaa5e6f6ea4406b60e8f959b2c2d43bdb"

# Herramientas (URL y sha256)
SDAT2IMG_COMMIT="0eec6c264645ad610169b3c807175c437e1f3aa4"
IMG2SDAT_COMMIT="19b4f1c2d330923b0a19453e99d3218d7f9249f1"
HERRAMIENTAS=(
  "sdat2img.py|https://raw.githubusercontent.com/xpirt/sdat2img/${SDAT2IMG_COMMIT}/sdat2img.py|35c39baf6f7e700e4cbebf70b86d602e312e3146e58ec1e8b08c1baf046edeb9"
  "img2sdat/img2sdat.py|https://raw.githubusercontent.com/xpirt/img2sdat/${IMG2SDAT_COMMIT}/img2sdat.py|ea04a5947fb9c6a7c424e48ef9ae5daabd27e013c5fe34ca79b0febb04a60072"
  "img2sdat/blockimgdiff.py|https://raw.githubusercontent.com/xpirt/img2sdat/${IMG2SDAT_COMMIT}/blockimgdiff.py|f67ca0c0dd4448997ef7df39c6101dec02bcdbff08abd592820ef661a57128cb"
  "img2sdat/common.py|https://raw.githubusercontent.com/xpirt/img2sdat/${IMG2SDAT_COMMIT}/common.py|b2657dc565e5c1b6d8f808fd1a1cce4f8cd7d7c61af8b90affcfea8225a58947"
  "img2sdat/rangelib.py|https://raw.githubusercontent.com/xpirt/img2sdat/${IMG2SDAT_COMMIT}/rangelib.py|5584d84abaabcf9ca9fdd46ba3028495e3e7f9122a0c9d0b74e9399ed8956820"
  "img2sdat/sparse_img.py|https://raw.githubusercontent.com/xpirt/img2sdat/${IMG2SDAT_COMMIT}/sparse_img.py|bc422158db1d30ab5955665397e18a73e408f8500f6791c94d9aaaff978bf725"
  "smali.jar|https://bitbucket.org/JesusFreke/smali/downloads/smali-2.5.2.jar|9544299578b16f771d8aa8eaefe0d3718ca03478c16f3c356f2fcf1366bfb116"
  "baksmali.jar|https://bitbucket.org/JesusFreke/smali/downloads/baksmali-2.5.2.jar|d3116248cce4f82ec5a31eb7f95ee75daff42ddf6eed0ab573973dc53fbad2e5"
  "apktool.jar|https://github.com/iBotPeaches/Apktool/releases/download/v2.9.3/apktool_2.9.3.jar|7956eb04194300ce0d0a84ad18771eebc94b89fb8d1ddcce8ea4c056818646f4"
  "bcprov.jar|https://repo1.maven.org/maven2/org/bouncycastle/bcprov-jdk15on/1.50/bcprov-jdk15on-1.50.jar|115b14a02b91fb03cb1866d6b311d33cd5518a9d8524dd63a14f19571e420404"
  "bcpkix.jar|https://repo1.maven.org/maven2/org/bouncycastle/bcpkix-jdk15on/1.50/bcpkix-jdk15on-1.50.jar|037dca15295313174f3f88cc9631db4896d8726a3be3e0cd65e6c2534ad22ed3"
  "olauncher.apk|https://f-droid.org/repo/app.olauncher_114.apk|27d02910287065256f2e4df8cbf28fc7cbfa6c865294d5773158b633f250bdb8"
)

# Firmador y llaves publicas de AOSP. El firmware del M9 usa estas llaves (test-keys),
# por eso el recovery acepta paquetes firmados con ellas.
AOSP="https://android.googlesource.com/platform/build/+/refs/heads"
FUENTES_AOSP=(
  "SignApk.java|${AOSP}/lollipop-release/tools/signapk/SignApk.java?format=TEXT|30fe2ecaf49e388753f0dc63d76eebea684d4f0ba7f557e8434b3d9f964d6103"
  "llaves/testkey.pk8|${AOSP}/nougat-release/target/product/security/testkey.pk8?format=TEXT|495675d32e89a149d5abe191f4e9c0e218b9068714e9b53a7c91e164a0741a23"
  "llaves/testkey.x509.pem|${AOSP}/nougat-release/target/product/security/testkey.x509.pem?format=TEXT|a4384ba815b9499a5ce349b4e33c1755278873fe2eac150a068823f526e6dbde"
  "llaves/platform.pk8|${AOSP}/nougat-release/target/product/security/platform.pk8?format=TEXT|1ad8ef556870edb70f69a9d3c112544c07de5162ba440d84d33f8bb0c5962875"
  "llaves/platform.x509.pem|${AOSP}/nougat-release/target/product/security/platform.x509.pem?format=TEXT|9837de028f460c35cc8d3fa45f14eecce30f6fbfe4b93d399aef1acb80c20d14"
)

# Colores (kamon): crema y rojo del sello
COLOR_CREMA="e8e0cc"
COLOR_ROJO="b22824"

# Rueda de volumen: milisegundos que se ignoran despues de un paso (ajustable en el equipo con setprop)
DBNC_MISMA_MS=140
DBNC_REVERSA_MS=300
