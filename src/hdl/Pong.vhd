--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
--Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2024.1 (lin64) Build 5076996 Wed May 22 18:36:09 MDT 2024
--Date        : Mon Mar 24 16:35:59 2025
--Host        : pop-os running 64-bit Pop!_OS 22.04 LTS
--Command     : generate_target mb_design_wrapper.bd
--Design      : mb_design_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity Pong is
  port (
    clk_in1 : in STD_LOGIC;
    j1_cs : out STD_LOGIC;
    j1_miso : in STD_LOGIC;
    j1_mosi : out STD_LOGIC;
    j1_sclk : out STD_LOGIC;
    j2_cs : out STD_LOGIC;
    j2_miso : in STD_LOGIC;
    j2_mosi : out STD_LOGIC;
    j2_sclk : out STD_LOGIC;
    reset : in STD_LOGIC
  );
end Pong;

architecture STRUCTURE of Pong is
  component mb_design is
  port (
    clk_in1 : in STD_LOGIC;
    reset : in STD_LOGIC;
    j1_cs : out STD_LOGIC;
    j1_sclk : out STD_LOGIC;
    j1_mosi : out STD_LOGIC;
    j2_cs : out STD_LOGIC;
    j2_mosi : out STD_LOGIC;
    j2_sclk : out STD_LOGIC;
    j1_miso : in STD_LOGIC;
    j2_miso : in STD_LOGIC
  );
  end component mb_design;
begin
mb_design_i: component mb_design
     port map (
      clk_in1 => clk_in1,
      j1_cs => j1_cs,
      j1_miso => j1_miso,
      j1_mosi => j1_mosi,
      j1_sclk => j1_sclk,
      j2_cs => j2_cs,
      j2_miso => j2_miso,
      j2_mosi => j2_mosi,
      j2_sclk => j2_sclk,
      reset => reset
    );
end STRUCTURE;
