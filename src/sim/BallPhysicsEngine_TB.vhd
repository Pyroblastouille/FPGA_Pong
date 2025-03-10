library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BallPhysicsEngine_TB is
end BallPhysicsEngine_TB;

architecture Behavioral of BallPhysicsEngine_TB is
    -- Component Declaration
    component BallPhysicsEngine
        generic(
            Player_height   : integer := 10;
            Player_width    : integer := 5;
            Player_x_padding: integer := 2;
            Ball_height     : integer := 5;
            Ball_width      : integer := 5;
            Ball_max_speed  : integer := 17
        );
        port(
            clk             : in std_logic;
            reset           : in std_logic;
            State_Col_reg   : inout std_logic_vector(31 downto 0);
            Screen_reg      : in std_logic_vector(31 downto 0);
            Ball_reg        : out std_logic_vector(31 downto 0);
            Players_reg     : in std_logic_vector(31 downto 0)
        );
    end component;

    -- Signals for Testbench
    signal clk_tb           : std_logic := '0';
    signal reset_tb         : std_logic := '0';
    signal State_Col_reg_tb : std_logic_vector(31 downto 0);
    signal Screen_reg_tb    : std_logic_vector(31 downto 0);
    signal Ball_reg_tb      : std_logic_vector(31 downto 0);
    signal Players_reg_tb   : std_logic_vector(31 downto 0);

    -- Clock Period Definition (100 MHz = 10 ns period)
    constant clk_period : time := 10 ns;
    
begin
    -- Instantiate DUT (Device Under Test)
    UUT: BallPhysicsEngine
        generic map(
            Player_height   => 10,
            Player_width    => 5,
            Player_x_padding => 2,
            Ball_height     => 5,
            Ball_width      => 5,
            Ball_max_speed  => 17
        )
        port map(
            clk          => clk_tb,
            reset        => reset_tb,
            State_Col_reg => State_Col_reg_tb,
            Screen_reg   => Screen_reg_tb,
            Ball_reg     => Ball_reg_tb,
            Players_reg  => Players_reg_tb
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
        -- 1. Set Screen Size (MUST be done BEFORE reset)
        Screen_reg_tb <= "00000010010110000000001100100000"; -- Width = 320, Height = 160
        State_Col_reg_tb <= X"00008001"; -- Enable + NFR bit set
        Ball_reg_tb <= X"00000000";
        Players_reg_tb <= X"00780078";
        wait for 10 ns;

        -- 2. Apply Reset (AFTER screen size is set)
        reset_tb <= '1';
        wait for 20 ns;
        reset_tb <= '0';
        wait for 10 ns;

        -- 3. Enable the engine and request a frame update
        State_Col_reg_tb <= X"00008001"; -- Enable + NFR bit set
        wait for 20 ns;

        -- 4. Apply Player Positions
        Players_reg_tb <= X"00780078"; -- Both Players at Y=120
        wait for 10 ns;

        -- 5. Observe Ball Movement for Several Cycles
        for i in 0 to 20 loop
            -- Wait for the engine to process one frame
            wait for 50 ns;
            
            -- Reactivate NFR (because the engine resets it to 0)
            State_Col_reg_tb(14) <= '1';
            
            -- Wait for the next frame
            wait for 50 ns;
        end loop;

        -- 6. Simulate Ball Hitting Left Wall
        Ball_reg_tb <= X"00000010"; -- Ball near left wall
        wait for 20 ns;

        -- 7. Reactivate NFR and continue
        State_Col_reg_tb(14) <= '1';
        wait for 50 ns;

        -- 8. Simulate Ball Hitting Player 1 Paddle
        Ball_reg_tb <= X"00000020"; -- Ball near P1
        Players_reg_tb <= X"00780078"; -- P1 at Y=120
        wait for 20 ns;

        -- 9. Reactivate NFR and continue
        State_Col_reg_tb(14) <= '1';
        wait for 50 ns;

        -- 10. Simulate Ball Hitting Right Wall
        Ball_reg_tb <= X"00F00020"; -- Ball near right wall
        wait for 20 ns;

        -- 11. Reactivate NFR and continue
        State_Col_reg_tb(14) <= '1';
        wait for 50 ns;

        -- 12. Simulate Ball Hitting Player 2 Paddle
        Ball_reg_tb <= X"00F00030"; -- Ball near P2
        Players_reg_tb <= X"00780078"; -- P2 at Y=120
        wait for 20 ns;

        -- 13. Reactivate NFR and continue
        State_Col_reg_tb(14) <= '1';
        wait for 50 ns;

        -- End of test
        wait;
    end process;

end Behavioral;
