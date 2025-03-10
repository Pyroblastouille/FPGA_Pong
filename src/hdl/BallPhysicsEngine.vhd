----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/03/2025 01:26:02 PM
-- Design Name: 
-- Module Name: BallPhysicsEngine - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BallPhysicsEngine is
    generic(
        Player_height   : integer := 10;    -- Player height in pixels
        Player_width    : integer := 5;     -- Player width in pixels
        Player_x_padding: integer := 2;     -- Number of pixel of padding between the player and its wall
        Ball_height     : integer := 5;     -- Ball height in pixels
        Ball_width      : integer := 5;     -- Ball width in pixels
        Ball_max_speed  : integer := 17     -- Max ball speed
    );  
    port(
        clk             : in std_logic;  -- Input Clock
        reset           : in std_logic;  -- Reset
        
        -- AXI4-Lite Registres
        State_Col_reg   : inout std_logic_vector(31 downto 0);  -- 0x0 (Speed/Direction/Collision/Reset/NFR/Enable/Collision with ?)
        Screen_reg      : in    std_logic_vector(31 downto 0);  -- 0x4 (Width/Height of screen)
        Ball_reg        : out   std_logic_vector(31 downto 0);  -- 0x8 (X/Y of the ball)
        Players_reg     : in    std_logic_vector(31 downto 0)   -- 0x12 (P1 and P2 Y coordinate)
    );
end BallPhysicsEngine;

architecture Behavioral of BallPhysicsEngine is
    -- Define State Machine
    type state_type is (IDLE, UPDATE_POS, CHECK_COLLISION, WRITE_BACK);
    signal Current_state, Next_state : state_type;
    
    -- Internal signals for computation
    signal Ball_reg_sig : std_logic_vector(31 downto 0) := (others => '0');  -- Intermediate signal for Ball_reg
    signal State_Col_reg_sig : std_logic_vector(31 downto 0) := (others => '0'); -- Intermediate signal for State_Col_reg
    
