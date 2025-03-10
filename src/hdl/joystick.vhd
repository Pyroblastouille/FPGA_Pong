----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.02.2025 14:31:22
-- Design Name: 
-- Module Name: joystick - Behavioral
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

use IEEE.NUMERIC_STD.ALL;

-- Communication SPI with joystick
entity joystick is
  Port (
    -- Clock and Reset
    clk : in std_logic; 
    nreset : in std_logic;
    -- cs defining if idling
    ask : in std_logic;
    -- joystick values --
    always_on : out std_logic;
    --x : out std_logic_vector(9 downto 0);
    --y : out std_logic_vector(9 downto 0);
    btn_trigger : out std_logic;
    btn_joystick : out std_logic;
    
    leds : out STD_LOGIC_VECTOR(2 downto 0);
    
    --SPI INTERFACE -- 
    sclk      : out STD_LOGIC; -- SPI clock
    mosi      : out STD_LOGIC; -- Master Out Slave In (data to slave)
    miso      : in  STD_LOGIC; -- Master In Slave Out (data from slave)
    cs        : out STD_LOGIC  -- Chip Select (active low)
  );
end joystick;

-- Architecture body
architecture Behavioral of joystick is
  

component spi_pmodjstk2_if is
    generic (
        DATA_WIDTH  : integer := 8; -- bits per SPI transaction
        CLK_DIVIDER : integer := 10
        );
   Port (
        clk       : in  STD_LOGIC; -- System clock
        nrst       : in  STD_LOGIC; -- System reset
        start     : in  STD_LOGIC; -- Start SPI transaction
        data_in   : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0); -- Data to transmit
        data_out  : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0); -- Data received
        busy      : out STD_LOGIC; -- SPI master busy flag
        sclk      : out STD_LOGIC; -- SPI clock
        mosi      : out STD_LOGIC; -- Master Out Slave In (data to slave)
        miso      : in  STD_LOGIC; -- Master In Slave Out (data from slave)
        cs        : out STD_LOGIC;  -- Chip Select (active low)
        state_out : out STD_LOGIC_VECTOR(2 downto 0)
    );   
end component spi_pmodjstk2_if;

    signal joy_request : std_logic := '0';
    signal joy_busy : std_logic := '0';
    signal joy_data_in : std_logic_vector(39 downto 0) := (others=> '0');
    signal joy_data_out: std_logic_vector(39 downto 0) := (others => '0');
    signal ss : std_logic := '1';    
    
    signal count : integer := 0;

    
  -- Internal state machine
  type state_type is (IDLE,ASK_JOY,WAIT_JOY);
  signal state : state_type := IDLE;
begin
    
always_on <= '1';
joy : spi_pmodjstk2_if
    generic map (
      DATA_WIDTH => 40
      )
    port map(
        clk         => clk  ,
        nrst        => nreset  ,
        start       => joy_request  ,
        data_in     => joy_data_in ,
        data_out    => joy_data_out  ,
        busy        => joy_busy ,
        sclk        => sclk ,
        mosi        => mosi ,
        miso        => miso ,
        cs          => ss,
        state_out => leds
        );
    cs <= ss;
    
    get_data: process(clk)
        constant CMD_GET : std_logic_vector(39 downto 0) := (x"F000000000");
    begin
            
        if(rising_edge(clk)) then
            if(nreset = '0') then
               -- x <= (others => '0');
                --y <= (others => '0');
                btn_trigger <= '0';
                btn_joystick <= '0';
                state <= IDLE;
             else
                    case state is
                        when IDLE =>
                            if(ask = '1') then
                                state <= ASK_JOY;
                            end if;
                        when ASK_JOY =>
                            joy_data_in <= CMD_GET;
                            if(joy_busy = '0') then
                                joy_request <= '1';
                            elsif( joy_request = '1') then
                                state<= WAIT_JOY;
                            end if;
                        
                        when WAIT_JOY =>
                            joy_request <= '0';
                            if(joy_busy = '0') then
                                --x <= joy_data_out(25) & joy_data_out(37) & joy_data_out(32);
                                --Wy <= joy_data_out(9) & joy_data_out(19) & joy_data_out(16);
                                --x <= joy_data_out(25 downto 24) & joy_data_out(39 downto 32);
                                --y <= joy_data_out(9 downto 8) & joy_data_out(23 downto 16);
                                btn_trigger <= joy_data_out(1);
                                btn_joystick <= joy_data_out(0);
                                
                                state <= IDLE;
                            end if;
                        when others =>
                            state <= IDLE;
                    end case;             
                end if;
        end if;
    end process get_data;


end Behavioral;
