#include "console.h"
#include <stdint.h>
int main(void){
    volatile uint32_t *ps2_controller_ptr = (volatile uint32_t *)0x0000000c;

    int buffer=0;
   
    int background=3;
    
    
    int posix=0;
    int inc=1;
    int addr_buffer[4];
    addr_buffer[0] =0x38400;
    addr_buffer[1] = 0x70800;
    addr_buffer[2] = 0xa8c00;
    addr_buffer[3] = 0;
    //copy_sprite_from_sdram_to_buffer(0x0e1100,4096,0x0);
    //load_pallet_from_sdram(0xe1000);
    load_pallet_from_sdram(0xe2000);

    ppu_wait_nmi();

    
    set_sprite_wiwdh(64);
    while(1){
        set_backgound(addr_buffer[buffer],0); 
        for(int i=0;i<4;i++) copy_sprite_from_sdram_to_buffer(0x0e1100,4096,0x0);
        for(int i=0;i<5;i++) load_pallet_from_sdram(0xe1000);
        
        render_sprite(((320*(30))+posix+(1*80))+addr_buffer[buffer], 64,64,0,0);
        
        for(int i=0;i<1;i++) render_sprite(((320*(30))+posix+(2*80))+addr_buffer[buffer], 64,64,1,0);
        
        copy_sprite_from_sdram_to_buffer(0x0e2100,40*40,0x0);
        load_pallet_from_sdram(0xe2000);

        render_sprite(((320*(30))+posix+(3*80))+addr_buffer[buffer], 40,40,0,1);
        
        ppu_wait_nmi();
        set_frame_buffer(addr_buffer[buffer],0);

        buffer++;
        if(buffer==2) buffer=0;

        uint32_t ps2_controller = *ps2_controller_ptr;
        

        if(((ps2_controller>>16)&UINT32_C(0xff))==0x7f)
             posix=posix-1;
        //else if(((ps2_controller>>16)&UINT32_C(0xff))==0xdf)
             //posix=posix+1;
        
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