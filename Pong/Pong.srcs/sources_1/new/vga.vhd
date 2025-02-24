----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/24/2025 02:18:27 PM
-- Design Name: 
-- Module Name: vga - Behavioral
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


library ieee;
use ieee.std_logic_1164.all;

entity vga is
port( A : in std_logic;
    B : in std_logic;
    S : out std_logic;
    C : out std_logic );
end vga;

architecture dataflow of vga is
begin
    S <= (A and not B ) or (not A and B );
    C <= (A and B );
end dataflow;
