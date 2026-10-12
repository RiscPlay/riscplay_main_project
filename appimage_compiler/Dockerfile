FROM --platform=linux/386 debian:trixie

ENV DEBIAN_FRONTEND=noninteractive
ENV PREFIX=/opt/riscv
ENV TARGET=riscv32-unknown-elf
ENV PATH=/opt/riscv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Compilador hospedeiro: x86 de 32 bits, sem SSE/MMX.
##ENV CFLAGS="-O2 -march=pentiumpro -mtune=pentiumpro -mno-sse -mno-sse2 -mno-mmx"
##ENV CXXFLAGS="-O2 -march=pentiumpro -mtune=pentiumpro -mno-sse -mno-sse2 -mno-mmx"
##ENV CFLAGS_FOR_BUILD="-O2 -march=pentiumpro -mtune=pentiumpro -mno-sse -mno-sse2 -mno-mmx"

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential gcc g++ make \
      binutils bison flex gawk texinfo \
      wget curl ca-certificates xz-utils \
      python3 perl file patchelf \
      libgmp-dev libmpfr-dev libmpc-dev \
      zlib1g-dev libisl-dev \
      squashfs-tools desktop-file-utils \
      fakeroot git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Versões fixadas para builds reproduzíveis.
ENV BINUTILS_VERSION=2.44
ENV GCC_VERSION=14.2.0
ENV NEWLIB_VERSION=4.4.0.20231231

# Baixa e compila binutils.
RUN wget -q \
      https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.xz \
      -O binutils.tar.xz && \
    tar -xf binutils.tar.xz && \
    mkdir binutils-build && \
    cd binutils-build && \
    ../binutils-${BINUTILS_VERSION}/configure \
      --target=${TARGET} \
      --prefix=${PREFIX} \
      --with-arch=rv32imac \
      --with-abi=ilp32 \
      --disable-nls \
      --disable-werror \
      --disable-gdb \
      --disable-sim && \
    make -j2 && \
    make install

# Baixa GCC e Newlib.
RUN wget -q \
      https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz \
      -O gcc.tar.xz && \
    tar -xf gcc.tar.xz && \
    wget -q \
      https://sourceware.org/pub/newlib/newlib-${NEWLIB_VERSION}.tar.gz \
      -O newlib.tar.gz && \
    tar -xf newlib.tar.gz

# GCC inicial: gera o compilador C sem cabeçalhos do sistema-alvo.
RUN mkdir gcc-stage1 && \
    cd gcc-stage1 && \
    ../gcc-${GCC_VERSION}/configure \
      --target=${TARGET} \
      --prefix=${PREFIX} \
      --with-arch=rv32imac \
      --with-abi=ilp32 \
      --with-newlib \
      --without-headers \
      --enable-languages=c \
      --disable-nls \
      --disable-shared \
      --disable-threads \
      --disable-multilib \
      --disable-libatomic \
      --disable-libgomp \
      --disable-libquadmath \
      --disable-libssp \
      --disable-libvtv \
      --disable-werror && \
    make -j2 all-gcc && \
    make install-gcc

# Biblioteca C bare-metal.
RUN mkdir newlib-build && \
    cd newlib-build && \
    ../newlib-${NEWLIB_VERSION}/configure \
      --target=${TARGET} \
      --prefix=${PREFIX} \
      --disable-nls \
      --disable-multilib \
      --enable-newlib-io-long-long \
      --enable-newlib-io-c99-formats \
      --disable-newlib-supplied-syscalls && \
    make -j2 && \
    make install

# GCC final: inclui as bibliotecas do alvo.
RUN mkdir gcc-final && \
    cd gcc-final && \
    ../gcc-${GCC_VERSION}/configure \
      --target=${TARGET} \
      --prefix=${PREFIX} \
      --with-arch=rv32imac \
      --with-abi=ilp32 \
      --with-newlib \
      --enable-languages=c,c++ \
      --disable-nls \
      --disable-shared \
      --disable-threads \
      --disable-multilib \
      --disable-libatomic \
      --disable-libgomp \
      --disable-libquadmath \
      --disable-libssp \
      --disable-libvtv \
      --disable-werror && \
    make -j2 && \
    make install

# Verifica o compilador e a arquitetura dos executáveis.
RUN ${TARGET}-gcc --version && \
    ${TARGET}-gcc -dumpmachine && \
    file ${PREFIX}/bin/${TARGET}-gcc

# Monta o AppDir.
RUN mkdir -p /out/AppDir/usr/bin \
             /out/AppDir/usr/lib \
             /out/AppDir/usr/share/doc/riscv-gcc

RUN cp -a ${PREFIX}/bin/. /out/AppDir/usr/bin/ && \
    cp -a ${PREFIX}/${TARGET}/. /out/AppDir/usr/${TARGET}/ && \
    cp -a ${PREFIX}/lib/. /out/AppDir/usr/lib/ && \
    cp -a ${PREFIX}/libexec/. /out/AppDir/usr/libexec/ 2>/dev/null || true

# Arquivos de suporte do GCC.
RUN cp -a ${PREFIX}/lib/gcc/. /out/AppDir/usr/lib/gcc/ && \
    cp -a ${PREFIX}/include/. /out/AppDir/usr/include/ 2>/dev/null || true

