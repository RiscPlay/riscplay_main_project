async function parseBMP(file) {
    const buffer = await file.arrayBuffer();
    const view = new DataView(buffer);

    // Assinatura BMP
    if (view.getUint16(0, false) !== 0x424D) {
        throw new Error("Não é um arquivo BMP");
    }

    const pixelOffset = view.getUint32(10, true);
    const dibSize = view.getUint32(14, true);

    const width = view.getInt32(18, true);
    const heightRaw = view.getInt32(22, true);

    const topDown = heightRaw < 0;
    const height = Math.abs(heightRaw);

    const bpp = view.getUint16(28, true);
    const compression = view.getUint32(30, true);

    if (compression !== 0) {
        throw new Error("Somente BI_RGB sem compressão é suportado");
    }

    // Quantidade de cores da paleta
    let colorsUsed = 0;

    if (dibSize >= 40) {
        colorsUsed = view.getUint32(46, true);
    }

    let paletteEntries = 0;

    if (bpp <= 8) {
        paletteEntries = colorsUsed || (1 << bpp);
    }

    // Leitura da paleta
    const palette = [];
    const paletteOffset = 14 + dibSize;

    for (let i = 0; i < paletteEntries; i++) {
        const p = paletteOffset + i * 4;

        palette.push({
            r: view.getUint8(p + 2),
            g: view.getUint8(p + 1),
            b: view.getUint8(p + 0)
        });
    }

    // Matriz de índices
    const pixels = Array.from(
        { length: height },
        () => new Array(width)
    );

    const rowSize = Math.floor((bpp * width + 31) / 32) * 4;

    for (let y = 0; y < height; y++) {

        const bmpY = topDown
            ? y
            : (height - 1 - y);

        const rowStart = pixelOffset + bmpY * rowSize;

        if (bpp === 8) {

            for (let x = 0; x < width; x++) {
                pixels[y][x] =
                    view.getUint8(rowStart + x);
            }

        } else if (bpp === 4) {

            for (let x = 0; x < width; x++) {

                const byte =
                    view.getUint8(rowStart + (x >> 1));

                pixels[y][x] =
                    (x & 1)
                    ? (byte & 0x0F)
                    : ((byte >> 4) & 0x0F);
            }

        } else if (bpp === 1) {

            for (let x = 0; x < width; x++) {

                const byte =
                    view.getUint8(rowStart + (x >> 3));

                pixels[y][x] =
                    (byte >> (7 - (x & 7))) & 1;
            }

        } else {
            throw new Error(
                `BPP ${bpp} não suportado`
            );
        }
    }

    return {
        width,
        height,
        bpp,
        palette,
        pixels
    };
}