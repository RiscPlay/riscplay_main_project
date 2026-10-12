#ifndef  ___TILEMAP___
#define  ___TILEMAP___
#include <stdint.h>
#define  ___TILE_SIZE__ 9
#define  ___TILEMAP_SIZEX__ 120
#define  ___TILEMAP_SIZEX_PLUS_1__ ___TILEMAP_SIZEX__+1
#define  ___TILEMAP_SIZEY__ 20 //180/9=20 180 size_y display

static const char *__tilemap__[] = {
   "##                                                                                                                      ",
   "# #                                                                                                                     ",
   "#  #                                                                                                                    ",
   "#   #                                                                                                                   ",
   "#    #                                                                                                                  ",
   "#     ##                                                                                                                ",
   "#      ###                                                                                                              ",
   "#        ##                                                                                                             ",
   "#         ##                                                                                                            ",
   "#          #                                                                                                            ",
  "#           #                                                                                                           ",
  "#            #                                                                                                          ",
  "#            #                                                                                                          ",
  "#             #                                                                                                         ",
  "#              #                                                                                                        ",
  "#               #  aaaa                                                                                                 ",
  "#               ## aaaa                                                                                                 ",
  "#                ##aaaa                                                                                                 ",
  "#                 ##                                                                                                    ",
  "#                  #                                                                                                    ",
  "#                  ##                                                                                                   ",
  "#                   ##                                                                                                  ",
  "#                    #                                                                                                  ",
  "#                    ##                                    ##                       aaaaa                               ",
  "#                     #                               ########    aaa               aaa                                 ",
  "#                     ##                            ###      ####a  aaaaaaaaaaaaaa  aaaaaaaaa     aa           aaaaaaaaa",
  "#                      #                          ##                             aaaaaaaaaaaa  aaaaaaaaaaaaaaaaaa  aa   ",
  "#                      ##                      ###                                   aaa  aa          aa     a          ",
  "#                       #                    ###                                                                        ",
  "#                        #                 ###                                                                          ",
  "#                         ##               #                                                                            ",
  "#                          ##             ##                                                                            ",
  "#                           ##          ###                                                                             ",
  "#                             #       ###                                                                               ",
  "#                              #     ##                                                                                 ",
  "#                               #   #                                                                                   ",
  "#                                ###                                                                                    ",
  "#                                                                                                                       ",
  "#                                                                                                                       ",
  "#                                                                                                                       "
};

void define_tile_addrs(uint32_t *tile_sprite_to_sdram){
  for(int i=0;i<128;i++){
    tile_sprite_to_sdram[i]=UINT32_MAX;
  }
  tile_sprite_to_sdram['#']=0xe4100;
  tile_sprite_to_sdram['a']=0xe3100;

}
void define_tile_sprites_ids(uint32_t *tile_sprits_ids){
  for(int i=0;i<128;i++){
    tile_sprits_ids[i]=0;
  }
  tile_sprits_ids['#']=3;
  tile_sprits_ids['a']=3;

}
#endif