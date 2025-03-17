----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 24.02.2025 16:10:54
-- Design Name:
-- Module Name: JoystickGrabber - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity JoystickGrabber is
--  Port ( );
    generic(
        C_ADDR_WIDTH : integer := 32;
        C_DATA_WIDTH : integer := 32);
    port(
    
    
    s_axi_aclk      : in  std_logic;
    s_axi_aresetn   : in  std_logic;
    -- ######################### --
    -- Joystick
    -- ######################### --
    joy_1 : out std_logic_vector(C_ADDR_WIDTH -1 downto 0);
    joy_2 : out std_logic_vector(C_ADDR_WIDTH -1 downto 0);
    
    -- ######################### --
    -- PMOD out
    -- ######################### --

    miso_1 : in STD_LOGIC;
    mosi_1 : out STD_LOGIC;
    sclk_1 : out STD_LOGIC;
    ss_1 : out STD_LOGIC;

    miso_2 : in STD_LOGIC;
    mosi_2 : out STD_LOGIC;
    sclk_2 : out STD_LOGIC;
    ss_2 : out STD_LOGIC

    );
end JoystickGrabber;

architecture Behavioral of JoystickGrabber is


  ---------------------------------------------------------------------------------
  -- Joystick
  ---------------------------------------------------------------------------------


  component pmod_joystick IS
  GENERIC(
    clk_freq        : INTEGER := 50); --system clock frequency in MHz
  PORT(
    clk             : IN     STD_LOGIC;                     --system clock
    reset_n         : IN     STD_LOGIC;                     --active low reset
    miso            : IN     STD_LOGIC;                     --SPI master in, slave out
    mosi            : OUT    STD_LOGIC;                     --SPI master out, slave in
    sclk            : BUFFER STD_LOGIC;                     --SPI clock
    cs_n            : OUT    STD_LOGIC;                     --pmod chip select
    x_position      : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0);  --joystick x-axis position
    y_position      : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0);  --joystick y-axis position
    trigger_button  : OUT    STD_LOGIC;                     --trigger button status
    center_button   : OUT    STD_LOGIC);                    --center button status
END component pmod_joystick;


  -- Internal state machine
  type state_type is (ASK_J1,WAIT_J1,ASK_J2,WAIT_J2);
  signal state : state_type := ASK_J1;
  
  --Joysticks
  signal bfr_joy_1_x : std_logic_vector(7 downto 0);
  signal bfr_joy_1_y : std_logic_vector(7 downto 0);
  signal bfr_joy_1_btn_trigger : std_logic;
  signal bfr_joy_1_btn_joystick : std_logic;

  signal bfr_joy_2_x : std_logic_vector(7 downto 0);
  signal bfr_joy_2_y : std_logic_vector(7 downto 0);
  signal bfr_joy_2_btn_trigger : std_logic;
  signal bfr_joy_2_btn_joystick : std_logic;
begin


  ---------------------------------------------------------------------------------
  -- Joystick
  ---------------------------------------------------------------------------------
  joystick_1 : pmod_joystick
    generic map (
      clk_freq => 100
      )
    port map(
        clk             => s_axi_aclk  ,
        reset_n         => s_axi_aresetn  ,
        miso            => miso_1  ,
        mosi            => mosi_1 ,
        sclk            => sclk_1  ,
        cs_n            => ss_1 ,
        x_position      => bfr_joy_1_x ,
        y_position      => bfr_joy_1_y ,
        trigger_button  => bfr_joy_1_btn_trigger ,
        center_button   => bfr_joy_1_btn_joystick
        );

  joystick_2 : pmod_joystick
  generic map (
    clk_freq => 100
    )
  port map(
      clk             => s_axi_aclk  ,
      reset_n         => s_axi_aresetn  ,
      miso            => miso_2  ,
      mosi            => mosi_2 ,
      sclk            => sclk_2  ,
      cs_n            => ss_2 ,
      x_position      => bfr_joy_2_x ,
      y_position      => bfr_joy_2_y ,
      trigger_button  => bfr_joy_2_btn_trigger ,
      center_button   => bfr_joy_2_btn_joystick
      );

    get_data: process(s_axi_aclk,s_axi_aresetn)
    begin
        if(s_axi_aresetn = '0') then
            joy_1 <= (others => '0');
            joy_2 <= (others => '0');
        elsif(rising_edge(s_axi_aclk)) then
            joy_1(7 downto 0) <= bfr_joy_1_x(7 downto 0);
            joy_1(15 downto 8) <= bfr_joy_1_y(7 downto 0);
            joy_1(16) <= bfr_joy_1_btn_trigger;
            joy_1(17) <= bfr_joy_1_btn_joystick;
            
            joy_2(7 downto 0) <= bfr_joy_2_x(7 downto 0);
            joy_2(15 downto 8) <= bfr_joy_2_y(7 downto 0);
            joy_2(16) <= bfr_joy_2_btn_trigger;
            joy_2(17) <= bfr_joy_2_btn_joystick;
        end if;
    end process get_data;


end Behavioral;
