-------------------------------------------------------------------------------
-- Title      : controlUnit
-- Project    :
-------------------------------------------------------------------------------
-- File       : operativeUnit.vhd
-- Author     : Jean-Noel BAZIN  <jnbazin@pc-disi-026.enst-bretagne.fr>
-- Company    :
-- Created    : 2018-04-11
-- Last update: 2019-02-13
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Control unit of a sequential FIR filter.
-------------------------------------------------------------------------------
-- Copyright (c) 2018
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2018-04-11  1.0      jnbazin Created
-- 2025-04-09  1.1      marzel  Renamed some signals and port names to match
--                              the description of lab activity
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controlUnit is

  port (
    I_clock               : in  std_logic;  -- global clock
    I_reset               : in  std_logic;  -- asynchronous global reset
    I_inputSampleValid    : in  std_logic;  -- Control signal to load the input sample in the sample shift register and shift the register
    I_processingDone      : in  std_logic;
    O_loadShift           : out std_logic;  -- filtered sample
    O_initAddress         : out std_logic;  -- Control signal to initialize register read address
    O_incrAddress         : out std_logic;  -- Control signal to increment register read address
    O_initSum             : out std_logic;  -- Control signal to initialize the MAC register
    O_loadSum             : out std_logic;  -- Control signal to load the MAC register;
    O_loadOutput          : out std_logic;  -- Control signal to load Y register
    O_FilteredSampleValid : out std_logic  -- Data valid signal for filtered sample
    );

end entity controlUnit;
architecture archi_operativeUnit of controlUnit is


  type T_state is (WAIT_SAMPLE, STORE, PROCESSING_LOOP, OUTPUT, WAIT_END_SAMPLE);  -- state list
  signal SR_currentState : T_state;
  signal SR_nextState   : T_state;

begin

  -- Process to describe the state register
  -- Current state is provide at the output of the register
  -- and is updated with the next state at each rising edge of clock
  process (_BLANK_) is
  begin
    if I_reset = '1' then               -- asynchronous reset (active high)
      SR_currentState <= _BLANK_
    elsif rising_edge(I_clock) then     -- rising clock edge
      _BLANK_
    end if;
  end process;

  -- Combinatorial process computing the next state which depends on
  -- the current state and on the inputs
  process (_BLANK_) is
  begin
    case SR_currentState is

      when WAIT_SAMPLE =>
        _BLANK_

      when others => null;
    end case;
  end process;

  -- Rules to compute the outputs depending on the current state
  -- (and on the inputs, if you want a Mealy machine).
  O_loadShift           <= '1' when _BLANK_ else '0';
  O_initAddress         <= '1' when _BLANK_ else '0';
  O_incrAddress         <= '1' when _BLANK_ else '0';
  O_initSum             <= '1' when _BLANK_ else '0';
  O_loadSum             <= '1' when _BLANK_ else '0';
  O_loadOutput          <= '1' when _BLANK_ else '0';
  O_FilteredSampleValid <= '1' when _BLANK_ else '0';





end architecture archi_operativeUnit;
