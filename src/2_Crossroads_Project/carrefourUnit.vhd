-------------------------------------------------------------------------------
-- Title      : carrefourUnit
-- Project    :
-------------------------------------------------------------------------------
-- File       : carrefourUnit.vhd
-- Author     : Jean-Noel BAZIN  <jnbazin@pc-disi-026.enst-bretagne.fr>
-- Company    :
-- Created    : 2018-05-30
-- Last update: 2020-01-27
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Connection between the counter and the FSM
-------------------------------------------------------------------------------
-- Copyright (c) 2018
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2018-05-30  1.0      jnbazin Created
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY carrefourUnit IS

  GENERIC (
    G_number_of_cycle_per_second : INTEGER := 2 -- number of clock cycles in one second, small value for test,  50 000 000 for 50MHz clock onboard
  );

  PORT (
    I_clk : IN STD_LOGIC; -- Global clock
    I_rst : IN STD_LOGIC; -- Global asynchronous active high reset
    I_presence : IN STD_LOGIC; -- A vehicule is present on the track
    O_led : OUT STD_LOGIC_VECTOR(5 DOWNTO 0); -- drive the leds of the traffic light the signal has the format  :  RV & RO & RR & CV & CO & CR
    O_dataOut : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)); -- Output counter value

END ENTITY carrefourUnit;

ARCHITECTURE archi_carrefourUnit OF carrefourUnit IS
  --component fsmMealy is
  --  port (
  --    I_clk         : in  std_logic;
  --    I_rst         : in  std_logic;
  --    I_timerDone   : in  std_logic;
  --    I_presence    : in  std_logic;
  --    O_led         : out std_logic_vector(5 downto 0);
  --    O_maxCount    : out std_logic_vector(3 downto 0);
  --    O_initTimer   : out std_logic;
  --    O_enableTimer : out std_logic);
  --end component fsmMealy;

  COMPONENT fsmMoore IS
    PORT (
      I_clk : IN STD_LOGIC;
      I_rst : IN STD_LOGIC;
      I_timerDone : IN STD_LOGIC;
      I_presence : IN STD_LOGIC;
      O_led : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
      O_maxCount : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      O_initTimer : OUT STD_LOGIC;
      O_enableTimer : OUT STD_LOGIC);
  END COMPONENT fsmMoore;

  COMPONENT counter IS
    GENERIC (
      G_number_of_cycle_per_second : INTEGER := 1 -- number of clock cycle in
    ); -- one second
    PORT (
      I_clk : IN STD_LOGIC;
      I_rst : IN STD_LOGIC;
      I_init : IN STD_LOGIC;
      I_enable : IN STD_LOGIC;
      I_maxCount : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      O_dataOut : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      O_done : OUT STD_LOGIC);
  END COMPONENT counter;

  SIGNAL SC_timerDone : STD_LOGIC;
  SIGNAL SC_maxCount : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL SC_initTimer : STD_LOGIC;
  SIGNAL SC_enableTimer : STD_LOGIC;

BEGIN -- architecture archi_carrefourUnit

  fsm_1 : fsmMoore
  PORT MAP(
    I_clk => I_clk,
    I_rst => I_rst,
    I_timerDone => SC_timerDone,
    I_presence => I_presence,
    O_led => O_led,
    O_maxCount => SC_maxCount,
    O_initTimer => SC_initTimer,
    O_enableTimer => SC_enableTimer);

  counter_1 : counter
  GENERIC MAP(
    G_number_of_cycle_per_second => G_number_of_cycle_per_second
  )
  PORT MAP(
    I_clk => I_clk,
    I_rst => I_rst,
    I_init => SC_initTimer,
    I_enable => SC_enableTimer,
    I_maxCount => SC_maxCount,
    O_dataOut => O_dataOut,
    O_done => SC_timerDone);

END ARCHITECTURE archi_carrefourUnit;