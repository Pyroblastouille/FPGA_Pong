----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.03.2025 14:18:41
-- Design Name: 
-- Module Name: spi_if - Behavioral
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

entity spi_pmodjstk2_if is
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
        cs        : out STD_LOGIC  -- Chip Select (active low)
    );   
end spi_pmodjstk2_if;

architecture Behavioral of spi_pmodjstk2_if is
    type state_type is (IDLE, WAIT_15us, TRANSFER,WAIT_10us,RECEIVE,WAIT_25uS);
    signal state : state_type := IDLE;
    
    signal bit_counter : INTEGER := 0; -- Counter for bits transferred
    signal shift_reg   : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0) := (others => '0'); -- Shift register for data
    signal miso_reg    : STD_LOGIC := '0'; -- Register to store MISO input
    signal clk_cnt : integer := 0;
    signal sclk_bfr : std_logic := '0';
begin
    sclk <= sclk_bfr;
    --SPI Clock
    sclk_gen:process(clk,nrst)
    begin
        if(nrst = '0') then
            sclk_bfr <= '0';
        elsif(rising_edge(clk)) then
            clk_cnt <= clk_cnt + 1;
            if(clk_cnt = CLK_DIVIDER) then
                clk_cnt <= 0;
                sclk_bfr <= not sclk_bfr;
            end if;
        end if;
    end process sclk_gen;
    
    --SPI Transact
    spi_transfer:process(sclk_bfr,nrst)
    begin
        if(nrst = '0') then
            state <= IDLE;
            cs <= '1'; -- Deactivate chip select
            busy <= '0'; -- Not busy
            bit_counter <= 0;
            shift_reg <= (others => '0');
            data_out <= (others => '0');
            mosi <= '0';
        elsif(rising_edge(sclk_bfr)) then
            case state is
                when IDLE =>
                    cs <= '1'; -- Deactivate chip selects
                    busy <= '0'; -- Not busy
                    if start = '1' then
                        cs <= '0'; -- Activate chip select
                        busy <= '1'; -- Busy flag
                        shift_reg <= data_in; -- Load input data into shift register
                        bit_counter <= 0; -- Reset bit counter
                        state <= TRANSFER;
                    end if;
                when WAIT_15us =>
                    bit_counter <= bit_counter + 1;
                    if(bit_counter > 15000/(10*CLK_DIVIDER)) then
                        bit_counter <= 0;
                        state <= TRANSFER;
                    end if;
                when WAIT_10us =>
                    bit_counter <= bit_counter + 1;
                    if(bit_counter > 10000/(10*CLK_DIVIDER)) then
                        bit_counter <= 0;
                        state <= TRANSFER;
                    end if;
                when WAIT_25us =>
                    bit_counter <= bit_counter + 1;
                    if(bit_counter > 25000/(10*CLK_DIVIDER)) then
                        bit_counter <= 0;
                        busy <= '0'; -- Not busy
                        state <= IDLE;
                    end if;
                when TRANSFER =>
                    if bit_counter < DATA_WIDTH then
                        -- Data transfer on rising or falling edge of SPI clock
                        mosi <= shift_reg(DATA_WIDTH - 1); -- Output MSB of shift register
                        shift_reg <= shift_reg(DATA_WIDTH - 2 downto 0) & miso; -- Shift left and insert MISO
                        bit_counter <= bit_counter + 1; -- Increment bit counter
                        if((bit_counter + 1) mod 8 = 0) then
                            state <= WAIT_10us;
                        end if;
                    else
                        bit_counter <= 0;
                        state <= WAIT_25us;
                        cs <= '1'; -- Deactivate chip select
                    end if;
                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process spi_transfer;

end Behavioral;
