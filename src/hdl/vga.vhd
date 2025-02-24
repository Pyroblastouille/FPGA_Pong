library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga is
    generic(
        H_sync_polarity: std_logic := '1';
        V_sync_polarity: std_logic := '1';
        H_Visible      : integer := 1280;
        H_Front_porch  : integer := 16;
        H_Sync_pulse   : integer := 144;
        H_Back_porch   : integer := 248;
        V_Visible      : integer := 1024;
        V_Front_porch  : integer := 1;
        V_Sync_pulse   : integer := 3;
        V_Back_porch   : integer := 38
    );
    port (
        clk      : in std_logic;
        rst      : in std_logic;
        Hcount   : out std_logic_vector(12 downto 0);
        Vcount   : out std_logic_vector(12 downto 0);
        H_sync   : out std_logic;
        V_sync   : out std_logic;
        blank    : out std_logic;
        frame    : out std_logic
    );
end vga;

architecture Behavioral of vga is
    constant H_total : signed(15 downto 0) := to_signed(H_Visible + H_Front_porch + H_Sync_pulse + H_Back_porch, 16);
    constant V_total : signed(15 downto 0) := to_signed(V_Visible + V_Front_porch + V_Sync_pulse + V_Back_porch, 16);

    signal H_counter : signed(15 downto 0) := (others => '0');
    signal V_counter : signed(15 downto 0) := (others => '0');

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                H_counter <= (others => '0');
                V_counter <= (others => '0');
            else
                -- Horizontal counter
                if H_counter = H_total - 1 then
                    H_counter <= (others => '0');
                    -- Increment vertical counter on each new line
                    if V_counter = V_total - 1 then
                        V_counter <= (others => '0');
                    else
                        V_counter <= V_counter + 1;
                    end if;
                else
                    H_counter <= H_counter + 1;
                end if;
            end if;
        end if;
    end process;

    -- Generate horizontal and vertical sync signals
    H_sync <= H_sync_polarity when (to_integer(H_counter) >= H_Visible + H_Front_porch and to_integer(H_counter) < H_Visible + H_Front_porch + H_Sync_pulse) else not H_sync_polarity;
    V_sync <= V_sync_polarity when (to_integer(V_counter) >= V_Visible + V_Front_porch and to_integer(V_counter) < V_Visible + V_Front_porch + V_Sync_pulse) else not V_sync_polarity;

    -- Output counters for pixel position
    Hcount <= std_logic_vector(to_unsigned(to_integer(H_counter), Hcount'length));
    Vcount <= std_logic_vector(to_unsigned(to_integer(V_counter), Vcount'length));

    -- Generate blanking signal: 0 during visible area, 1 otherwise
    blank <= '0' when (to_integer(H_counter) < H_Visible and to_integer(V_counter) < V_Visible) else '1';

    -- Frame signal to indicate start of a new frame
    frame <= '1' when (H_counter = H_total-1 and V_counter = V_total-1) else '0';
end Behavioral;
