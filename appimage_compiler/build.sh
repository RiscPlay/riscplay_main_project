#!/usr/bin/env bash
set -Eeuo pipefail

IMAGE_NAME="riscv-gcc-appimage-builder"
OUTPUT_DIR="$(pwd)/dist"

mkdir -p "$OUTPUT_DIR"

docker build \
  --platform linux/386 \
  --progress=plain \
  -t "$IMAGE_NAME" .

docker run --rm \
  --platform linux/386 \
  -v "$OUTPUT_DIR:/export" \
  "$IMAGE_NAME"

echo
echo "Build concluído."
echo "AppImage: $OUTPUT_DIR/riscv32-unknown-elf-gcc-i686.AppImage"
sed -i '2i export LD_LIBRARY_PATH="$HERE/usr/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"' dist/AppDir/AppRun

wget https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage \
  -O appimagetool.AppImage
chmod +x appimagetool.AppImage
chmod +X appimagetool.AppImage
cp -rf dist dist____riscv32_unknown_elf_gcc
cp -rf dist dist____riscv32_unknown_elf_objcopy

sed -i '$c\exec "$HERE/usr/bin/riscv32-unknown-elf-objcopy" "$@"' dist____riscv32_unknown_elf_objcopy/AppDir/AppRun
ARCH=i686 ./appimagetool.AppImage --no-appstream dist____riscv32_unknown_elf_gcc/AppDir ./riscv32_unknown_elf_gcc.AppImage
ARCH=i686 ./appimagetool.AppImage --no-appstream dist____riscv32_unknown_elf_objcopy/AppDir ./riscv32_unknown_elf_objcopy.AppImage