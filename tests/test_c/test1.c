#include <stdint.h>
#include <stdio.h>

#define N 100

/* =========================
   GERADOR LCG
   ========================= */
uint32_t lcg(uint32_t *seed) {
    // Parâmetros clássicos (Numerical Recipes)
    *seed = (*seed * 1664525u + 1013904223u);
    return *seed;
}

/* =========================
   SWAP
   ========================= */
void swap(uint32_t *a, uint32_t *b) {
    uint32_t t = *a;
    *a = *b;
    *b = t;
}

/* =========================
   HEAPIFY (RECURSIVO)
   ========================= */
void heapify(uint32_t arr[], int n, int i) {
    int largest = i;
    int left = 2 * i + 1;
    int right = 2 * i + 2;

    if (left < n && arr[left] > arr[largest])
        largest = left;

    if (right < n && arr[right] > arr[largest])
        largest = right;

    if (largest != i) {
        swap(&arr[i], &arr[largest]);
        heapify(arr, n, largest); // recursivo
    }
}

/* =========================
   HEAP SORT
   ========================= */
void heapSort(uint32_t arr[], int n) {
    // Construir heap
    for (int i = n / 2 - 1; i >= 0; i--) {
        heapify(arr, n, i);
    }

    // Extrair elementos
    for (int i = n - 1; i > 0; i--) {
        swap(&arr[0], &arr[i]);
        heapify(arr, i, 0);
    }
}

/* =========================
   CRC32 (bit a bit, sem tabela)
   ========================= */
uint32_t crc32(uint8_t *data, int len) {
    uint32_t crc = 0xFFFFFFFF;

    for (int i = 0; i < len; i++) {
        crc ^= data[i];
        for (int j = 0; j < 8; j++) {
            if (crc & 1)
                crc = (crc >> 1) ^ 0xEDB88320;
            else
                crc >>= 1;
        }
    }

    return ~crc;
}

/* =========================
   MAIN
   ========================= */
int main() {
    uint32_t arr[N];
    uint32_t seed = 123456789;

    // Inicializar vetor com LCG
    for (int i = 0; i < N; i++) {
        arr[i] = lcg(&seed);
    }

    // Ordenar
    heapSort(arr, N);

    // Calcular CRC do vetor ordenado
    uint32_t crc = crc32((uint8_t*)arr, N * sizeof(uint32_t));

    // Imprimir resultado
    printf("CRC32: 0x%08X\n", crc);

    return 0;
}