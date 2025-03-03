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
        C_AXI_ADDR_WIDTH : integer := 32;
        C_AXI_DATA_WIDTH : integer := 32;
        C_ADDR_WIDTH : integer := 32;
        C_DATA_WIDTH : integer := 32);
    port(
    
    
    -- ######################### --
    -- AXI4-Lite INTERFACE       --
    -- ######################### --
    s_axi_aclk      : in  std_logic;
    s_axi_aresetn   : in  std_logic;
    -- AXI4-Lite Write interface
    s_axi_awaddr    : in  std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
    s_axi_awvalid   : in  std_logic;
    s_axi_awready   : out std_logic;
    s_axi_wdata     : in  std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
    s_axi_wstrb     : in  std_logic_vector(C_AXI_DATA_WIDTH/8-1 downto 0);
    s_axi_wvalid    : in  std_logic;
    s_axi_wready    : out std_logic;
    s_axi_bresp     : out std_logic_vector(1 downto 0);
    s_axi_bvalid    : out std_logic;
    s_axi_bready    : in  std_logic;
    -- AXI4-Lite Read interface
    s_axi_araddr    : in  std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
    s_axi_arvalid   : in  std_logic;
    s_axi_arready   : out std_logic;
    s_axi_rdata     : out std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
    s_axi_rresp     : out std_logic_vector(1 downto 0);
    s_axi_rvalid    : out std_logic;
    s_axi_rready    : in  std_logic;
    
    -- ######################### --
    -- Joystick
    -- ######################### --
    
    joy_1_x       : out STD_LOGIC_VECTOR(9 downto 0); -- Joystick X position
    joy_1_y       : out STD_LOGIC_VECTOR(9 downto 0); -- Joystick Y position
    joy_1_btn_trigger : out STD_LOGIC; -- Trigger button state
    joy_1_btn_joystick: out STD_LOGIC;  -- Joystick button state
    
    joy_2_x       : out STD_LOGIC_VECTOR(9 downto 0); -- Joystick X position
    joy_2_y       : out STD_LOGIC_VECTOR(9 downto 0); -- Joystick Y position
    joy_2_btn_trigger : out STD_LOGIC; -- Trigger button state
    joy_2_btn_joystick: out STD_LOGIC;  -- Joystick button state
    
    -- ######################### --
    -- PMOD out
    -- ######################### --
     
    miso_1 : in STD_LOGIC;
    miso_2 : in STD_LOGIC;
    mosi_1 : out STD_LOGIC;
    mosi_2 : out STD_LOGIC;
    sclk_1 : out STD_LOGIC;
    sclk_2 : out STD_LOGIC;
    ss_1 : out STD_LOGIC;
    ss_2 : out STD_LOGIC
    
    );
end JoystickGrabber;

architecture Behavioral of JoystickGrabber is


  ---------------------------------------------------------------------------------
  -- AXI4-Lite interface
  ---------------------------------------------------------------------------------
  component axi4lite_if is
    generic (
      C_DATA_WIDTH : integer := 32;
      C_ADDR_WIDTH : integer := 4
      );
    port (
      s_axi_aclk    : in  std_logic;
      s_axi_aresetn : in  std_logic;
      s_axi_awaddr  : in  std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
      s_axi_awvalid : in  std_logic;
      s_axi_awready : out std_logic;
      s_axi_wdata   : in  std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
      s_axi_wstrb   : in  std_logic_vector(C_AXI_DATA_WIDTH/8-1 downto 0);
      s_axi_wvalid  : in  std_logic;
      s_axi_wready  : out std_logic;
      s_axi_bresp   : out std_logic_vector(1 downto 0);
      s_axi_bvalid  : out std_logic;
      s_axi_bready  : in  std_logic;
      s_axi_araddr  : in  std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
      s_axi_arvalid : in  std_logic;
      s_axi_arready : out std_logic;
      s_axi_rdata   : out std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
      s_axi_rresp   : out std_logic_vector(1 downto 0);
      s_axi_rvalid  : out std_logic;
      s_axi_rready  : in  std_logic;
      wr_valid_o    : out std_logic;
      wr_addr_o     : out std_logic_vector((C_ADDR_WIDTH - 1) downto 0);
      wr_data_o     : out std_logic_vector((C_DATA_WIDTH - 1) downto 0);
      rd_valid_o    : out std_logic;
      rd_addr_o     : out std_logic_vector((C_ADDR_WIDTH - 1) downto 0);
      rd_data_i     : in  std_logic_vector((C_DATA_WIDTH - 1) downto 0));
  end component axi4lite_if;
  
  signal wr_valid_o    : std_logic;
  signal wr_addr_o     : std_logic_vector((C_ADDR_WIDTH - 1) downto 0);
  signal wr_data_o     : std_logic_vector((C_DATA_WIDTH - 1) downto 0);
  signal rd_valid_o    : std_logic;
  signal rd_addr_o     : std_logic_vector((C_ADDR_WIDTH - 1) downto 0);
  signal rd_data_i     : std_logic_vector((C_DATA_WIDTH - 1) downto 0);
  
  ---------------------------------------------------------------------------------
  -- Joystick 
  ---------------------------------------------------------------------------------
  
  

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
        cs        : out STD_LOGIC  -- Chip Select (active low)
    );   
