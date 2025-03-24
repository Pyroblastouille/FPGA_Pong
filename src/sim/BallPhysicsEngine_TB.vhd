library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BallPhysicsEngine_TB is
end BallPhysicsEngine_TB;

architecture Behavioral of BallPhysicsEngine_TB is
    -- Component Declaration
    component BallPhysicsEngine
        generic(
            Player_height   : integer := 100;    -- Player height in pixels
            Player_width    : integer := 10;     -- Player width in pixels
            Player_x_padding: integer := 20;     -- Number of pixel of padding between the player and its wall
            Ball_height     : integer := 5;     -- Ball height in pixels
            Ball_width      : integer := 5     -- Ball width in pixels
        );
        port(
            clk             : in std_logic;
            State_Col_reg   : out std_logic_vector(31 downto 0);
            Screen_reg      : in std_logic_vector(31 downto 0);
            Ball_reg        : out std_logic_vector(31 downto 0);
            Players_reg     : in std_logic_vector(31 downto 0);
            Request_reg     : in std_logic_vector(31 downto 0)
        );
    end component;

    -- Signals for Testbench
    signal clk_tb           : std_logic := '0';
    signal State_Col_reg_tb : std_logic_vector(31 downto 0);
    signal Screen_reg_tb    : std_logic_vector(31 downto 0);
    signal Ball_reg_tb      : std_logic_vector(31 downto 0);
    signal Players_reg_tb   : std_logic_vector(31 downto 0);
    signal Request_reg_tb   : std_logic_vector(31 downto 0);

    -- Clock Period Definition (100 MHz = 10 ns period)
    constant clk_period : time := 10 ns;
    
begin
    -- Instantiate DUT (Device Under Test)
    UUT: BallPhysicsEngine
        generic map(
            Player_height   => 100,
            Player_width    => 10,
            Player_x_padding => 20,
            Ball_height     => 5,
            Ball_width      => 5
        )
        port map(
            clk          => clk_tb,
            State_Col_reg => State_Col_reg_tb,
            Screen_reg   => Screen_reg_tb,
            Ball_reg     => Ball_reg_tb,
            Players_reg  => Players_reg_tb,
            Request_reg => Request_reg_tb
        );

    -- Clock Process
    clk_process: process
    begin
        while true loop
            clk_tb <= '0';
            wait for clk_period / 2;
           clk_tb <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus Process (Test Cases)
    stimulus_process: process
    begin
        Request_reg_tb <= "00000000000000000000000000000000";
        
        -- 1. Set Screen Size
        Screen_reg_tb <= "00000010010110000000001100100000"; -- Width = 800, Height = 600
        
        -- 2. Apply Player Positions
        Players_reg_tb <= X"01220110";

        wait for 10 ns;

        -- 2. Reset
        Request_reg_tb <= "00000000000000000000000000000001";
        wait for 10 ns;
        Request_reg_tb <= "00000000000000000000000000000000";
        wait for 10 ns;

        -- 3. Enable the engine and request a frame update
        Request_reg_tb <= "00000000000000000000000000000110"; -- Enable + NFR bit set
        wait for 100000 ns;

        -- End of test
        wait;
    end process;

end Behavioral;
