----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.10.2024 17:13:42
-- Design Name: 
-- Module Name: vga_controller - behavioral
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

    --Settings qui fonctionnent sûr
	--generic map(40000000, '1', '1', 800, 40, 128, 88, 600, 1,4, 23)	--800x600p60
	--generic map(25175000,'0','0',640,16,96,48,480,10,2,33) --640x480p60
	
    --D'autres settings
    --generic map(148500000, '1', '1', 1920, 88, 44, 148, 1080, 4, 5, 36)	--1920x1080p60
	--generic map(74250000,'1','1',1280,110,40,220,720,5,5,20) -- 1280x720p60
    --generic map(193333333, '0', '0', 1920, 88, 44, 148, 1080, 4, 5, 36) --1920x1200
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- using
-- arithmetic functions with Signed or Unsigned values
use ieee.numeric_std.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity VGA_ctrl is
    generic(
        freq_clk: integer :=50000000; 
        H_sync_polarity: std_logic := '1'; 	-- Sync polarity - 1 positive, 0 negative
		V_sync_polarity: std_logic := '1'; 	-- Sync polarity - 1 positive, 0 negative
		H_Visible: integer :=800; 		-- nombre de pixels visibles
		H_Front_porch: integer	:=56; 		-- nombre de cycles porch
		H_Sync_pulse: integer :=120;		-- nombre de cycles H_sync
		H_Back_porch: integer :=64;		-- nombre de cycles porch
		V_Visible: integer :=600;		-- nombre de lignes visibles
		V_Front_porch: integer :=37;		-- nombre de lignes porch
		V_Sync_pulse: integer :=6;		-- nombre de lignes V_sync
		V_Back_porch: integer :=23);		-- nombre de lignes porch
    port(
	clk 	: in std_logic;				-- clk d'entr�e
	rst 	: in std_logic;				-- reset
	Hcount 	: out std_logic_vector(12 downto 0);	-- Cordonnée du pixel horizontale �  afficher
	Vcount 	: out std_logic_vector(12 downto 0);	-- Cordonnée du pixel horizontale �  afficher
	H_sync  : out std_logic;			-- Signal de synchronization
	V_sync  : out std_logic;			-- Signal de synchronization
	blank   : out std_logic;				-- 0 si pixel visible, 1 si non visible (porch ou sync)
	frame   : out std_logic);
        
        
end VGA_ctrl;

architecture behavioral of VGA_ctrl is
    constant h_total : integer := H_Visible + H_Front_porch + H_Sync_pulse + H_Back_porch;
    constant v_total : integer := V_Visible + V_Front_porch + V_Sync_pulse + V_Back_porch;
   signal current_h: integer := 0;
   signal current_v: integer := 0;
begin
    PROCESS(clk)
        begin
            --g�rer le blank
            if ((current_h >= H_Sync_pulse + H_Back_porch
                and current_h < h_total-H_Front_porch) 
                and (current_v >= V_Sync_pulse + V_Back_porch
                and current_v < v_total - V_Front_porch)) then
                    blank <= '0';
                    Hcount <= std_logic_vector(to_unsigned(current_h-(H_Sync_pulse+H_Back_porch),13));
                    Vcount <= std_logic_vector(to_unsigned(current_v-(V_Sync_pulse+V_Back_porch),13));
                else
                    blank <= '1';
            end if;
            
            if(rst = '0') then
                current_h <= 0;
                current_v <= 0;
                Hcount <= (others => '0');
                Vcount <= (others => '0');
                blank <= '1';
                H_sync <= not H_sync_polarity;
                V_sync <= not V_sync_polarity;
            elsif (rising_edge(clk)) then
                frame <= '0';
                --Mise � jour Hcount et Vcount
                if(current_h < h_total - 1) then
                    current_h <= current_h+1;
                else
                    current_h <= 0;
                    Hcount <= (others => '0');
                    if(current_v < v_total - 1) then
                        current_v <= current_v+1;
                    else
                        current_v <= 0;
                        Vcount <= (others => '0');
                        frame <= '1';
                    end if;
                end if;
                -- On g�re les sync pulse
                if (current_h < H_Sync_pulse) then
                    H_sync <= H_sync_polarity;
                else
                    H_sync <= not H_sync_polarity;
                end if;
                if (current_v < v_sync_pulse) then
                    V_sync <= V_sync_polarity;
                else
                    V_sync <= not V_sync_polarity;
                end if;
                
            end if;
    end process;
end behavioral;
