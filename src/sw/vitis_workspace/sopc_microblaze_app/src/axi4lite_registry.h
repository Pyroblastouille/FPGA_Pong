#ifndef AXI4LITE_REGISTRY_H
#define AXI4LITE_REGISTRY_H

#include <stdint.h>
#include <stdbool.h>
#include "xparameters.h"

#define REGISTRY_BASE_ADDR (XPAR_AXI4LITE_IF_0_BASEADDR)

#define REGISTER_COLLISION  (0x00)
#define REGISTER_SCREEN     (0x04)
#define REGISTER_BALL       (0x08)
#define REGISTER_PLAYERS    (0x0C)
#define REGISTER_REQUEST    (0x10)

#define REGISTER_JOYSTICK(x)  (0x20 + ((x-1)*0x4))

typedef struct{
    uint16_t x;
    uint16_t y;
} ball_t;

typedef struct{
    uint8_t speed_x;    //4 bits
    uint8_t speed_y;    //4 bits
    bool going_left;
    bool going_right;
    bool going_up;
    bool going_down;
    bool is_colliding;
    bool has_reset;
    bool next_frame_ready;
    bool is_loading;
    bool collide_wall_up;
    bool collide_wall_down;
    bool collide_wall_left;
    bool collide_wall_right;
    bool collide_p1_far_up;
    bool collide_p1_up;
    bool collide_p1_middle;
    bool collide_p1_down;
    bool collide_p1_far_down;
    bool collide_p2_far_up;
    bool collide_p2_up;
    bool collide_p2_middle;
    bool collide_p2_down;
    bool collide_p2_far_down;
} state_collision_t;

typedef struct{
    uint16_t width;
    uint16_t height;
}screen_t;
typedef struct{
    uint16_t p1_y;
    uint16_t p2_y;
}players_t;
typedef struct{
    bool reset;
    bool next_frame_request;
    bool enable;
} request_t;

typedef struct{
    int8_t val_x;
    int8_t val_y;
    bool trigger_pressed;
    bool joystick_pressed;
}joystick_t;



//Module BallPhysicsEngine
state_collision_t reg_read_state_collision();
ball_t reg_read_ball();
void reg_write_screen(screen_t* screen);
void reg_write_players(players_t* players);
void reg_write_request(request_t* request);

//Module JoystickGrabber
joystick_t reg_read_joystick(bool read_p1);






#endif