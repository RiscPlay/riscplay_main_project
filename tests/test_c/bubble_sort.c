#include <stdint.h>
#ifdef __linux__
#include <stdio.h>
#endif



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


void bubble_sort(uint8_t arr[], int n) {
    for(int i=0;i<n;i++){
        for(int j=0;j<(n-1);j++){
             if(arr[j]>arr[j+1]){
                  uint8_t temp=arr[j];
                  arr[j]=arr[j+1];
                  arr[j+1]=temp;
             }
        }
    }
}

int main() {
    uint8_t arr[] = {5, 3, 8, 2, 9};
    int n = 5;

    bubble_sort(arr, n);
    uint32_t crc = crc32(arr, n);
    //uint32_t crc=UINT32_C(0xfafb);
    #ifdef __linux__
    printf("CRC32: 0x%08X\n", crc);
    #endif

    if(arr[0]==2 && arr[1]==3 && arr[2]==5 && arr[3]==8 && arr[4]==9){
        #ifdef __riscv
        volatile uint32_t *p0 = (volatile uint32_t*)0x00000108;
        *p0=UINT32_C(0x11);
        #endif
        #ifdef __linux__
        printf("ok\n");
        #endif
    }
    else {
        #ifdef __riscv
        volatile uint32_t *p1 = (volatile uint32_t*)0x00000108;
        *p1=UINT32_C(0x45);
        #endif
        #ifdef __linux__
        printf("error\n");
        #endif
    }

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
