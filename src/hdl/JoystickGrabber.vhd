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
        ADDR_WIDTH : integer := 32;
        DATA_WIDTH : integer := 32);
    port(
        -- Global signals
        CLK     : in std_logic;       -- Clock signal
        NRESET  : in std_logic;       -- Active-low reset signal
        
        -- Read address channel
        R_ADDR   : in std_logic_vector(ADDR_WIDTH-1 downto 0); -- Read address
        R_ADDR_VALID  : in std_logic;       -- Read address valid
        R_ADDR_READY  : out std_logic;      -- Read address ready
        
        -- Read data channel
        R_DATA: out std_logic_vector(DATA_WIDTH-1 downto 0); -- Read data
        R_RESP    : out std_logic; -- Read response
        R_DATA_VALID   : out std_logic;       -- Read data valid
        R_DATA_READY : in std_logic         -- Read data ready
        
        -- Write address channel
        W_ADDR  : in std_logic_vector(ADDR_WIDTH-1 downto 0); -- Write address
        W_ADDR_VALID  : in std_logic;       -- Write address valid
        W_ADDR_READY  : out std_logic;      -- Write address ready
    
        -- Write data channel
        W_DATA    : in std_logic_vector(DATA_WIDTH-1 downto 0); -- Write data
        W_STROBE    : in std_logic_vector((DATA_WIDTH/8)-1 downto 0); -- Write strobe
        W_DATA_VALID   : in std_logic;       -- Write data valid
        W_DATA_READY: out std_logic;      -- Write data ready
    
        -- Write response channel
        W_RESP: out std_logic_vector(1 downto 0); -- Write response
        W_RESP_VALID: out std_logic;       -- Write response valid
        W_RESP_READY: in std_logic;        -- Write response ready
    
    
    );
end JoystickGrabber;

architecture Behavioral of JoystickGrabber is
    type state_type is (IDLE, WRITE, RESPOND, READ);
    signal write_state : state_type := IDLE;
    signal read_state  : state_type := IDLE;
    
    --AXI4 Lite
    signal w_a_ready : std_logic := '0';
    signal w_ready : std_logic := '0';
    signal w_resp_valid : std_logic := '0';
    signal r_addr_ready: std_logic := '0';
    signal r_valid : std_logic := '0';
    signal w_addr : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
    signal w_data : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal r_addr : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
    
begin

    --WRITE
    W_ADDR_READY <= w_addr_ready; --WAT
    write_channel : process(CLK)
    begin
        if(rising_edge(CLK)) then
            if(NRESET = '0') then
                --RESET--
            else
                case write_state is
                when IDLE =>
                    --IDLE--
                    if(W_ADDR_VALID = '1' and W_DATA_VALID = '1') then
                        write_state <= WRITE;
                        w_data <= W_DATA;
                        w_addr <= W_ADDR;
                        W_ADDR_READY <= '0';
                        W_DATA_READY <= '0';
                    end if;
                when WRITE =>
                    --WRITE--
                when RESPOND => 
                    --WRITE--
                
                when READ =>
                    --READ--
                when others =>
                    --Not Handled--
            end if;
        end if;
    end write_channel;

    --READ
    read_channel : process(CLK)
    begin
        if(rising_edge(CLK)) then
        end if;
    end read_channel;

end Behavioral;
