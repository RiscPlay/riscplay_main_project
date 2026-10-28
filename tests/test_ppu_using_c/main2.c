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
    addr_buffer[0]=0;
    addr_buffer[1] = 0x7a900;
    set_backgound(addr_buffer[0],1);
    set_backgound(addr_buffer[1],4);
    set_frame_buffer(addr_buffer[0],0);

    while(1){
        //set_backgound(addr_buffer[0],buffer);
        set_frame_buffer(addr_buffer[buffer],0);

        ppu_wait_nmi();
        //set_frame_buffer(addr_buffer[buffer_next],0);
        buffer=(buffer+1)&1;
        buffer_next=(buffer_next+1)&1;

        for(int i=0;i<2000000;i++);
        if(posix==200)
            inc=0;
        else if(posix==0)
            inc=1;
        if(inc)
            posix=posix+1;
        else 
            posix=posix-1;
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