#ifndef  ___TILEMAP___
#define  ___TILEMAP___
#include <stdint.h>
#define  ___TILE_SIZE__ 9
#define  ___TILEMAP_SIZEX__ 120
#define  ___TILEMAP_SIZEX_PLUS_1__ 121
#define  ___TILEMAP_SIZEY__ 40

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

void define_tile_addr(uint32_t *tile_sprite_to_sdram){
  for(int i=0;i<128;i++){
    tile_sprite_to_sdram[i]=UINT32_MAX;
  }
  tile_sprite_to_sdram['#']=0xe4100;
  tile_sprite_to_sdram['a']=0xe3100;

}

#endif