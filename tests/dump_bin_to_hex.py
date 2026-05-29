import sys

def bin_to_mi(bin_path, mi_path, data_width=32):
    word_size = data_width // 8

    with open(bin_path, "rb") as f:
        data = f.read()

    # padding se não for múltiplo de 4 bytes
    if len(data) % word_size != 0:
        data += b"\x00" * (word_size - (len(data) % word_size))

    words = len(data) // word_size

    with open(mi_path, "w") as f:
        n_words_wrote=0
        for i in range(words):
            chunk = data[i * word_size:(i + 1) * word_size]

            # RISC-V = little endian
            value = int.from_bytes(chunk,byteorder="big")

            f.write(f"{value:08X}\n")
            n_words_wrote=n_words_wrote+1

        for i in range(4096-n_words_wrote):
            f.write("00000000\n")

    print(f"OK: {mi_path} gerado com {words} words")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Uso: python bin_to_mi.py input.bin output.mi")
        sys.exit(1)

    bin_to_mi(sys.argv[1], sys.argv[2])
