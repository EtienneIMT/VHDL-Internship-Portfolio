-------------------------------------------------------------------------------
-- Title      : counter
-- Project    :
-------------------------------------------------------------------------------
-- File       : counter.vhd
-- Author     : Jean-Noel BAZIN  <jnbazin@pc-disi-026.enst-bretagne.fr>
-- Company    :
-- Created    : 2018-05-30
-- Last update: 2020-01-27
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Programable counter used to count second before changing colors
-- on the traffic light. one counter generating a pulse for each second from
-- clock, a second counter to decount the number of second
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

ENTITY counter IS

  GENERIC (
    G_number_of_cycle_per_second : INTEGER := 1 -- number of clock cycle in one second, must be at least 1
  );
  PORT (
    I_clk : IN STD_LOGIC; -- Global input clock
    I_rst : IN STD_LOGIC; -- Global asynchronous reset, active high
    I_init : IN STD_LOGIC; -- Synchronous initialization
    I_enable : IN STD_LOGIC; -- Synchronous chip enable control s
    I_maxCount : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- max value for the counter
    O_dataOut : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- counter output value
    O_done : OUT STD_LOGIC
  );
END ENTITY counter;

ARCHITECTURE arch_counter OF counter IS

  CONSTANT G_clockPeriodToCount : INTEGER := G_number_of_cycle_per_second - 1;

  SIGNAL SR_counterPulse : INTEGER RANGE 0 TO G_clockPeriodToCount; -- Counter internal value
  SIGNAL SC_secondPulse : STD_LOGIC; -- signal raised for one clock period every second
  SIGNAL SR_counterSecond : INTEGER RANGE 0 TO 9; -- Counter internal value signal

BEGIN

  -- purpose: Generate a pulse every second according to the clock period
  -- type   : sequential
  -- inputs : I_clk, I_rst, I_init, I_enable
  -- output : SR_counterPulse
  pulse_counter : PROCESS (I_clk, I_rst) IS
  BEGIN

    IF I_rst = '1' THEN
      SR_counterPulse <= 0;
    ELSIF rising_edge(I_clk) THEN
      IF I_enable = '1' THEN
        IF SR_counterPulse = G_clockPeriodToCount THEN
          SR_counterPulse <= 0;
        ELSE
          SR_counterPulse <= SR_counterPulse + 1;
        END IF;
      END IF;
    END IF;

  END PROCESS pulse_counter;

  SC_secondPulse <= '1' WHEN SR_counterPulse = G_clockPeriodToCount AND I_rst = '0' ELSE
    '0';

  -- purpose: Drive the SR_counter signal to count according to I_init and I_incr
  -- type   : sequential
  -- inputs : I_clk, I_rst, I_init, I_enable, I_maxCount
  -- outputs: SR_counterSecond
  second_counter : PROCESS (I_clk, I_rst) IS
  BEGIN

    IF I_rst = '1' THEN
      SR_counterSecond <= 0;
    ELSIF rising_edge(I_clk) THEN
      IF I_init = '1' THEN
        SR_counterSecond <= to_integer(unsigned(I_maxCount));
      ELSIF I_enable = '1' AND SC_secondPulse = '1' THEN
        IF SR_counterSecond > 0 THEN
          SR_counterSecond <= SR_counterSecond - 1;
        END IF;
      END IF;
    END IF;

  END PROCESS second_counter;

  O_dataOut <= STD_LOGIC_VECTOR(to_unsigned(SR_counterSecond, 4));
  O_done <= '1' WHEN(SR_counterSecond = 0 AND SC_secondPulse = '1') ELSE
    '0';

END ARCHITECTURE arch_counter;