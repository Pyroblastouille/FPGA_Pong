#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include "xparameters.h"
#include "sleep.h"

#define WIDTH   (640)
#define HEIGHT  (480)
#define PIXEL_BRAM_ADDR (0x40000000)
#define REGISTER_BASE_ADDR  (0x80000000)
#define REGISTER_COLLISION  (0x00)
#define REGISTER_SCREEN     (0x04)
#define REGISTER_BALL       (0x08)
#define REGISTER_PLAYERS    (0x0C)
#define REGISTER_REQUEST    (0x10)

void WriteWave(uint8_t* dest,int offset){
    *dest = offset & 0xff;
}


#define RB_IS_COLLIDE (RB_STATE_COLLISION&(1<<12))
#define RB_BALL (*((uint32_t*)))

#define RB_BALL_X ((uint16_t)(RB_BALL&0xff))
#define RB_BALL_Y ((uint16_t)((RB_BALL>>16)&0xff))


#define REQUEST_NEW_FRAME do{*(((uint32_t*)(REGISTER_BASE_ADDR+REGISTER_ENABLE)) = 0b110;}while(0)
#define REGISTER_SCREEN_SIZE(width,height) do{*((uint32_t*)(REGISTER_BASE_ADDR+REGISTER_SCREEN)) = (width + (height << 16));}while(0)
#define REGISTER_ENABLE do{*((uint32_t*)(REGISTER_BASE_ADDR+REGISTER_ENABLE)) = 0b100;}while(0)

int main(){
    uint32_t* values = (uint32_t*)REGISTER_BASE_ADDR;

    REGISTER_SCREEN_SIZE(WIDTH, HEIGHT);

    uint32_t* pixels = (uint32_t*)PIXEL_BRAM_ADDR;

    
    while(1){
        uint32_t* two_pixel = pixels;

        uint16_t x_id = RB_BALL_X;
        uint16_t y_id = RB_BALL_Y;

        for (int y = 0; y < HEIGHT; y++) {
            for (int x = 0; x < WIDTH; x+=8) {
                if(y_id == y && (x_id >= x && x_id <= x+8)){
                    *two_pixel = 0x00000000;
                }else{
                    *two_pixel = 0xffffffff;
                }
                two_pixel++;
            }
        }
        sleep(1);
        REQUEST_NEW_FRAME;


    }
    return 0;
}