end component spi_pmodjstk2_if;

    signal joy_1_request: std_logic := '0';
    signal joy_2_request: std_logic := '0';
    signal joy_1_busy : std_logic := '0';
    signal joy_2_busy : std_logic := '0';
    
    
    signal joy_1_data_in : std_logic_vector(39 downto 0) := (others=> '0');
    signal joy_1_data_out: std_logic_vector(39 downto 0) := (others => '0');
    signal joy_2_data_in : std_logic_vector(39 downto 0) := (others=> '0');
    signal joy_2_data_out: std_logic_vector(39 downto 0) := (others => '0');
    
  -- Internal state machine
  type state_type is (ASK_J1,WAIT_J1,ASK_J2,WAIT_J2);
  signal state : state_type := ASK_J1;
begin

  ---------------------------------------------------------------------------------
  -- AXI4-Lite interface
  ---------------------------------------------------------------------------------
  axi4lite_if_i : axi4lite_if
    generic map (
      C_DATA_WIDTH => C_DATA_WIDTH,
      C_ADDR_WIDTH => C_ADDR_WIDTH
      )
    port map (
      s_axi_aclk    => s_axi_aclk,
      s_axi_aresetn => s_axi_aresetn,
      s_axi_awaddr  => s_axi_awaddr,
      s_axi_awvalid => s_axi_awvalid,
      s_axi_awready => s_axi_awready,
      s_axi_wdata   => s_axi_wdata,
      s_axi_wstrb   => s_axi_wstrb,
      s_axi_wvalid  => s_axi_wvalid,
      s_axi_wready  => s_axi_wready,
      s_axi_bresp   => s_axi_bresp,
      s_axi_bvalid  => s_axi_bvalid,
      s_axi_bready  => s_axi_bready,
      s_axi_araddr  => s_axi_araddr,
      s_axi_arvalid => s_axi_arvalid,
      s_axi_arready => s_axi_arready,
      s_axi_rdata   => s_axi_rdata,
      s_axi_rresp   => s_axi_rresp,
      s_axi_rvalid  => s_axi_rvalid,
      s_axi_rready  => s_axi_rready,
      wr_valid_o    => wr_valid_o,
      wr_addr_o     => wr_addr_o,
      wr_data_o     => wr_data_o,
      rd_valid_o    => rd_valid_o,
      rd_addr_o     => rd_addr_o,
      rd_data_i     => rd_data_i
      );


  ---------------------------------------------------------------------------------
  -- Joystick 
  ---------------------------------------------------------------------------------
  
  joystick_1 : spi_pmodjstk2_if
    generic map (
      DATA_WIDTH => 40
      )
    port map(
        clk         => s_axi_aclk  ,
        nrst        => s_axi_aresetn  ,
        start       => joy_1_request  ,
        data_in     => joy_1_data_in ,
        data_out    => joy_1_data_out  ,
        busy        => joy_1_busy ,
        sclk        => sclk_1 ,
        mosi        => mosi_1 ,
        miso        => miso_1 ,
        cs          => ss_1
        );
        
  joystick_2 : spi_pmodjstk2_if
    generic map (
      DATA_WIDTH => 40
      )
    port map(
        clk         => s_axi_aclk  ,
        nrst        => s_axi_aresetn  ,
        start       => joy_2_request  ,
        data_in     => joy_2_data_in ,
        data_out    => joy_2_data_out  ,
        busy        => joy_2_busy ,
        sclk        => sclk_2 ,
        mosi        => mosi_2 ,
        miso        => miso_2 ,
        cs          => ss_2
        );
        
    get_data: process(s_axi_aclk,s_axi_aresetn)
        constant CMD_GET : std_logic_vector(39 downto 0) := (x"F000000000");
    begin   
        if(s_axi_aresetn = '0') then
            joy_1_x <= (9 => '1',others => '0') ;
            joy_1_y <= (9 => '1',others => '0') ;
            joy_1_btn_trigger <= '0';
            joy_1_btn_joystick<= '0';
            joy_1_request <= '0';
            
            joy_2_x <= (9 => '1',others => '0') ;
            joy_2_y <= (9 => '1',others => '0') ;
            joy_2_btn_trigger <= '0';
            joy_2_btn_joystick<= '0';
            joy_2_request <= '0';
        elsif(rising_edge(s_axi_aclk)) then
             case state is
                when ASK_J1 =>
                    joy_1_data_in <= CMD_GET;--cmd to send;
                    if(joy_1_busy = '0') then
                        joy_1_request <= '1';
                        state <= WAIT_J1;
                     end if;
                when WAIT_J1 =>
                    if (joy_1_busy = '0') then
                        -- Extract Data --
                        joy_1_x <= joy_1_data_out(25 downto 24) & joy_1_data_out(39 downto 32);
                        joy_1_y <= joy_1_data_out(9 downto 8) & joy_1_data_out(23 downto 16);
                        joy_1_btn_trigger <= joy_1_data_out(1);
                        joy_1_btn_joystick <= joy_1_data_out(0); 
                        -- Next State
                        state <= ASK_J2;
                    end if;
                when ASK_J2 =>
                    joy_2_data_in <= CMD_GET;--cmd to send;
                    if(joy_2_busy = '0') then
                        joy_2_request <= '1';
                        state <= WAIT_J2;
                     end if;
                when WAIT_J2 =>
                    if (joy_2_busy = '0') then
                        -- Extract Data --
                        joy_2_x <= joy_2_data_out(25 downto 24) & joy_2_data_out(39 downto 32);
                        joy_2_y <= joy_2_data_out(9 downto 8) & joy_2_data_out(23 downto 16);
                        joy_2_btn_trigger <= joy_2_data_out(1);
                        joy_2_btn_joystick <= joy_2_data_out(0); 
                        -- Next State
                        state <= ASK_J1;
                    end if;
                when others =>
                    state <= ASK_J1;
            end case;          
        end if;
            
        
    end process get_data;
        
  
end Behavioral;
