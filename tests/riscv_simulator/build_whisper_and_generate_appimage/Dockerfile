# Dockerfile
FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    g++ \
    gcc \
    make \
    wget \
    file \
    patchelf \
    desktop-file-utils \
    squashfs-tools \
    xz-utils \
    ca-certificates \
    libz-dev \
    libboost-all-dev \
    && rm -rf /var/lib/apt/lists/*

# AppImage tool
RUN wget -O /appimagetool.AppImage \
https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage && \
chmod +x /appimagetool.AppImage

ENV APPIMAGE_EXTRACT_AND_RUN=1

WORKDIR /work

CMD ["bash"]
