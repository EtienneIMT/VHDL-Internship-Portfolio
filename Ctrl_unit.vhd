----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/01/2025 03:53:54 PM
-- Design Name: 
-- Module Name: Ctrl_unit - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
--any Xilinx leaf cells in this code.

library UNISIM;
use UNISIM.VComponents.all;


--------------------------------------------------------------------------------

entity Ctrl_unit is
Port (clk  	: in std_logic;
           reset  	: in std_logic;
           C 		: in std_logic;
           selUAL  	: out std_logic;	
           clrC  	: out std_logic;
           ldC  	: out std_logic;
           ldACCU  	: out std_logic;	
           ldR1  	: out std_logic;
           enM  	: out std_logic;
           weM  	: out std_logic;
           AdrOut   : out std_logic_vector(5 downto 0);		  
           DataIn   : in  std_logic_vector(7 downto 0));
end Ctrl_unit;

--------------------------------------------------------------------------------


architecture archi_Ctrl_unit of Ctrl_unit is

  -- component ports
  signal selAdr  	: std_logic;
  signal clrPC  	: std_logic;
  signal ldPC    	: std_logic;
  signal O_IR    	: std_logic_vector(5 downto 0);
  signal O_MUX    	: std_logic_vector(5 downto 0);
  signal CodeOp   	: std_logic_vector(1 downto 0);
  signal ldIR       : std_logic;
  signal incPC      : std_logic;
  signal O_PC  	    : std_logic_vector(5 downto 0);

 
    
  component FSMCTRL is
    port (
           clk  	:  in std_logic;
           reset  	:  in std_logic;
           C 		:  in std_logic;
           CodeOp  	:  in std_logic_vector(1 downto 0);	
           selUAL  	:  out std_logic;	
           clrC  	:  out std_logic;
           ldC  	:  out std_logic;
           ldACCU  	:  out std_logic;	
           ldR1  	:  out std_logic;
           ldIR  	:  out std_logic;
           ldPC  	:  out std_logic;
           incPC  	:  out std_logic;
           clrPC  	:  out std_logic;
           selADR  	:  out std_logic;	
           enM  	:  out std_logic;
           weM  	:  out std_logic	
	);
  end component FSMCTRL;

--------------------------------------------------------------------------------


begin
  
  
    -- component instantiation
  DUT : entity work.FSMCTRL
    port map (
       clk  	=> 	clk,  	
       reset  	=> 	reset,  	
       C 		=> 	C, 		
       CodeOp 	=>  CodeOp, 		
       selUAL 	=>  selUAL, 		
       clrC  	=> 	clrC,  	
       ldC  	=> 	ldC,  	
       ldACCU 	=>  ldACCU, 		
       ldR1  	=> 	ldR1,  	
       ldIR  	=> 	ldIR,  	
       ldPC  	=> 	ldPC,  	
       incPC  	=> 	incPC,  	
       clrPC  	=> 	clrPC,  	
       selADR 	=>  selADR, 		
       enM  	=> 	enM,  	
       weM  	=> 	weM);  	
       
        
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then    -- synchronous reset (active high)
                O_PC <= "000000";
            elsif clrPC = '1' then
                O_PC <= "000000";
            elsif ldPC = '1' then 
                O_PC <= O_IR;
            elsif incPC = '1' then 
                O_PC <= std_logic_vector(unsigned(O_PC) + 1);
            end if;
        end if;
    end process;
       
          
       
     process (selADR, O_PC, O_IR)
     begin
     if selADR = '1' then
        O_MUX <= O_PC;
     else
        O_MUX <= O_IR;
     end if;
     end process;
     
    
      
      
      process(clk)
      begin
     
      if rising_edge(clk) then
        if reset = '1' then
           CodeOp <= "00";
           O_IR <= "000000";
        elsif ldIR = '1' then
            CodeOp <= DataIn(7 downto 6);
            O_IR <= DataIn(5 downto 0);
        end if;
      end if;
            
      end process;
      

AdrOut <= O_MUX;
 
 
 end architecture archi_Ctrl_unit;
 

