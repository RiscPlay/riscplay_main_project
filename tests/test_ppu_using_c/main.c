#include "console.h"
#include <stdint.h>
int main(void){
    volatile uint32_t *ps2_controller_ptr = (volatile uint32_t *)0x0000000c;

    int buffer=0;
    int buffer_next=1;
    int background=3;
    
    
    int posix=0;
    int inc=1;
    int addr_buffer[2];
    addr_buffer[0]=0;
    addr_buffer[1] = 0x70800;


    copy_sprite_from_sdram_to_buffer(0x0e1100,4096,0x0);
    load_pallet_from_sdram(0xe1000);
    //ppu_wait_nmi();

    
    
    while(1){
        set_backgound(addr_buffer[buffer_next],0); 
        for(int j=0;j<64;j++){

            for(int i=0;i<64;i++){
                for(int k=0;k<1;k++) render_sprite(((640*(i+30))+posix+(j*80))+addr_buffer[buffer_next], 64,i*64,0);
            }
        }
        for(int i=0;i<64;i++){
            for(int k=0;k<1;k++) render_sprite(((640*(i+120))+posix+(1*80))+addr_buffer[buffer_next], 64,i*64,0);
        }
        
        ppu_wait_nmi();
        set_frame_buffer(addr_buffer[buffer_next],0);
        buffer=(buffer+1)&1;
        buffer_next=(buffer_next+1)&1;
        uint32_t ps2_controller = *ps2_controller_ptr;
        

        //if(((ps2_controller>>16)&UINT32_C(0xff))==0x7f)
        //     posix=posix-1;
        //else if(((ps2_controller>>16)&UINT32_C(0xff))==0xdf)
             posix=posix+1;
        
        /*** 
        if(background==1){
            background=0x38;
        }
        else{
            background=1;
        }
            ***/
    }
    return 0;
}