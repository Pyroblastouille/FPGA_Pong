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
    reset : in std_logic;
    -- cs defining if idling
    cs: out std_logic;
    -- Buffer send and receive --
    tx : in std_logic_vector(39 downto 0);
    rx : out std_logic_vector(39 downto 0)
  );
end joystick;

-- Architecture body
architecture Behavioral of joystick is
    
  -- SPI
  signal MOSI : std_logic := '0';
  signal MISO : std_logic := '0';
  signal SCLK : std_logic := '0';
  
  -- SPI communication signals
  signal clk_div   : unsigned(15 downto 0) := (others => '0');  -- Clock divider
  signal spi_clk   : std_logic := '0';      -- SPI clock signal
  signal bit_count : integer := 0; -- Bit counter for SPI transfer
  signal transfer  : std_logic := '0';      -- Signal to initiate SPI transfer
  signal buffer_tx : std_logic_vector(39 downto 0) := (others => '0'); -- Transmit data buffer (5 bytes)
  signal buffer_rx : std_logic_vector(39 downto 0) := (others => '0'); -- Receive data buffer (5 bytes)
    
  -- Internal state machine
  type state_type is (IDLE, SEND, RECEIVE, DONE);
  signal state : state_type := IDLE;

begin

buffer_tx <= tx;
rx <= buffer_rx;
  -- SPI Clock Generation
  process (clk, reset)
  begin
    if reset = '1' then
      clk_div <= (others => '0');
      spi_clk <= '0';
    elsif rising_edge(clk) then
      -- Go from 100MHz to 1MHz
      if clk_div < 100 then
        clk_div <= (others => '0');
        spi_clk <= not spi_clk; -- Toggle SPI clock
      else
        clk_div <= clk_div + 1;
      end if;
    end if;
  end process;

  -- SPI Transaction State Machine
  process (clk, reset)
  begin
    if reset = '1' then
      cs <= '1';
      MOSI <= '0';
      bit_count <= 0;
      state <= IDLE;
      
    elsif rising_edge(spi_clk) then
      case state is
        when IDLE =>
          cs <= '1';  -- Deactivate cs
          bit_count <= 0;
          if transfer = '1' then
            cs <= '0'; -- Activate cs
            state <= SEND;
          end if;

        when SEND =>
          -- Send data byte (MSB first)
          if bit_count < 40 then
            MOSI <= buffer_tx(39 - bit_count); -- Shift out MSB first
            bit_count <= bit_count + 1;
          else
            bit_count <= 0;
            state <= RECEIVE; -- Move to receive state
          end if;

        when RECEIVE =>
          -- Receive byte from MISO
          if bit_count < 40 then
            buffer_rx(39 - bit_count) <= MISO; -- Shift in MSB first
            bit_count <= bit_count + 1;
          else
            bit_count <= 0;
            state <= DONE; -- Move to process state
          end if;

        when DONE =>
          cs <= '1'; -- Deactivate cs
          state <= IDLE; -- Return to IDLE state

        when others =>
          state <= IDLE;
      end case;
    end if;
  end process;


end Behavioral;