# Launcher: permite executar o GCC diretamente pelo AppImage.
RUN printf '%s\n' \
  '#!/bin/sh' \
  'HERE="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"' \
  'export PATH="$HERE/usr/bin:$PATH"' \
  'export GCC_EXEC_PREFIX="$HERE/usr/lib/gcc/"' \
  'export LD_LIBRARY_PATH="$HERE/usr/lib:$HERE/usr/lib32${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"' \
  'exec "$HERE/usr/bin/riscv32-unknown-elf-gcc" "$@"' \
  > /out/AppDir/AppRun && chmod +x /out/AppDir/AppRun

# Inclui o restante do toolchain em um diretório acessível.
RUN mkdir -p /out/AppDir/usr/share/riscv-toolchain && \
    cp -a ${PREFIX}/. /out/AppDir/usr/share/riscv-toolchain/



# O AppImage precisa de um appimagetool compatível com i686.
RUN wget -q \
      https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-i686.AppImage \
      -O /tmp/appimagetool.AppImage && \
    chmod +x /tmp/appimagetool.AppImage && \
    cd /tmp && \
    /tmp/appimagetool.AppImage --appimage-extract && \
    cp /tmp/squashfs-root/AppRun /usr/local/bin/appimagetool && \
    mkdir -p /usr/local/lib/appimagetool && \
    cp -a /tmp/squashfs-root/. /usr/local/lib/appimagetool/ && \
    printf '%s\n' \
      '#!/bin/sh' \
      'exec /usr/local/lib/appimagetool/AppRun "$@"' \
      > /usr/local/bin/appimagetool && \
    chmod +x /usr/local/bin/appimagetool && \
    rm -rf /tmp/squashfs-root /tmp/appimagetool.AppImage





RUN mkdir -p /out/AppDir/usr/share/applications \
             /out/AppDir/usr/share/icons/hicolor/256x256/apps

RUN printf '%s\n' \
    '[Desktop Entry]' \
    'Name=RISC-V GCC Toolchain' \
    'Comment=RISC-V bare-metal compiler' \
    'Exec=riscv-gcc-terminal' \
    'Icon=riscv-gcc' \
    'Terminal=true' \
    'Type=Application' \
    'Categories=Development;' \
    > /out/AppDir/usr/share/applications/riscv-gcc.desktop

RUN printf '%s\n' \
    '#!/bin/sh' \
    'HERE="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"' \
    'exec "$HERE/AppRun" "$@"' \
    > /out/AppDir/usr/bin/riscv-gcc-terminal && \
    chmod +x /out/AppDir/usr/bin/riscv-gcc-terminal

RUN apt-get update && \
    apt-get install -y --no-install-recommends imagemagick && \
    mkdir -p /out/AppDir/usr/share/icons/hicolor/256x256/apps && \
    convert -size 256x256 xc:'#263238' \
      -fill white -font DejaVu-Sans \
      -pointsize 100 -gravity center \
      -annotate +0+0 'RV' \
      /out/AppDir/riscv-gcc.png && \
    cp /out/AppDir/riscv-gcc.png \
      /out/AppDir/usr/share/icons/hicolor/256x256/apps/riscv-gcc.png && \
    rm -rf /var/lib/apt/lists/*


RUN cp /out/AppDir/usr/share/applications/riscv-gcc.desktop \
       /out/AppDir/riscv-gcc.desktop






RUN mv /usr/bin/mksquashfs /usr/bin/mksquashfs.real && \
    printf '%s\n' \
      '#!/bin/sh' \
      'exec /usr/bin/mksquashfs.real "$@" -processors 1' \
      > /usr/bin/mksquashfs && \
    chmod +x /usr/bin/mksquashfs

RUN printf '%s\n' \
    '#!/bin/sh' \
    'exec /usr/bin/mksquashfs "$@" -processors 1' \
    > /usr/local/bin/mksquashfs && \
    chmod +x /usr/local/bin/mksquashfs

ENV PATH="/usr/local/bin:${PATH}"

RUN mv /usr/bin/mksquashfs /usr/bin/mksquashfs.real && \
    printf '#!/bin/sh\nexec /usr/bin/mksquashfs.real "$@" -processors 1\n' \
      > /usr/bin/mksquashfs && \
    chmod +x /usr/bin/mksquashfs


RUN ldd /out/AppDir/usr/libexec/gcc/riscv32-unknown-elf/14.2.0/cc1
RUN set -eux; \
    mkdir -p /out/AppDir/usr/lib; \
    for lib in \
        libisl.so.23 \
        libmpc.so.3 \
        libmpfr.so.6 \
        libgmp.so.10; \
    do \
        path="$(ldconfig -p | awk -v name="$lib" '$1 == name && /i386/ {print $NF; exit}')"; \
        test -n "$path"; \
        cp -L "$path" "/out/AppDir/usr/lib/$lib"; \
    done

RUN mkdir -p /out/AppDir/usr/lib && \
    cp -L /usr/lib/i386-linux-gnu/libisl.so.23 \
          /out/AppDir/usr/lib/libisl.so.23

RUN find /usr/lib -name 'libisl.so.23*'
# Gera o pacote final.
ENV ARCH=i686
ENV VERSION=14.2.0

########RUN taskset -c 0 appimagetool --no-appstream /out/AppDir /out/riscv32-unknown-elf-gcc-i686.AppImage

CMD ["sh", "-c", "cp -rf /out/AppDir /export/"]