begin
    process(clk, reset, State_Col_reg(13), State_Col_reg(15))
    variable Screen_width  : integer;
    variable Screen_height : integer;
    variable Ball_center_x : integer;
    variable Ball_center_y : integer;
    begin
        if rising_edge(clk) and State_Col_reg(15) = '1' then -- Enable
            Current_state <= Next_state;
        end if;
    end process;

    process(Current_state, State_Col_reg(14), reset, State_Col_reg(13))
    constant Half_Ball_Width        : integer   := Ball_width / 2;
    constant Half_Ball_Height       : integer   := Ball_height / 2;
    constant Half_Player_Height     : integer   := Player_height / 2;
    constant Fifth_Player_Height    : integer   := Player_height / 5;
    variable Collide                : std_logic;
    variable Collide_what           : std_logic_vector(13 downto 0);
    variable Screen_width           : integer;
    variable Screen_height          : integer;
    variable Ball_center_x          : integer;
    variable Ball_center_y          : integer;
    variable Ball_x, Ball_y           : std_logic_vector(15 downto 0);
    variable Direction_x, Direction_y : std_logic;
    variable Speed_x, Speed_y         : integer;
    begin
        if reset = '1' or State_Col_reg(13) = '1' then
            Next_state <= IDLE;
            
            -- Convert screen size from std_logic_vector to integer
            Screen_width  := to_integer(unsigned(Screen_reg(15 downto 0)));
            Screen_height := to_integer(unsigned(Screen_reg(31 downto 16)));
            
            -- Compute ball center dynamically
            Ball_center_x := (Screen_width - Ball_width) / 2;
            Ball_center_y := (Screen_height - Ball_height) / 2;
            
            -- Convert back to std_logic_vector
            Ball_x := std_logic_vector(to_unsigned(Ball_center_x, 16));
            Ball_y := std_logic_vector(to_unsigned(Ball_center_y, 16));
            Ball_reg_sig <= Ball_x & Ball_y;
            
            Direction_x := '1';                     -- Ball will go left
            Direction_y := '0';                     -- Ball will go down
            
            State_Col_reg_sig <= "00000000000000000000101001010101";    -- Clear Reset, Collision, Direction and NFR
        else
            case Current_state is
                when IDLE =>
                    if State_Col_reg(14) = '1' then -- NFR
                        Next_state <= UPDATE_POS;
                    else
                        Next_state <= IDLE;
                    end if;
    
                when UPDATE_POS =>
                    -- Update Ball Position
                    if Direction_x = '1' then
                        Ball_x := std_logic_vector(to_unsigned(to_integer(unsigned(Ball_x)) + Speed_x, 16));
                    else
                        Ball_x := std_logic_vector(to_unsigned(to_integer(unsigned(Ball_x)) - Speed_x, 16));
                    end if;
                    
                    if Direction_y = '1' then
                        Ball_y := std_logic_vector(to_unsigned(to_integer(unsigned(Ball_y)) + Speed_y, 16));
                    else
                        Ball_y := std_logic_vector(to_unsigned(to_integer(unsigned(Ball_y)) - Speed_y, 16));
                    end if;
                    Next_state <= CHECK_COLLISION;
    
                when CHECK_COLLISION =>
                
                    Collide := '0';
                    Collide_what := "00000000000000"; 
                    
                    -- Detect Wall Collision
                    -- Left Wall
                    if to_integer(unsigned(Ball_x)) <= Half_Ball_Width then
                        Direction_x := not Direction_x;
                        Collide := '1';
                        Collide_what(11) := '1';
                    
                    -- Right Wall
                    elsif to_integer(unsigned(Ball_x)) >= (to_integer(unsigned(screen_reg(7 downto 0))) - Half_Ball_Width) then
                        Direction_x := not Direction_x;
                        Collide := '1';
                        Collide_what(10) := '1';
                    
                    -- Top Wall
                    elsif to_integer(unsigned(Ball_y)) <= Half_Ball_Height then
                        Direction_y := not Direction_y;
                        Collide := '1';
                        Collide_what(13) := '1';
                    
                    -- Bottom Wall
                    elsif to_integer(unsigned(Ball_y)) >= (to_integer(unsigned(Screen_reg(15 downto 8))) - Half_Ball_Height) then
                        Direction_y := not Direction_y;
                        Collide := '1';
                        Collide_what(12) := '1';
    
                    -- Detect Players 1 Collision
                    elsif (to_integer(unsigned(ball_x)) <= (Player_x_padding + Player_width + Half_Ball_Width) and 
                    to_integer(unsigned(ball_y)) >= (to_integer(unsigned(players_reg(15 downto 0))) - Half_Ball_Height - Half_Player_Height) and
                    to_integer(unsigned(ball_y)) <= (to_integer(unsigned(players_reg(15 downto 0))) + Half_Ball_Height + Half_Player_Height)) then
                        Direction_x := not Direction_x;
                        Collide := '1';
                        
                        -- Update Speed
                        if (to_integer(unsigned(ball_y)) >= (to_integer(unsigned(players_reg(15 downto 0))) - Half_Player_Height + (4 * Fifth_Player_Height))) then
                            Collide_what(5) := '1';
                            if (Direction_y = '0') then
                                Speed_x := Speed_x * 2;
                                Speed_y := Speed_y * 2;
                             else
                                Speed_x := Speed_x * 5;
                                Speed_y := Speed_y * 0;
                             end if;
                        elsif (to_integer(unsigned(ball_y)) >= (to_integer(unsigned(players_reg(15 downto 0))) - Half_Player_Height + (3 * Fifth_Player_Height))) then
                            Collide_what(6) := '1';
                            if (Direction_y = '0') then
                                Speed_x := (Speed_x * 3) / 2;
                                Speed_y := (Speed_y * 3) / 2;
                            else
                                Speed_x := Speed_x / 2;
                                Speed_y := Speed_y / 2;
                            end if;
                        elsif (to_integer(unsigned(ball_y)) >= (to_integer(unsigned(players_reg(15 downto 0))) - Half_Player_Height + (2 * Fifth_Player_Height))) then
                            Collide_what(7) := '1';
                            if (Direction_y = '0') then
                                Speed_x := Speed_x * 1;
                                Speed_y := Speed_y * 1;
                            end if;
                        elsif (to_integer(unsigned(ball_y)) >= (to_integer(unsigned(players_reg(15 downto 0))) - Half_Player_Height + (1 * Fifth_Player_Height))) then
                            Collide_what(8) := '1';
                            if (Direction_y = '0') then
                                Speed_x := Speed_x / 2;
                                Speed_y := Speed_y / 2;
                            else
                                Speed_x := (Speed_x * 3) / 2;
                                Speed_y := (Speed_y * 3) / 2;
                            end if;
                        elsif (to_integer(unsigned(ball_y)) >= (to_integer(unsigned(players_reg(15 downto 0))) - Half_Player_Height + (0 * Fifth_Player_Height))) then
                            Collide_what(9) := '1';
                            if (Direction_y = '0') then
                                Speed_x := 5;
                                Speed_y := Speed_y * 0;
                            else
                                Speed_x := Speed_x * 2;
                                Speed_y := Speed_y * 2;
                            end if;
                        end if;
                    
                    -- Detect Players 2 Collision
                    elsif (to_integer(unsigned(ball_x)) >= (to_integer(unsigned(Screen_reg(7 downto 0))) - Player_x_padding - Player_width - Half_Ball_Width) and 
                        to_integer(unsigned(ball_y)) >= (to_integer(unsigned(players_reg(31 downto 16))) - Half_Ball_Height - Half_Player_Height) and
                        to_integer(unsigned(ball_y)) <= (to_integer(unsigned(players_reg(31 downto 16))) + Half_Ball_Height + Half_Player_Height)) then
                        Direction_x := not Direction_x;
                        Collide := '1';
                        
                        -- Update Speed
                        if (to_integer(unsigned(ball_y)) >= (to_integer(unsigned(players_reg(31 downto 16))) - Half_Player_Height + (4 * Fifth_Player_Height))) then
                            Collide_what(0) := '1';
                            if (Direction_y = '0') then
                                Speed_x := Speed_x * 2;
                                Speed_y := Speed_y * 2;
                             else
                                Speed_x := Speed_x * 5;
                                Speed_y := Speed_y * 0;
                             end if;
                        elsif (to_integer(unsigned(ball_y)) >= (to_integer(unsigned(players_reg(31 downto 16))) - Half_Player_Height + (3 * Fifth_Player_Height))) then
                            Collide_what(1) := '1';
                            if (Direction_y = '0') then
                                Speed_x := (Speed_x * 3) / 2;
                                Speed_y := (Speed_y * 3) / 2;
                            else
                                Speed_x := Speed_x / 2;
                                Speed_y := Speed_y / 2;
                            end if;
                        elsif (to_integer(unsigned(ball_y)) >= (to_integer(unsigned(players_reg(31 downto 16))) - Half_Player_Height + (2 * Fifth_Player_Height))) then
                            Collide_what(2) := '1';
                            if (Direction_y = '0') then
                                Speed_x := Speed_x * 1;
                                Speed_y := Speed_y * 1;
                            end if;
                        elsif (to_integer(unsigned(ball_y)) >= (to_integer(unsigned(players_reg(31 downto 16))) - Half_Player_Height + (1 * Fifth_Player_Height))) then
                            Collide_what(3) := '1';
                            if (Direction_y = '0') then
                                Speed_x := Speed_x / 2;
                                Speed_y := Speed_y / 2;
                            else
                                Speed_x := (Speed_x * 3) / 2;
                                Speed_y := (Speed_y * 3) / 2;
                            end if;
                        elsif (to_integer(unsigned(ball_y)) >= (to_integer(unsigned(players_reg(31 downto 16))) - Half_Player_Height + (0 * Fifth_Player_Height))) then
                            Collide_what(4) := '1';
                            if (Direction_y = '0') then
                                Speed_x := 5;
                                Speed_y := Speed_y * 0;
                            else
                                Speed_x := Speed_x * 2;
                                Speed_y := Speed_y * 2;
                            end if;
                        end if;
                        
                        -- Check Max Speed
                        if(Speed_x > Ball_max_speed) then
                            Speed_x := Ball_max_speed;
                        end if;
                        if(Speed_y > Ball_max_speed) then
                            Speed_y := Ball_max_speed;
                        end if;
                        
                    end if;
    
                    Next_state <= WRITE_BACK;
    
                when WRITE_BACK =>
                    Ball_reg_sig <= Ball_x & Ball_y;
                    State_Col_reg_sig <=    std_logic_vector(to_unsigned(Speed_x, 4)) & -- Speed X      (bits 0-3)
                                        std_logic_vector(to_unsigned(Speed_y, 4)) & -- Speed Y      (bits 4-7)
                                        Direction_x &                               -- Left         (bit 8)
                                        (not Direction_x) &                         -- Right        (bit 9)
                                        Direction_y &                               -- Up           (bit 10)
                                        (not Direction_y) &                         -- Down         (bit 11)
                                        Collide &                                   -- Collide      (bit 12)
                                        State_Col_reg(13) &                         -- Reset        (bit 13)
                                        '0' &                                       -- NFR          (bit 14)
                                        State_Col_reg(15) &                         -- Enable       (bit 15)
                                        Collide_what &                              -- Collide with (bit 16-29)
                                        "00";                                       -- Padding 32 bits
                    Next_state <= IDLE;
    
                when others =>
                    Next_state <= IDLE;
            end case;
        end if;
    end process;
    
    Ball_reg <= Ball_reg_sig;
    State_Col_reg <= State_Col_reg_sig;
    
end Behavioral;