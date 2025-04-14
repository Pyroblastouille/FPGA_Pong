
#include "axi4lite_registry.h"

//Module BallPhysicsEngine
state_collision_t reg_read_state_collision(){
    state_collision_t state_collision;
    uint32_t reg = *((uint32_t*)(REGISTRY_BASE_ADDR+REGISTER_COLLISION));
    state_collision.speed_x             = reg           & 0xf;
    state_collision.speed_y             = (reg >> 4)    & 0xf;
    state_collision.going_left          = (reg >> 8)    & 0x1;
    state_collision.going_right         = (reg >> 9)    & 0x1;
    state_collision.going_up            = (reg >> 10)   & 0x1;
    state_collision.going_down          = (reg >> 11)   & 0x1;
    state_collision.is_colliding        = (reg >> 12)   & 0x1;
    state_collision.has_reset           = (reg >> 13)   & 0x1;
    state_collision.next_frame_ready    = (reg >> 14)   & 0x1;
    state_collision.is_loading          = (reg >> 15)   & 0x1;
    state_collision.collide_wall_up     = (reg >> 16)   & 0x1;
    state_collision.collide_wall_down   = (reg >> 17)   & 0x1;
    state_collision.collide_wall_left   = (reg >> 18)   & 0x1;
    state_collision.collide_wall_right  = (reg >> 19)   & 0x1;
    state_collision.collide_p1_far_up   = (reg >> 20)   & 0x1;
    state_collision.collide_p1_up       = (reg >> 21)   & 0x1;
    state_collision.collide_p1_middle   = (reg >> 22)   & 0x1;
    state_collision.collide_p1_down     = (reg >> 23)   & 0x1;
    state_collision.collide_p1_far_down = (reg >> 24)   & 0x1;
    state_collision.collide_p2_far_up   = (reg >> 25)   & 0x1;
    state_collision.collide_p2_up       = (reg >> 26)   & 0x1;
    state_collision.collide_p2_middle   = (reg >> 27)   & 0x1;
    state_collision.collide_p2_down     = (reg >> 28)   & 0x1;
    state_collision.collide_p2_far_down = (reg >> 29)   & 0x1;

    return state_collision;
}
ball_t reg_read_ball(){
    ball_t ball;
    uint32_t reg = *((uint32_t*)(REGISTRY_BASE_ADDR+REGISTER_BALL));
    ball.x = reg & 0xff;
    ball.y = (reg >> 16) & 0xff;
    return ball;
}
void reg_write_screen(screen_t* screen){

    uint32_t reg = ((uint32_t)screen->height << 16) + (uint32_t)screen->width;
    *((uint32_t*)(REGISTRY_BASE_ADDR+REGISTER_SCREEN)) = reg;

}
void reg_write_players(players_t* players){
    uint32_t reg = ((uint32_t)players->p2_y << 16) + (uint32_t)players->p1_y;
    *((uint32_t*)(REGISTRY_BASE_ADDR+REGISTER_PLAYERS)) = reg;
}
void reg_write_request(request_t* request){
    uint32_t reg = 
        (uint32_t)request->reset + 
        ((uint32_t)request->next_frame_request << 1) + 
        ((uint32_t)request->enable << 2);
    
    *((uint32_t*)(REGISTRY_BASE_ADDR+REGISTER_REQUEST)) = reg;
}

//Module JoystickGrabber
joystick_t reg_read_joystick(bool read_p1){
    uint32_t reg;
    if(read_p1){
        reg = *((uint32_t*)(REGISTRY_BASE_ADDR+REGISTER_JOYSTICK(1)));
    }else{
        reg = *((uint32_t*)(REGISTRY_BASE_ADDR+REGISTER_JOYSTICK(2)));
    }
    joystick_t joystick;
    joystick.val_x = reg & 0xff;
    joystick.val_y = (reg >> 8) & 0xff;
    joystick.trigger_pressed = (reg >> 16) & 0x1;
    joystick.joystick_pressed = (reg >> 17) & 0x1;
}