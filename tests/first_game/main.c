///   https://stmn.itch.io/ascii-map-editor
///   https://github.com/stmn/ascii-map-editor?utm_source=chatgpt.com
#include "console.h"
#include <stdint.h>
#include "tilemap.h"
#define __MIN_ADDR_IN_SDRAM_TO_LOAD_SPRITES__ 0x26280 //((320*128)+128)+((320*180)*2)
int main(void){
    uint32_t tile_sprite_to_sdram[128];
    uint32_t tile_sprites_ids[128];

    define_tile_addrs(tile_sprite_to_sdram);
    define_tile_sprites_ids(tile_sprites_ids);
    
    int buffer=0;
   
    
    int inv_posix_inc=0;
    int posix=0;
    int posiy=0;
    int inc=1;
    int addr_buffer[2];
    addr_buffer[0] = 0xa080;//((320*128)+128)
    addr_buffer[1] = 0x18180;//((320*128)+128)+(320*180)

    int32_t time_when_collision_happen=-1;
    clear_collision();
    ppu_finished_all_operations();
    int32_t frames=0;
    while(1){
        set_backgound(addr_buffer[buffer],0x0E);
        print_tilemap(__tilemap__,tile_sprite_to_sdram,tile_sprites_ids,addr_buffer[buffer],posix, 10, ___TILEMAP_SIZEX__, ___TILEMAP_SIZEY__, ___TILE_SIZE__ ); 
        
        //copy_sprite_from_sdram_to_buffer(0x50100,28*28,0x0); 
        //load_pallet_from_sdram(0x50000);
        //render_sprite(0,addr_buffer[buffer], 28,28,100,30,0,0);
        load_pallet_from_sdram(0xA0000);
        copy_sprite_from_sdram_to_buffer(0xA0100,16*12,0x0);
        render_sprite(0,addr_buffer[buffer], 16,12,100,100,0,0);
        
        ppu_finished_all_operations();
        /*
        if(time_when_collision_happen>0 && ((int32_t)get_time()- time_when_collision_happen)> INT32_C(50) ){
            time_when_collision_happen=-1;
            ppu_finished_all_operations();

        }
        if(time_when_collision_happen==-1){
            if(check_collision(0,1)){
                time_when_collision_happen=get_time();
                if(inv_posix_inc==0)inv_posix_inc=1;
                else inv_posix_inc=0;
            }
        }
        */
        clear_collision();

        frames++;
        ppu_finished_all_operations();
        set_frame_buffer(addr_buffer[buffer],0);
        posix=posix+1;
        if(posix>100)
            posix=0;
        buffer++;
        if(buffer==2) buffer=0;

        

        //if(((get_ps2_controller_state()>>16)&UINT32_C(0xff))==0x7f)
        //posiy=posiy+1;
        //else if(((get_ps2_controller_state()>>16)&UINT32_C(0xff))==0xdf)
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