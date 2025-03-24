----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.03.2025 14:50:08
-- Design Name: 
-- Module Name: vga_joystick_axis - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_joystick_axis is
    Port(
        clk     :   in std_logic;
        rst     :   in std_logic;
        joy1    :   in std_logic_vector(31 downto 0);
        joy2    :   in std_logic_vector(31 downto 0);
        H_sync  :   out std_logic;
        V_sync  :   out std_logic;
        pixel   :   out std_logic_vector(11 downto 0)
    );
end vga_joystick_axis;

architecture Behavioral of vga_joystick_axis is


	-- ###########################
	-- 	start define VGA
	-- ###########################
   component VGA_ctrl is
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
		V_Back_porch: integer :=23		-- nombre de lignes porch
          );
     port( 
	clk 	: in std_logic;				-- clk d'entrée
	rst 	: in std_logic;				-- reset
	Hcount 	: out std_logic_vector(12 downto 0);	-- Cordonnée du pixel horizontale �  afficher
	Vcount 	: out std_logic_vector(12 downto 0);	-- Cordonnée du pixel horizontale �  afficher
	H_sync  : out std_logic;			-- Signal de synchronization
	V_sync  : out std_logic;			-- Signal de synchronization
	blank   : out std_logic;				-- 0 si pixel visible, 1 si non visible (porch ou sync)
	frame   : out std_logic
        );
    end component VGA_ctrl;
    
	-- ###########################
	-- 	end define VGA
	-- ###########################
	
	
    --affichage
    constant WHITE : std_logic_vector(11 downto 0) := "111111111111";
    constant GREY : std_logic_vector(11 downto 0) := "011101110111";
    constant BLACK : std_logic_vector(11 downto 0) := "000000000000";
    constant RED : std_logic_vector(11 downto 0) := "111100000000";
    constant GREEN : std_logic_vector(11 downto 0) := "000011110000";
    constant BLUE : std_logic_vector(11 downto 0) := "000000001111";
    signal Hcount : std_logic_vector(12 downto 0);
    signal Vcount : std_logic_vector(12 downto 0);
    signal blank, frame : std_logic;
    
    
    --input direction 
    signal j1_x : integer := 0;
    signal j1_y : integer := 0;
    signal j1_t : std_logic := '0';
    signal j1_j : std_logic := '0';
    signal j2_x : integer := 0;
    signal j2_y : integer := 0;
    signal j2_t : std_logic := '0';
    signal j2_j : std_logic := '0';
    
    constant freq_clk : integer := 25175000;        
    constant H_sync_polarity: std_logic := '0'; 	-- Sync polarity - 1 positive, 0 negative
    constant V_sync_polarity: std_logic := '0'; 	-- Sync polarity - 1 positive, 0 negative
    constant H_Visible: integer :=640; 		-- nombre de pixels visibles
    constant H_Front_porch: integer	:=16; 		-- nombre de cycles porch
    constant H_Sync_pulse: integer :=96;		-- nombre de cycles H_sync
    constant H_Back_porch: integer :=48;		-- nombre de cycles porch
    constant V_Visible: integer :=480;		-- nombre de lignes visibles
    constant V_Front_porch: integer :=10;		-- nombre de lignes porch
    constant V_Sync_pulse: integer :=2;		-- nombre de lignes V_sync
    constant V_Back_porch: integer :=33;		-- nombre de lignes porch
begin


	-- ###########################
	-- 	start instantiation VGA
	-- ###########################
VGA_inst : VGA_ctrl
	--generic map(148500000, '1', '1', 1920, 88, 44, 148, 1080, 4, 5, 36)  -- 1920x1080p60
	--generic map(40000000, '1', '1', 800, 40, 128, 88, 600, 1,4, 23)	       -- 800x600p60
	--generic map(25175000,'0','0',640,16,96,48,480,10,2,33)               -- 640x480p60
	--generic map(74250000,'1','1',1280,110,40,220,720,5,5,20)             -- 1280x720p60
	generic map(
        freq_clk        => freq_clk,
        H_sync_polarity => H_sync_polarity,
        V_sync_polarity => V_sync_polarity,
        H_Visible       => H_Visible,
        H_Front_porch   => H_Front_porch,
        H_Sync_pulse    => H_Sync_pulse,
        H_Back_porch    => H_Back_porch,
        V_Visible       => V_Visible,
        V_Front_porch   => V_Front_porch,
        V_Sync_pulse    => V_Sync_pulse,
        V_Back_porch    => V_Back_porch)
	port map( 
        clk     => clk, 
        rst     => rst, 
        Hcount  => Hcount, 
        Vcount  => Vcount, 
        H_sync  => H_sync,  
        V_sync  => V_sync, 
        blank   => blank, 
        frame   => frame);
	
	-- ###########################
	-- 	start instantiation VGA
	-- ###########################
	
j1_x <= to_integer(signed(joy1(7 downto 0)));
j1_y <= to_integer(signed(joy1(15 downto 8)));
j1_t <= joy1(16);
j1_j <= joy1(17);
j2_x <= to_integer(signed(joy2(7 downto 0)));
j2_y <= to_integer(signed(joy2(15 downto 8)));
j2_t <= joy2(16);
j2_j <= joy2(17);

show : process(clk)
    variable x : integer := 0;
    variable y : integer := 0;
begin
    if(rising_edge(clk)) then
        if blank = '0' then 
            x := to_integer(unsigned(Hcount));
            y := to_integer(unsigned(Vcount));
            --zone active
            if(x = 200+j1_x and y = 200+j1_y) then
                pixel <= WHITE;
             elsif (x = (H_Visible-200)+j2_x and y = 200+j2_y) then
                pixel <= WHITE;
             elsif(j1_t = '1' and x=190 and y = 190) then
                pixel <= WHITE;
             elsif(j1_j = '1' and x=210 and y = 190) then
                pixel <= WHITE;
             elsif(j2_t = '1' and x=(H_Visible-210) and y = 190) then
                pixel <= WHITE;
             elsif(j2_j = '1' and x=(H_Visible-190) and y = 190) then
                pixel <= WHITE;
             else 
                pixel <= BLACK;
             end if;
        else
            pixel <= BLACK;
        end if;
    end if;
end process show;
    
end Behavioral;
