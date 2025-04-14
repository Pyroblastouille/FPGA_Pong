#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>

#include "xparameters.h"
#include "xbram.h"
#include "sleep.h"

#include <stdio.h>
#include <xil_types.h>
#include <xstatus.h>

#include "axi4lite_registry.h"

#define WIDTH               (640)
#define HEIGHT              (480)
#define PIXEL_BRAM_ADDR     (XPAR_AXI_BRAM_CTRL_0_BASEADDR)

void WriteWave(uint8_t* dest,int offset){
    *dest = offset & 0xff;
}


int main(){

    /**
        Initialize Registers 
    **/
    screen_t screen;
    screen.width = WIDTH;
    screen.height = HEIGHT;
    reg_write_screen(&screen);
    request_t request;
    request.enable = true;
    request.next_frame_request = true;
    request.reset = true;
    reg_write_request(&request);

    /**
        Initialize BRAM 
    **/
    XBram bram; 
    bram.Config = *XBram_LookupConfig(PIXEL_BRAM_ADDR);
    if(XBram_CfgInitialize(&bram,&bram.Config,PIXEL_BRAM_ADDR) != XST_SUCCESS){
        return XST_FAILURE;
    }
    if(XBram_SelfTest(&bram, 0) != XST_SUCCESS){
        return XST_FAILURE;
    }
    
    while(!bram.IsReady){
        sleep(1);
    }
    
    /**
        Program 
    **/
    ball_t ball;
    state_collision_t state_collision;
    while(1){
        state_collision = reg_read_state_collision();
        ball = reg_read_ball();

        uint32_t* two_pixel = (uint32_t*)bram.Config.BaseAddress;
        for (int y = 0; y < HEIGHT; y++) {
            for (int x = 0; x < WIDTH; x+=8) {
                if(ball.y == y && (ball.x >= x && ball.x <= x+8)){
                    *two_pixel = 0x00000000;
                }else{
                    *two_pixel = 0xffffffff;
                }
                two_pixel++;
            }
        }
        sleep(1);

        
        request.next_frame_request = true;
        request.enable = true;
        request.reset = false;
        reg_write_request(&request);
    }
    return 0;
}