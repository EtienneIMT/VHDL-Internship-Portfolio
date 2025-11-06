----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/07/2025 02:54:42 PM
-- Design Name: 
-- Module Name: tb_cpu8bits - Behavioral
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

entity tb_cpu8bits is
--  Port ( );
end tb_cpu8bits;

architecture Behavioral of tb_cpu8bits is

    component cpu8bits is
    port(
        clk     : in  std_logic;
        reset    : in  std_logic;
		ADR_pin : OUT std_logic_vector(5 downto 0);
		DataOut_pin : OUT std_logic_vector(7 downto 0)
  
    );
    end component cpu8bits;	
 
   
  signal S_clk  	: std_logic := '1';
  signal S_reset  	: std_logic;
  signal ADR      : std_logic_vector(5 downto 0);
  signal DataInM  : std_logic_vector(7 downto 0);
  
   
begin


DUT : entity work.cpu8bits

    port map(
    
    clk => S_clk,
    reset => S_reset,
    ADR_pin => ADR,
	DataOut_pin => DataInM
	);
	
	
-- clock generation 
S_clk     <= not S_clk after 5 ns;

-- input test vector
S_reset   <= '1', '0' after 32 ns;


end Behavioral;
