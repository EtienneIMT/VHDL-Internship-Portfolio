-------------------------------------------------------------------------------
-- Author:      Etienne Bertin (completed academic skeleton)
-- Create Date: 2018-05-30
-- Last update: 2025-09-24 (by Etienne Bertin)
--
-- Module Name: counter
-- Project:     VHDL Portfolio (Academic Crossroads Project)
--
-- Description: 
-- This module implements the Datapath (Operative Unit) for the 
-- crossroads traffic light controller.
--
-- It is a parameterizable, dual-stage timer. It uses a wide 
-- pre-scaler counter ('pulse_counter') to generate a 1-second pulse 
-- from the fast system clock. This pulse is then used to enable 
-- a second, smaller counter ('second_counter') that decrements the
-- number of seconds specified by the FSM.
--
-- Revisions:
-- Date        Version  Author   Description
-- 2018-05-30  1.0      jnbazin  Created (skeleton file with BLANK_TO_FILL)
-- 2025-09-24  2.0      EtienneB Completed all logic sections.
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY counter IS

  GENERIC (
    -- Parameter to define system clock frequency (e.g., 100_000_000 for 100MHz)
    G_number_of_cycle_per_second : INTEGER := 1 
  );
  PORT (
    I_clk : IN STD_LOGIC; -- Global input clock
    I_rst : IN STD_LOGIC; -- Global asynchronous reset, active high
    I_init : IN STD_LOGIC; -- Synchronous initialization (from FSM)
    I_enable : IN STD_LOGIC; -- Synchronous enable (from FSM)
    I_maxCount : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- max value for the second counter (from FSM)
    O_dataOut : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- current second count
    O_done : OUT STD_LOGIC -- '1' when the second counter reaches 0
  );
END ENTITY counter;

ARCHITECTURE arch_counter OF counter IS

  -- Constant for the pre-scaler max value (e.g., 99_999_999 for a 100MHz clock)
  CONSTANT G_clockPeriodToCount : INTEGER := G_number_of_cycle_per_second - 1;

  -- Internal Signals
  SIGNAL SR_counterPulse : INTEGER RANGE 0 TO G_clockPeriodToCount; -- Pre-scaler register
  SIGNAL SC_secondPulse : STD_LOGIC; -- 1-clock-cycle pulse generated every second
  SIGNAL SR_counterSecond : INTEGER RANGE 0 TO 9; -- Second counter register

BEGIN

  -- PROCESS 1: Pre-scaler (Clock Divider)
  -- purpose: Generate a pulse every second according to the clock period.
  --
  -- [My Implementation]: Logic below was written to complete the
  -- original skeleton file.
  --
  pulse_counter : PROCESS (I_clk, I_rst) IS
  BEGIN
    -- Asynchronous reset
    IF I_rst = '1' THEN
      SR_counterPulse <= 0;
    ELSIF rising_edge(I_clk) THEN
      -- The counter increments only when enabled by the FSM (I_enable)
      IF I_enable = '1' THEN
        -- When max value is reached, roll over to 0
        IF SR_counterPulse = G_clockPeriodToCount THEN
          SR_counterPulse <= 0;
        ELSE
          -- Increment the pre-scaler
          SR_counterPulse <= SR_counterPulse + 1;
        END IF;
      END IF;
    END IF;

  END PROCESS pulse_counter;

  -- [My Implementation]: Combinatorial logic to generate the 1-second pulse.
  SC_secondPulse <= '1' WHEN SR_counterPulse = G_clockPeriodToCount AND I_rst = '0' ELSE
    '0';

  -- PROCESS 2: Second Counter (Datapath)
  -- purpose: Drives the SR_counter signal to count down.
  --
  -- [My Implementation]: Logic below was written to complete the
  -- original skeleton file.
  --
  second_counter : PROCESS (I_clk, I_rst) IS
  BEGIN
    -- Asynchronous reset
    IF I_rst = '1' THEN
      SR_counterSecond <= 0;
    ELSIF rising_edge(I_clk) THEN
      -- The FSM 'init' signal has priority and loads the timer duration
      IF I_init = '1' THEN
        SR_counterSecond <= to_integer(unsigned(I_maxCount));
      
      -- If not initializing, check for a 'decrement' command
      -- This logic ensures decrementing only happens ONCE per second.
      ELSIF I_enable = '1' AND SC_secondPulse = '1' THEN
        IF SR_counterSecond > 0 THEN
          SR_counterSecond <= SR_counterSecond - 1;
        END IF;
      END IF;
    END IF;

  END PROCESS second_counter;

  -- Concurrent Assignments (provided in skeleton)
  O_dataOut <= STD_LOGIC_VECTOR(to_unsigned(SR_counterSecond, 4));
  O_done <= '1' WHEN(SR_counterSecond = 0 AND SC_secondPulse = '1') ELSE
    '0';

END ARCHITECTURE arch_counter;