----------------------------------------------------------------------------------
-- Author:      Etienne Bertin
-- Create Date: 10/01/2025
--
-- Module Name: Ctrl_unit
-- Project:     VHDL Portfolio (Academic 8-bit CPU Project)
-- 
-- Description: 
-- This module implements the top-level Control Unit for a simple 8-bit CPU
-- designed in the TAF_SEH_UE_A_TP_GPP_2024 academic project.
--
-- This unit is described structurally, connecting all the necessary 
-- control path components:
-- 1. FSMCTRL (The core Finite State Machine, instantiated as a component)
-- 2. A 6-bit Program Counter (PC) register
-- 3. An 8-bit Instruction Register (IR) with opcode/operand splitting
-- 4. A 6-bit Address MUX
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;


--------------------------------------------------------------------------------

entity Ctrl_unit is
Port (clk  	: in std_logic;
           reset  	: in std_logic;
           -- Status input from Datapath
           C 		: in std_logic;
           -- Control signals to Datapath & Memory
           selUAL  	: out std_logic;	
           clrC  	: out std_logic;
           ldC  	: out std_logic;
           ldACCU  	: out std_logic;	
           ldR1  	: out std_logic;
           enM  	: out std_logic;
           weM  	: out std_logic;
           -- Memory Interface
           AdrOut   : out std_logic_vector(5 downto 0);		  
           DataIn   : in  std_logic_vector(7 downto 0));
end Ctrl_unit;

--------------------------------------------------------------------------------


architecture archi_Ctrl_unit of Ctrl_unit is

  -- Internal signals connecting the FSM, PC, IR, and MUX
  signal selAdr  	: std_logic;
  signal clrPC  	: std_logic;
  signal ldPC    	: std_logic;
  signal O_IR    	: std_logic_vector(5 downto 0); -- Operand/Address part of the instruction
  signal O_MUX    	: std_logic_vector(5 downto 0); -- Output of the address MUX
  signal CodeOp   	: std_logic_vector(1 downto 0); -- OpCode part of the instruction
  signal ldIR       : std_logic;
  signal incPC      : std_logic;
  signal O_PC  	    : std_logic_vector(5 downto 0); -- Output of the Program Counter

 
  -- Component definition for the core Finite State Machine (FSM)
  component FSMCTRL is
    port (
           clk  	:  in std_logic;
           reset  	:  in std_logic;
           C 		:  in std_logic;
           CodeOp  	:  in std_logic_vector(1 downto 0);	
           selUAL  	:  out std_logic;	
           clrC 
  	:  out std_logic;
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
  
  
    -- Instantiate the core FSM (the "brain" of the control unit)
    -- This component generates all control signals based on the OpCode.
    DUT : entity work.FSMCTRL
    port map (
       clk  	=> 	clk,  	
       reset  	=> 	reset,  	
       C 		=> 	C, 		
       CodeOp 	=>  CodeOp, 	-- Input to FSM
       selUAL 	=>  selUAL, 	-- Output from FSM
       clrC  	=> 	clrC,  	
       ldC 
  	=> 	ldC,  	
       ldACCU 	=>  ldACCU, 		
       ldR1  	=> 	ldR1,  	
       ldIR  	=> 	ldIR,  	-- Output from FSM, controls IR register
       ldPC  	=> 	ldPC,  	-- Output from FSM, controls PC register
       incPC  	=> 	incPC,  	-- Output from FSM, controls PC register
       clrPC  	=> 	clrPC,  	-- Output from FSM, controls PC register
       selADR 	=>  selADR, 	-- Output from FSM, controls Address MUX
       enM  	=> 	enM,  	
       weM  	=> 	weM);  	
       
        
    -- PROCESS 1: Program Counter (PC) Register
    -- This register holds the address of the next instruction to be fetched.
    -- It is a 6-bit synchronous register with reset, clear, load (for jumps), 
    -- and increment (for sequential execution) capabilities, all driven by the FSM.
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then    -- Synchronous reset
                O_PC <= "000000";
            elsif clrPC = '1' then -- Clear PC (not used in final FSM, but good practice)
                O_PC <= "000000";
            elsif ldPC = '1' then  -- Load new address (for JCC instruction)
                O_PC <= O_IR;
            elsif incPC = '1' then -- Increment to next instruction (Fetch cycle)
                O_PC <= std_logic_vector(unsigned(O_PC) + 1);
            end if;
        end if;
    end process;
       
          
       
    -- PROCESS 2: Address MUX (Combinatorial)
    -- This MUX selects the address to be sent to memory (AdrOut).
    -- selADR = '1': Selects the Program Counter (O_PC) for instruction fetching.
    -- selADR = '0': Selects the Instruction Register (O_IR) for data access (e.g., STA, ADD, NOR).
     process (selADR, O_PC, O_IR)
     begin
     if selADR = '1' then
        O_MUX <= O_PC;
     else
        O_MUX <= O_IR;
     end if;
     end process;
     
     
     
    -- PROCESS 3: Instruction Register (IR) and OpCode Splitter
    -- This register latches the instruction (DataIn) read from memory when ldIR is high (Fetch cycle).
    -- It also splits the 8-bit instruction into:
    -- 1. CodeOp (7 downto 6): The 2-bit operation code, sent to the FSM.
    -- 2. O_IR (5 downto 0):   The 6-bit operand/address, used by PC (for jumps) or MUX (for data).
      process(clk)
      begin
     
      if rising_edge(clk) then
        if reset = '1' then
           CodeOp <= "00";
           O_IR <= "000000";
        elsif ldIR = '1' then
            CodeOp <= DataIn(7 downto 6); -- Split OpCode
            O_IR <= DataIn(5 downto 0); -- Split Operand/Address
        end if;
      end if;
            
      end process;
      

-- Concurrent Assignment: Connect the MUX output to the main address port
AdrOut <= O_MUX;
 
 
 end architecture archi_Ctrl_unit;
