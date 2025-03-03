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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

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
    type state_type is (IDLE, UPDATE_POS, CHECK_COLLISION, WRITE_BACK);
    signal Current_state, Next_state : state_type;
    
    -- Propriété de la balle
    signal Ball_x, Ball_y           : std_logic_vector(15 downto 0);
    signal Direction_x, Direction_y : std_logic;
    signal Speed_x, Speed_y         : integer;
    signal P1FU                     : std_logic;
    signal P1U                      : std_logic;
    signal P1D                      : std_logic;
    signal P1FD                     : std_logic;
    signal P2FU                     : std_logic;
    signal P2U                      : std_logic;
    signal P2D                      : std_logic;
    signal P2FD                     : std_logic;
    signal WU                       : std_logic;
    signal WD                       : std_logic;
    signal WL                       : std_logic;
    signal WR                       : std_logic;
    
begin
    process(clk, reset, State_Col_reg(13))
    variable screen_width  : integer;
    variable screen_height : integer;
    variable ball_center_x : integer;
    variable ball_center_y : integer;
    begin
        if reset = '1' or State_Col_reg(13) = '1' then
            Current_state <= IDLE;
            
            -- Convert screen size from std_logic_vector to integer
            screen_width  := conv_integer(Screen_reg(15 downto 0));
            screen_height := conv_integer(Screen_reg(31 downto 16));
            
            -- Compute ball center dynamically
            ball_center_x := (screen_width - Ball_width) / 2;
            ball_center_y := (screen_height - Ball_height) / 2;
            
            -- Convert back to std_logic_vector
            Ball_x <= conv_std_logic_vector(ball_center_x, 15);
            Ball_y <= conv_std_logic_vector(ball_center_y, 15);
            Ball_reg <= Ball_x & Ball_y;
            
            Direction_x <= '1';                     -- Ball will go left
            Direction_y <= '0';                     -- Ball will go down
            
            State_Col_reg <= "000000000000000000101001010101";    -- Clear Reset, Collision, Direction and NFR
        elsif rising_edge(clk) then
            Current_state <= Next_state;
        end if;
    end process;

    process(Current_state, State_Col_reg, Players_reg, Screen_reg)
    constant Half_Ball_Width        : integer := Ball_width / 2;
    constant Half_Ball_Height       : integer := Ball_height / 2;
    constant Half_Player_Height     : integer := Player_height / 2;
    constant Fifth_Player_Height    : integer := Player_height / 5;
    begin
        case Current_state is
            when IDLE =>
                if State_Col_reg(14) = '1' then -- NFR bit
                    Next_state <= UPDATE_POS;
                else
                    Next_state <= IDLE;
                end if;

            when UPDATE_POS =>
                -- Update Ball Position
                if Direction_x = '1' then
                    Ball_x <= Ball_x + Speed_x;
                else
                    Ball_x <= Ball_x - Speed_x;
                end if;
                
                if Direction_y = '1' then
                    Ball_y <= Ball_y + Speed_y;
                else
                    Ball_y <= Ball_y - Speed_y;
                end if;
                Next_state <= CHECK_COLLISION;

            when CHECK_COLLISION =>
            
                -- Detect Wall Collision
                if Ball_x <= Half_Ball_Width or Ball_x >= screen_reg(7 downto 0) - Half_Ball_Width then
                    Direction_x <= not Direction_x;
                    
                elsif Ball_y <= Half_Ball_Height or Ball_y >= screen_reg(15 downto 8) - Half_Ball_Height then
                    Direction_y <= not Direction_y;

                -- Detect Players 1 Collision
                elsif (ball_x <= Player_x_padding + Player_width + Half_Ball_Width and 
                    ball_y >= players_reg(7 downto 0) - Half_Ball_Height - Half_Player_Height and
                    ball_y <= players_reg(7 downto 0) + Half_Ball_Height + Half_Player_Height) then
                    Direction_x <= not Direction_x;
                    
                    -- Update Speed
                    if (ball_y >= players_reg(7 downto 0) - Half_Player_Height + (4 * Fifth_Player_Height)) then
                        if (Direction_y = '0') then
                            Speed_x <= Speed_x * 2;
                            Speed_y <= Speed_y * 2;
                         else
                            Speed_x <= Speed_x * 5;
                            Speed_y <= Speed_y * 0;
                         end if;
                    elsif (ball_y >= players_reg(7 downto 0) - Half_Player_Height + (3 * Fifth_Player_Height)) then
                        if (Direction_y = '0') then
                            Speed_x <= Speed_x * 1,5;
                            Speed_y <= Speed_y * 1,5;
                        else
                            Speed_x <= Speed_x * 0,5;
                            Speed_y <= Speed_y * 0,5;
                        end if;
                    elsif (ball_y >= players_reg(7 downto 0) - Half_Player_Height + (2 * Fifth_Player_Height)) then
                        if (Direction_y = '0') then
                            Speed_x <= Speed_x * 1;
                            Speed_y <= Speed_y * 1;
                        end if;
                    elsif (ball_y >= players_reg(7 downto 0) - Half_Player_Height + (1 * Fifth_Player_Height)) then
                        if (Direction_y = '0') then
                            Speed_x <= Speed_x * 0,5;
                            Speed_y <= Speed_y * 0,5;
                        else
                            Speed_x <= Speed_x * 1,5;
                            Speed_y <= Speed_y * 1,5;
                        end if;
                    elsif (ball_y >= players_reg(7 downto 0) - Half_Player_Height + (0 * Fifth_Player_Height)) then
                        if (Direction_y = '0') then
                            Speed_x <= 5;
                            Speed_y <= Speed_y * 0;
                        else
                            Speed_x <= Speed_x * 2;
                            Speed_y <= Speed_y * 2;
                        end if;
                    end if;
                
                -- Detect Players 2 Collision
                elsif (ball_x >= screen_reg(7 downto 0) - Player_x_padding - Player_width - Half_Ball_Width and 
                    ball_y >= players_reg(15 downto 8) - Half_Ball_Height - Half_Player_Height and
                    ball_y <= players_reg(15 downto 8) + Half_Ball_Height + Half_Player_Height) then
                    Direction_x <= not Direction_x;
                    
                    -- Update Speed
                    if (ball_y >= players_reg(15 downto 8) - Half_Player_Height + (4 * Fifth_Player_Height)) then
                        if (Direction_y = '0') then
                            Speed_x <= Speed_x * 2;
                            Speed_y <= Speed_y * 2;
                         else
                            Speed_x <= Speed_x * 5;
                            Speed_y <= Speed_y * 0;
                         end if;
                    elsif (ball_y >= players_reg(15 downto 8) - Half_Player_Height + (3 * Fifth_Player_Height)) then
                        if (Direction_y = '0') then
                            Speed_x <= Speed_x * 1,5;
                            Speed_y <= Speed_y * 1,5;
                        else
                            Speed_x <= Speed_x * 0,5;
                            Speed_y <= Speed_y * 0,5;
                        end if;
                    elsif (ball_y >= players_reg(15 downto 8) - Half_Player_Height + (2 * Fifth_Player_Height)) then
                        if (Direction_y = '0') then
                            Speed_x <= Speed_x * 1;
                            Speed_y <= Speed_y * 1;
                        end if;
                    elsif (ball_y >= players_reg(15 downto 8) - Half_Player_Height + (1 * Fifth_Player_Height)) then
                        if (Direction_y = '0') then
                            Speed_x <= Speed_x * 0,5;
                            Speed_y <= Speed_y * 0,5;
                        else
                            Speed_x <= Speed_x * 1,5;
                            Speed_y <= Speed_y * 1,5;
                        end if;
                    elsif (ball_y >= players_reg(15 downto 8) - Half_Player_Height + (0 * Fifth_Player_Height)) then
                        if (Direction_y = '0') then
                            Speed_x <= 5;
                            Speed_y <= Speed_y * 0;
                        else
                            Speed_x <= Speed_x * 2;
                            Speed_y <= Speed_y * 2;
                        end if;
                    end if;
                    
                    -- Check Max Speed
                    if(Speed_x > Ball_max_speed) then
                        Speed_x <= Ball_max_speed;
                    end if;
                    if(Speed_y > Ball_max_speed) then
                        Speed_y <= Ball_max_speed;
                    end if;
                    
                end if;

                Next_state <= WRITE_BACK;

            when WRITE_BACK =>
                Ball_reg <= Ball_x & Ball_y;
                State_Col_reg <=    conv_std_logic_vector(Speed_x, 4) & -- Speed X (bits 0-3)
                                    conv_std_logic_vector(Speed_y, 4) & -- Speed Y (bits 4-7)
                                    Direction_x &                       -- Going Left (bit 8)
                                    (not Direction_x) &                 -- Going Right (bit 9)
                                    Direction_y &                       -- Going Up (bit 10)
                                    (not Direction_y);                  -- Going Down (bit 11)
                                    -- TODO
                Next_state <= IDLE;

            when others =>
                Next_state <= IDLE;
        end case;
    end process;
    
end Behavioral;
