#!/bin/bash
set -e

IMAGE=whisper-builder
OUTDIR="$(pwd)"

docker build -t $IMAGE .

docker run --rm -v "$OUTDIR:/out" $IMAGE bash -lc '

set -e

rm -rf /whisper
git clone https://github.com/tenstorrent/whisper.git /whisper

cd /whisper
make SOFT_FLOAT=1

echo "==> Searching real ELF binary..."

BIN=$(find /whisper -type f -executable -exec file {} \; | grep ELF | grep executable | grep whisper | head -n1 | cut -d: -f1)

echo "Binary found: $BIN"

mkdir -p /Whisper.AppDir/usr/bin
mkdir -p /Whisper.AppDir/usr/lib

cp "$BIN" /Whisper.AppDir/usr/bin/whisper
chmod +x /Whisper.AppDir/usr/bin/whisper

cat > /Whisper.AppDir/AppRun <<EOF
#!/bin/bash
HERE=\$(dirname "\$(readlink -f "\$0")")
exec "\$HERE/usr/bin/whisper" "\$@"
EOF

chmod +x /Whisper.AppDir/AppRun

cat > /Whisper.AppDir/whisper.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Whisper
Exec=whisper
Icon=whisper
Terminal=true
Categories=Development;
EOF

# create valid png icon
base64 -d > /Whisper.AppDir/whisper.png <<EOF
iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jh4QAAAAASUVORK5CYII=
EOF

ldd "$BIN" | awk "{print \$3}" | grep "^/" | while read lib; do
cp -v "$lib" /Whisper.AppDir/usr/lib/ || true
done || true

APPIMAGE_EXTRACT_AND_RUN=1 ARCH=x86_64 /appimagetool.AppImage \
/Whisper.AppDir /out/Whisper-x86_64.AppImage

echo DONE
'
