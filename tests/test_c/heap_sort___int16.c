
#include <stdint.h>
#ifdef __linux__
#include <stdio.h>
#endif


#include <stdint.h>

void swap(int16_t *a, int16_t *b)
{
    int16_t t = *a;
    *a = *b;
    *b = t;
}

/* corrige heap descendo recursivamente */
void heapify(int16_t v[], int n, int i)
{
    int maior = i;
    int e = 2*i + 1;
    int d = 2*i + 2;

    if (e < n && v[e] > v[maior])
        maior = e;

    if (d < n && v[d] > v[maior])
        maior = d;

    if (maior != i) {
        swap(&v[i], &v[maior]);
        heapify(v, n, maior);
    }
}

/* constrói heap recursivamente */
void buildHeap(int16_t v[], int n, int i)
{
    if (i < 0)
        return;

    heapify(v, n, i);
    buildHeap(v, n, i - 1);
}

/* ordena recursivamente */
void heapSortRec(int16_t v[], int n)
{
    if (n <= 1)
        return;

    swap(&v[0], &v[n - 1]);
    heapify(v, n - 1, 0);
    heapSortRec(v, n - 1);
}

void heapSort(int16_t v[], int n)
{
    buildHeap(v, n, (n / 2) - 1);
    heapSortRec(v, n);
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

// Estado do PRNG
typedef struct {
    uint32_t v0;
    uint32_t v1;
    uint32_t key[4];
} XTEA_PRNG;

// Inicializa com seed
void xtea_init(XTEA_PRNG *rng, uint32_t seed) {
    rng->v0 = seed;
    rng->v1 = seed ^ 0x9E3779B9;

    rng->key[0] = seed;
    rng->key[1] = seed ^ 0xA5A5A5A5;
    rng->key[2] = seed ^ 0x3C6EF372;
    rng->key[3] = seed ^ 0xC6EF3720;
}

// Gera próximo bloco pseudoaleatório
void xtea_encrypt(uint32_t *v0, uint32_t *v1, uint32_t key[4]) {
    uint32_t sum = 0;
    uint32_t delta = 0x9E3779B9;

    for (int i = 0; i < 32; i++) {
        *v0 += (((*v1 << 4) ^ (*v1 >> 5)) + *v1) ^ (sum + key[sum & 3]);
        sum += delta;
        *v1 += (((*v0 << 4) ^ (*v0 >> 5)) + *v0) ^ (sum + key[(sum >> 11) & 3]);
    }
}

// Retorna uint32_t pseudoaleatório
uint32_t xtea_rand(XTEA_PRNG *rng) {
    xtea_encrypt(&rng->v0, &rng->v1, rng->key);
    return rng->v0 ^ rng->v1;
}

// Retorna número entre min e max
uint32_t xtea_rand_range(XTEA_PRNG *rng, uint32_t min, uint32_t max) {
    return min + (xtea_rand(rng) % (max - min + 1));
}

#define N_ARR 128


int main() {
    int16_t  arr[N_ARR];
    XTEA_PRNG rng;

    xtea_init(&rng, 123456789);
    for (int i = 0; i < N_ARR; i++) {
        arr[i]=(int16_t)xtea_rand(&rng);
    }
    #ifdef __riscv
    for(int i=0;i<N_ARR;i++){
        volatile int16_t *p0 = (volatile int16_t*)(0x80002000+(i*2));
        *p0=arr[i];
    }
    #endif
    heapSort(arr, N_ARR);
    uint32_t crc = crc32((uint8_t *)arr, N_ARR*2);
    //uint32_t crc=UINT32_C(0xfafb);
    #ifdef __linux__
    for (int i = 0; i < N_ARR; i++) { 
    	printf("%d\n", arr[i]);
    }
    printf("CRC32: 0x%08X\n", crc);
    #endif
    #ifdef __riscv
    for(int i=0;i<N_ARR;i++){
        volatile int16_t *p1 = (volatile int16_t*)(0x80002400+(i*2));
        *p1=arr[i];
    }
    #endif
    

    #ifdef __riscv
    volatile uint32_t *p2 = (volatile uint32_t*)0x00000104;
    *p2=crc;
    #endif

    if(crc!=UINT32_C(0x1999FBD4)){
        #ifdef __riscv
        volatile uint32_t *p3 = (volatile uint32_t*)0x00000100;//to read use uint32_t value = *(volatile uint32_t*)0x00000110;
        *p3=0xf;
        #endif 
    }
    else{
        #ifdef __riscv
        volatile uint32_t *p4 = (volatile uint32_t*)0x00000100;//to read use uint32_t value = *(volatile uint32_t*)0x00000110;
        *p4=0xfa;
        #endif 
    }

    while(1);
    return 0;
}