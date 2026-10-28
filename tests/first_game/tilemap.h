#ifndef  ___TILEMAP___
#define  ___TILEMAP___
#include <stdint.h>
#define  ___TILE_SIZE__ 28
#define  ___TILEMAP_SIZEX__ 37
#define  ___TILEMAP_SIZEX_PLUS_1__ ___TILEMAP_SIZEX__+1
#define  ___TILEMAP_SIZEY__ 7

static const char *__tilemap__[] = {
  "aaaaaaaaaeaaaaaaagaaaagaaaaaaaaaaeaaa",
  "aaaaaaaaaeaaaaaaagaaaagaaaaaaaaaaeaaa",
  "aaaaaaaaaeaaaaaaagaaaagaaaaaaaaaaeaaa",
  "aaaaaaaaaaaaaaaaaeaaaaeaaaaaaaaaaaaaa",
  "bbbbbbbbbfbbbbbbbbbbbbbbbbbbbbbbbfbbb",
  "cccccccccgcccccccfccccfccccccccccgccc",
  "ddddddddddddddddddddddddddddddddddddd"
};

void define_tile_addrs(uint32_t *tile_sprite_to_sdram){
  for(int i=0;i<128;i++){
    tile_sprite_to_sdram[i]=UINT32_MAX;
  }
  //tile_sprite_to_sdram['a']=0xe0100;
  tile_sprite_to_sdram['b']=0x40100;
  tile_sprite_to_sdram['c']=0x50100;  
  tile_sprite_to_sdram['d']=0x60100; 
  tile_sprite_to_sdram['e']=0x70100; 
  tile_sprite_to_sdram['f']=0x80100; 
  tile_sprite_to_sdram['g']=0x90100;  
  //tile_sprite_to_sdram['p']=0x0a0000;  

}
void define_tile_sprites_ids(uint32_t *tile_sprits_ids){
  for(int i=0;i<128;i++){
    tile_sprits_ids[i]=0;
  }
  //tile_sprits_ids['p']=2;
  tile_sprits_ids['e']=1;
  tile_sprits_ids['f']=1;
  tile_sprits_ids['g']=1;

}
#endif