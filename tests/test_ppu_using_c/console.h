
#include <stdint.h>
#include "tilemap.h"
#define __SCREEN____SIZEX__ 320
#define __SCREEN____SIZEY__ 180
uint32_t nes_palette(uint8_t color)
{
    switch (color) {
        case 0x00: return 0xFF7C7C7C;
        case 0x01: return 0xFF0000FC;
        case 0x02: return 0xFF0000BC;
        case 0x03: return 0xFF4428BC;
        case 0x04: return 0xFF940084;
        case 0x05: return 0xFFA80020;
        case 0x06: return 0xFFA81000;
        case 0x07: return 0xFF881400;
        case 0x08: return 0xFF503000;
        case 0x09: return 0xFF007800;
        case 0x0A: return 0xFF006800;
        case 0x0B: return 0xFF005800;
        case 0x0C: return 0xFF004058;
        case 0x0D: return 0xFF000000;
        case 0x0E: return 0xFF000000;
        case 0x0F: return 0xFF000000;

        case 0x10: return 0xFFBCBCBC;
        case 0x11: return 0xFF0078F8;
        case 0x12: return 0xFF0058F8;
        case 0x13: return 0xFF6844FC;
        case 0x14: return 0xFFD800CC;
        case 0x15: return 0xFFE40058;
        case 0x16: return 0xFFF83800;
        case 0x17: return 0xFFE45C10;
        case 0x18: return 0xFFAC7C00;
        case 0x19: return 0xFF00B800;
        case 0x1A: return 0xFF00A800;
        case 0x1B: return 0xFF00A844;
        case 0x1C: return 0xFF008888;
        case 0x1D: return 0xFF000000;
        case 0x1E: return 0xFF000000;
        case 0x1F: return 0xFF000000;

        case 0x20: return 0xFFF8F8F8;
        case 0x21: return 0xFF3CBCFC;
        case 0x22: return 0xFF6888FC;
        case 0x23: return 0xFF9878F8;
        case 0x24: return 0xFFF878F8;
        case 0x25: return 0xFFF85898;
        case 0x26: return 0xFFF87858;
        case 0x27: return 0xFFFCA044;
        case 0x28: return 0xFFF8B800;
        case 0x29: return 0xFFB8F818;
        case 0x2A: return 0xFF58D854;
        case 0x2B: return 0xFF58F898;
        case 0x2C: return 0xFF00E8D8;
        case 0x2D: return 0xFF787878;
        case 0x2E: return 0xFF000000;
        case 0x2F: return 0xFF000000;

        case 0x30: return 0xFFFCFCFC;
        case 0x31: return 0xFFA8E8FC;
        case 0x32: return 0xFFB8B8F8;
        case 0x33: return 0xFFD8B8F8;
        case 0x34: return 0xFFF8B8F8;
        case 0x35: return 0xFFF8A8C0;
        case 0x36: return 0xFFF0D0B0;
        case 0x37: return 0xFFFCE0A8;
        case 0x38: return 0xFFF8D878;
        case 0x39: return 0xFFD8F878;
        case 0x3A: return 0xFFB8F8B8;
        case 0x3B: return 0xFFB8F8D8;
        case 0x3C: return 0xFF00FCFC;
        case 0x3D: return 0xFFD8D8D8;
        case 0x3E: return 0xFF000000;
        case 0x3F: return 0xFF000000;

        default: return 0xFF000000;
    }
}

void ppu_wait_nmi(){
     asm volatile (
        ".insn r 0x2B, 0x1, 0x00, x0, x0, x0"
        :
        : 
        : "memory"
    );
}
void set_backgound(uint32_t sdram_addr,uint32_t color)
{
    uint32_t cmd_type= UINT32_C(0x30000000);//0x3<<28
    uint32_t rs2= nes_palette(color);
    uint32_t rs1=cmd_type|sdram_addr<<7;
    asm volatile (
        ".insn r 0x2B, 0x0, 0x00, x0, %0, %1"
        :
        : "r"(rs1), "r"(rs2)
        : "memory"
    );
}

