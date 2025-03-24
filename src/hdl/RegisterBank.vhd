----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/24/2025 03:03:19 PM
-- Design Name: 
-- Module Name: RegisterBank - Behavioral
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

entity RegisterBank is
    Port (
        -- AXI Clock & Reset
        clk     : in std_logic;
        rst     : in std_logic;

        -- AXI4-Lite Signals Simplifiés
        wr_valid_i : in std_logic;
        wr_addr_i  : in std_logic_vector(3 downto 0);
        wr_data_i  : in std_logic_vector(31 downto 0);

        rd_valid_i : in std_logic;
        rd_addr_i  : in std_logic_vector(3 downto 0);
        rd_data_o  : out std_logic_vector(31 downto 0);
        
        -- Registers
        state_reg  : in std_logic_vector(31 downto 0);
        screen_reg  : out std_logic_vector(31 downto 0);
        ball_reg  : in std_logic_vector(31 downto 0);
        players_reg  : out std_logic_vector(31 downto 0);
        request_reg  : out std_logic_vector(31 downto 0);
        joystick1_reg  : in std_logic_vector(31 downto 0);
        joystick2_reg  : in std_logic_vector(31 downto 0)
    );
end RegisterBank;

architecture Behavioral of RegisterBank is

    -- Registres internes
    signal state_reg_s     : std_logic_vector(31 downto 0) := (others => '0'); -- RO
    signal screen_reg_s    : std_logic_vector(31 downto 0) := (others => '0'); -- WO
    signal ball_reg_s      : std_logic_vector(31 downto 0) := (others => '0'); -- RO
    signal players_reg_s   : std_logic_vector(31 downto 0) := (others => '0'); -- WO
    signal request_reg_s   : std_logic_vector(31 downto 0) := (others => '0'); -- WO
    signal joystick1_reg_s  : std_logic_vector(31 downto 0) := (others => '0'); -- RO
    signal joystick2_reg_s  : std_logic_vector(31 downto 0) := (others => '0'); -- RO
    
    -- Adresse des registres
    constant REG_STATE_ADDR   : integer := 0;
    constant REG_SCREEN_ADDR  : integer := 4;
    constant REG_BALL_ADDR    : integer := 8;
    constant REG_PLAYERS_ADDR : integer := 12;
    constant REG_REQUEST_ADDR : integer := 16;
    constant REG_JOYSTICK1_ADDR : integer := 20;
    constant REG_JOYSTICK2_ADDR : integer := 24;
    
    -- Donnée de lecture
    signal rd_data_s : std_logic_vector(31 downto 0) := (others => '0');

begin
    -- Processus d'écriture
    wr_regs_proc : process(clk)
    begin
    
        if rising_edge(clk) then
        
            if rst = '0' then
                screen_reg  <= (others => '0');
                players_reg <= (others => '0');
                request_reg <= (others => '0');
            else
            
                screen_reg_s <= screen_reg_s;
                players_reg_s <= players_reg_s;
                request_reg_s <= request_reg_s;
                state_reg_s <= state_reg_s;
                ball_reg_s <= ball_reg_s;
                joystick1_reg_s <= joystick1_reg_s;
                joystick2_reg_s <= joystick2_reg_s;
                if wr_valid_i = '1' then
                
                    case to_integer(unsigned(wr_addr_i)) is
                        when REG_SCREEN_ADDR  => screen_reg_s  <= wr_data_i;
                        when REG_PLAYERS_ADDR => players_reg_s <= wr_data_i;
                        when REG_REQUEST_ADDR => request_reg_s <= wr_data_i;
                        when others => null;
                    end case;
                    
                end if;
                
            end if;
            
        end if;       
    end process wr_regs_proc;

    -- Processus de lecture
    rd_regs_proc : process(clk)
    begin
    
        if rising_edge(clk) then
        
            if rst = '0' then
            
                rd_data_s <= (others => '0');
                
            elsif rd_valid_i = '1' then
            
                case to_integer(unsigned(rd_addr_i)) is
                    when REG_STATE_ADDR     => rd_data_s <= state_reg_s;
                    when REG_BALL_ADDR      => rd_data_s <= ball_reg_s;
                    when REG_JOYSTICK1_ADDR  => rd_data_s <= joystick1_reg_s;
                    when REG_JOYSTICK2_ADDR  => rd_data_s <= joystick2_reg_s;
                    when others             => rd_data_s <= (others => '0');
                end case;
                
            end if;
            
        end if;
    end process rd_regs_proc;

    -- Map I / O to registers
    rd_data_o   <= rd_data_s;
    screen_reg  <= screen_reg_s;
    players_reg <= joystick2_reg_s(15 downto 0) & joystick1_reg_s(15 downto 0);
    request_reg <= request_reg_s;

end Behavioral;
