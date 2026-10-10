///   https://stmn.itch.io/ascii-map-editor
///   https://github.com/stmn/ascii-map-editor?utm_source=chatgpt.com
#include "console.h"
#include <stdint.h>
#include "tilemap.h"
#define __MIN_ADDR_IN_SDRAM_TO_LOAD_SPRITES__ 0x26280 //((320*128)+128)+((320*180)*2)
int main(void){
    uint32_t tile_sprite_to_sdram[128];
    define_tile_addr(tile_sprite_to_sdram);

    volatile uint32_t *ps2_controller_ptr = (volatile uint32_t *)0x0000000c;
    
    int buffer=0;
   
    int background=3;
    
    
    int posix=0;
    int posiy=0;
    int inc=1;
    int addr_buffer[4];
    addr_buffer[0] = 0xa080;//((320*128)+128)
    addr_buffer[1] = 0x18180;//((320*128)+128)+(320*180)

    //copy_sprite_from_sdram_to_buffer(0x0e1100,4096,0x0);
    //load_pallet_from_sdram(0xe1000);
    load_pallet_from_sdram(0xe2000);

    ppu_wait_nmi();

    
    
    while(1){
        set_backgound(addr_buffer[buffer],0);
        print_tilemap(__tilemap__,tile_sprite_to_sdram,addr_buffer[buffer],posix, 0, ___TILEMAP_SIZEX__, ___TILEMAP_SIZEY__, ___TILE_SIZE__ ); 
        for(int i=0;i<4;i++) copy_sprite_from_sdram_to_buffer(0x0e1100,4096,0x0);
        for(int i=0;i<5;i++) load_pallet_from_sdram(0xe1000);
        
        //render_sprite(0,((320*(30))+posix+(1*80))+addr_buffer[buffer], 64,64,posix+80,30,0,0);
        
        //for(int i=0;i<1;i++) render_sprite(1,((320*(30+posiy))+posix+(2*80))+addr_buffer[buffer], 64,64,posix+2*(80),30+posiy,1,0);
        
        copy_sprite_from_sdram_to_buffer(0x0e2100,40*40,0x0);
        load_pallet_from_sdram(0xe2000);

        render_sprite(2,addr_buffer[buffer], 40,40,0,0,0,1);
        

        load_pallet_from_sdram(0xe4000);
        copy_sprite_from_sdram_to_buffer(0xe4100,81,0x0);
        render_sprite(5,addr_buffer[buffer], 9,9,300,100,0,0);
        
        ppu_wait_nmi();
        set_frame_buffer(addr_buffer[buffer],0);

        buffer++;
        if(buffer==2) buffer=0;

        uint32_t ps2_controller = *ps2_controller_ptr;
        

        //if(((ps2_controller>>16)&UINT32_C(0xff))==0x7f)
        posix=posix+1;
        //posiy=posiy+1;
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