void copy_sprite_from_sdram_to_buffer(uint32_t sdram_addr, uint32_t n_pixels_to_copy,uint32_t buffer_addr)
{
    uint32_t cmd_type= UINT32_C(0x00000000);//0x3<<28
    uint32_t rs1=cmd_type|(sdram_addr<<7);
    uint32_t rs2=(buffer_addr<<18)| (n_pixels_to_copy<<2);
    asm volatile (
        ".insn r 0x2B, 0x0, 0x00, x0, %0, %1"
        :
        : "r"(rs1), "r"(rs2)
        : "memory"
    );
}

void __render_sprite(uint32_t id,uint32_t sdram_addr,uint32_t width,uint32_t height,int32_t inittial__posix_in_screen, int32_t inittial_posiy_in_screen,uint32_t invert_render_x,uint32_t invert_render_y)
{
    uint32_t cmd_type= UINT32_C(0x20000000);//0x2<<28
    uint32_t rs1=cmd_type|(sdram_addr<<7)|(id<<4)|((width&0x70)>>4);
    uint32_t buffer_addr=0;
    uint32_t rs2=((width&0xf)<<28)|(height<<21)|((((uint32_t)inittial__posix_in_screen)&0x3ff)<<11) |((((uint32_t)inittial_posiy_in_screen)&0x1ff)<<2) | (invert_render_x<<1)|(invert_render_y);
    asm volatile (
        ".insn r 0x2B, 0x0, 0x00, x0, %0, %1"
        :
        : "r"(rs1), "r"(rs2)
        : "memory"
    );
}

void render_sprite(uint32_t id,uint32_t fb_addr_in_sdram,uint32_t width,uint32_t height,int32_t posi_x, int32_t posi_y,uint32_t invert_render_x,uint32_t invert_render_y){
    int32_t sdram_addr=((int32_t)fb_addr_in_sdram) +(posi_y*__SCREEN____SIZEX__)+posi_x;
    //if(sdram_addr<0) sdram_addr=0;
    __render_sprite(id, (uint32_t)sdram_addr, width, height, posi_x, posi_y, invert_render_x, invert_render_y);
}


void load_pallet_from_sdram(uint32_t sdram_addr)
{
    uint32_t cmd_type= UINT32_C(0x10000000);//0x1<<28
    uint32_t rs1=cmd_type|(sdram_addr<<7);
    uint32_t rs2=0;
    asm volatile (
        ".insn r 0x2B, 0x0, 0x00, x0, %0, %1"
        :
        : "r"(rs1), "r"(rs2)
        : "memory"
    );
}
void set_frame_buffer(uint32_t sdram_addr,uint32_t horizontal_offset)
{
    uint32_t rs1=sdram_addr;
    uint32_t rs2=horizontal_offset;
    asm volatile (
        ".insn r 0x2B, 0x0, 0x01, x0, %0, %1"
        :
        : "r"(rs1), "r"(rs2)
        : "memory"
    );
}

void print_tilemap(const char *tilemap[], uint32_t *tile_sprite_to_sdram, uint32_t addr_buffer,int posi_x_init, int posi_y_init, int tilemap_sizex, int tilemap_sizey, int tile_size ){
    int min_indx_to_get=posi_x_init/tile_size;
    int min_indy_to_get=posi_y_init/tile_size;

    int first_x=-(posi_x_init%tile_size);
    int first_y=-(posi_y_init%tile_size);
    int x=first_x;
    int y=first_y;
    int indx=min_indx_to_get;
    int indy=min_indy_to_get;
    uint32_t sprit_addr=0;
    uint32_t last_sprit_addr=0;
    uint32_t print_sprite=0;
    while(y<__SCREEN____SIZEY__){
        while(x<__SCREEN____SIZEX__){
            print_sprite=0;
            int sprite_char=(int)tilemap[indy][indx];
            if(tile_sprite_to_sdram[sprite_char] !=UINT32_MAX) {
                sprit_addr=tile_sprite_to_sdram[sprite_char];
                print_sprite=1;

            }
            if(sprit_addr!=last_sprit_addr){
                load_pallet_from_sdram(sprit_addr-0x100);
                copy_sprite_from_sdram_to_buffer(sprit_addr,tile_size*tile_size,0x0);
            }
            if(print_sprite){        
                render_sprite(2,addr_buffer, tile_size,tile_size,x,y,0,0);
            }
            indx=indx+1;
            x=x+tile_size;
            last_sprit_addr=sprit_addr;
        }
        x=first_x;
        indx=min_indx_to_get;
        indy=indy+1;
        y=y+tile_size;
    }
    
}
