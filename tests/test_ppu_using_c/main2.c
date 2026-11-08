#include "console.h"
int main(void){
    int buffer=0;
    int buffer_next=0;
    int background=3;
    load_pallet_from_sdram(0xe1000);
    copy_sprite_from_sdram_to_buffer(0x0e1100,4096,0x0);
    int posix=0;
    int inc=1;
    int addr_buffer[2];
    addr_buffer[0] = 0xa080;//((320*128)+128)
    addr_buffer[1] = 0x18180;//((320*128)+128)+(320*180)
    set_backgound(addr_buffer[1],4);
    set_frame_buffer(addr_buffer[1],0);
    while(1){
        set_backgound(addr_buffer[buffer],0);
       
        load_pallet_from_sdram(0xE1000);
        copy_sprite_from_sdram_to_buffer(0xE1100,64*64,0x0);
        for (int i=0;i<32;i++){
            render_sprite(0,addr_buffer[buffer], 64,64,posix,1,0,0);
        }
        ppu_finished_all_operations();
        set_frame_buffer(addr_buffer[buffer],0);

        //set_frame_buffer(addr_buffer[buffer_next],0);
        buffer=buffer+1;
        if(buffer>1) buffer=0;

        if(posix==320)
            inc=-1;
        else if(posix==0)
            inc=1;
        
        posix=posix+inc;
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