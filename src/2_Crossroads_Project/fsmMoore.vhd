-------------------------------------------------------------------------------
-- Author:      Etienne Bertin (completed academic skeleton)
-- Create Date: 2018-05-30
-- Last update: 2025-09-24 (by Etienne Bertin)
--
-- Module Name: fsmMoore
-- Project:     VHDL Portfolio (Academic Crossroads Project)
--
-- Description: 
-- This module implements the Control Unit for the crossroads traffic light
-- controller. It is a 14-state Moore FSM that manages the light
-- sequence based on timers and a vehicle presence sensor.
--
-- It follows a robust 3-process methodology (State Register, 
-- Next-State Logic, and Output Logic).
--
-- Revisions:
-- Date        Version  Author   Description
-- 2018-05-30  1.0      jnbazin  Created (skeleton file with BLANK_TO_FILL)
-- 2025-09-24  2.0      EtienneB Completed all logic sections.
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fsmMoore IS
  PORT (
    I_clk : IN STD_LOGIC; -- Global clock
    I_rst : IN STD_LOGIC; -- Global asynchronous active high reset
    I_timerDone : IN STD_LOGIC; -- Indicates the timer is done
    I_presence : IN STD_LOGIC; -- A vehicule is present on the track
    O_led : OUT STD_LOGIC_VECTOR(5 DOWNTO 0); -- Drives the leds. Format: RV,RO,RR,CV,CO,CR
    O_maxCount : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- Indicates to the timer the time to count
    O_initTimer : OUT STD_LOGIC; -- Initializes the timer
    O_enableTimer : OUT STD_LOGIC); -- Enables timer processing

END ENTITY fsmMoore;

ARCHITECTURE archi_fsmMoore OF fsmMoore IS

  -- Timer duration constants (in seconds)
  CONSTANT CST_TimerRV : INTEGER := 9; -- Number of second the road light should remain green
  CONSTANT CST_TimerROCO : INTEGER := 3; -- Number of second the road or path light remains orange
  CONSTANT CST_TimerCV : INTEGER := 7; -- Number of second the path light remains green
  CONSTANT CST_TimerSECU : INTEGER := 2; -- Number of second both lights remain red (security)

  -- LED state constants (Road/Path, Green/Orange/Red)
  CONSTANT CST_RRCR : STD_LOGIC_VECTOR(5 DOWNTO 0) := "001001"; -- Road:Red, Path:Red
  CONSTANT CST_ROCR : STD_LOGIC_VECTOR(5 DOWNTO 0) := "010001"; -- Road:Orange, Path:Red
  CONSTANT CST_RVCR : STD_LOGIC_VECTOR(5 DOWNTO 0) := "100001"; -- Road:Green, Path:Red
  CONSTANT CST_RRCV : STD_LOGIC_VECTOR(5 DOWNTO 0) := "001100"; -- Road:Red, Path:Green
  CONSTANT CST_RRCO : STD_LOGIC_VECTOR(5 DOWNTO 0) := "001010"; -- Road:Red, Path:Orange

  -- Type definition for the 14 FSM states
  TYPE T_state IS (INIT, RRCR1_Init,
    RRCR1_Count, RVCR1_Init,
    RVCR1_Count, RVCR2,
    ROCR_Init, ROCR_Count,
    RRCR2_Init, RRCR2_Count,
    RRCV_Init, RRCV_Count,
    RRCO_Init, RRCO_Count); -- List of states

  -- FSM state signals
  SIGNAL SR_presentState : T_state; -- Signal for the present state (registered)
  SIGNAL SC_futurState : T_state; -- Signal for the next state (combinatorial)
  
  -- Internal signal for timer value
  SIGNAL SC_maxCountInt : INTEGER RANGE 0 TO 9; -- Signal indicating the max value for second counter
  
BEGIN

  -- PROCESS 1: State Register (Sequential)
  -- This process registers the next state (SC_futurState) into the 
  -- current state (SR_presentState) on each rising clock edge.
  PROCESS (I_clk, I_rst) IS
  BEGIN
    IF I_rst = '1' THEN -- Asynchronous reset
      SR_presentState <= INIT;
    ELSIF rising_edge(I_clk) THEN -- Synchronous state update
      SR_presentState <= SC_futurState;
    END IF;
  END PROCESS;


  -- PROCESS 2: Next-State Logic (Combinatorial)
  -- Computes the next state based on the current state and inputs.
  --
  -- [My Implementation]: This entire CASE statement logic was
  -- written to complete the original skeleton file.
  --
  PROCESS (SR_presentState, I_timerDone, I_presence) IS
  BEGIN
    CASE SR_presentState IS

      WHEN INIT =>
        SC_futurState <= RRCR1_Init; -- Go to first security red-red state

      WHEN RRCR1_Init =>
        SC_futurState <= RRCR1_Count; -- Unconditional transition to counting state

      WHEN RRCR1_Count =>
        -- Wait here until the 2-second security timer is done
        IF I_timerDone = '1' THEN
          SC_futurState <= RVCR1_Init; -- Move to Green for Road
        ELSE
          SC_futurState <= RRCR1_Count; -- Hold state while timer is running
        END IF;

      WHEN RVCR1_Init =>
        SC_futurState <= RVCR1_Count; -- Go to counting state

      WHEN RVCR1_Count =>
        -- Wait for the minimum Road-Green timer to finish
        IF I_timerDone = '1' THEN
          SC_futurState <= RVCR2; -- Move to the "wait for car" state
        ELSE
          SC_futurState <= RVCR1_Count;
        END IF;

      WHEN RVCR2 =>
        -- Main waiting state. Stay Road-Green indefinitely
        -- until a car is detected on the secondary path.
        IF I_presence = '1' THEN
          SC_futurState <= ROCR_Init; -- Car detected, start transition to red
        ELSE
          SC_futurState <= RVCR2; -- No car, stay green
        END IF;

      WHEN ROCR_Init =>
        SC_futurState <= ROCR_Count; -- Go to counting state

      WHEN ROCR_Count =>
        -- Wait for Road-Orange timer to finish
        IF I_timerDone = '1' THEN
          SC_futurState <= RRCR2_Init; -- Move to second security red-red state
        ELSE
          SC_futurState <= ROCR_Count;
        END IF;

      WHEN RRCR2_Init =>
        SC_futurState <= RRCR2_Count; -- Go to counting state

      WHEN RRCR2_Count =>
        -- Wait for 2-second security timer
        IF I_timerDone = '1' THEN
          SC_futurState <= RRCV_Init; -- Move to Green for Path
        ELSE
          SC_futurState <= RRCR2_Count;
        END IF;

      WHEN RRCV_Init =>
        SC_futurState <= RRCV_Count; -- Go to counting state

      WHEN RRCV_Count =>
        -- Wait for Path-Green timer
        IF I_timerDone = '1' THEN
          SC_futurState <= RRCO_Init; -- Move to Path-Orange
        ELSE
          SC_futurState <= RRCV_Count;
        END IF;

      WHEN RRCO_Init =>
        SC_futurState <= RRCO_Count; -- Go to counting state

      WHEN RRCO_Count =>
        -- Wait for Path-Orange timer
        IF I_timerDone = '1' THEN
          SC_futurState <= RRCR1_Init; -- Loop back to the start of the cycle
        ELSE
          SC_futurState <= RRCO_Count;
        END IF;

    END CASE;
  END PROCESS;


  -- PROCESS 3: Output Logic (Combinatorial - Moore)
  -- Defines the FSM's outputs based *only* on the current state.
  --
  -- [My Implementation]: This logic (default values and CASE statement)
  -- was written to complete the original skeleton file.
  --
  PROCESS (SR_presentState)
  BEGIN

    -- Default values: This is a safe state (all red) and timers disabled.
    -- All states will override these defaults as needed.
    O_initTimer <= '0';
    O_enableTimer <= '0';
    SC_maxCountInt <= CST_TimerSECU;
    O_led <= CST_RRCR;

    CASE SR_presentState IS
      -- State 1: Both Red (Security Period 1)
      WHEN RRCR1_Init =>
        O_initTimer <= '1'; -- Load the security timer
        SC_maxCountInt <= CST_TimerSECU;
        O_led <= CST_RRCR;

      WHEN RRCR1_Count =>
        O_enableTimer <= '1'; -- Run the security timer
        SC_maxCountInt <= CST_TimerSECU;
        O_led <= CST_RRCR;

      -- State 2: Road Green (Minimum Time)
      WHEN RVCR1_Init =>
        O_initTimer <= '1'; -- Load the Road-Green timer
        SC_maxCountInt <= CST_TimerRV;
        O_led <= CST_RVCR; -- Light: Road Green, Path Red

      WHEN RVCR1_Count =>
        O_enableTimer <= '1'; -- Run the Road-Green timer
        SC_maxCountInt <= CST_TimerRV;
        O_led <= CST_RVCR;

      -- State 3: Road Green (Waiting for Car)
      WHEN RVCR2 =>
        O_enableTimer <= '1'; -- Keep timer "running" (it's already 0, but shows presence check)
        SC_maxCountInt <= CST_TimerRV;
        O_led <= CST_RVCR;

      -- State 4: Road Orange
      WHEN ROCR_Init =>
        O_initTimer <= '1'; -- Load the Road-Orange timer
        SC_maxCountInt <= CST_TimerROCO;
        O_led <= CST_ROCR; -- Light: Road Orange, Path Red

      WHEN ROCR_Count =>
        O_enableTimer <= '1'; -- Run the Road-Orange timer
        SC_maxCountInt <= CST_TimerROCO;
        O_led <= CST_ROCR;

      -- State 5: Both Red (Security Period 2)
      WHEN RRCR2_Init =>
        O_initTimer <= '1'; -- Load the security timer
        SC_maxCountInt <= CST_TimerSECU;
        O_led <= CST_RRCR;

      WHEN RRCR2_Count =>
        O_enableTimer <= '1'; -- Run the security timer
        SC_maxCountInt <= CST_TimerSECU;
        O_led <= CST_RRCR;

      -- State 6: Path Green
      WHEN RRCV_Init =>
        O_initTimer <= '1'; -- Load the Path-Green timer
        SC_maxCountInt <= CST_TimerCV;
        O_led <= CST_RRCV; -- Light: Road Red, Path Green

      WHEN RRCV_Count =>
        O_enableTimer <= '1'; -- Run the Path-Green timer
        SC_maxCountInt <= CST_TimerCV;
        O_led <= CST_RRCV;

      -- State 7: Path Orange
      WHEN RRCO_Init =>
        O_initTimer <= '1'; -- Load the Path-Orange timer
        SC_maxCountInt <= CST_TimerROCO;
        O_led <= CST_RRCO; -- Light: Road Red, Path Orange

      WHEN RRCO_Count =>
        O_enableTimer <= '1'; -- Run the Path-Orange timer
        SC_maxCountInt <= CST_TimerROCO;
        O_led <= CST_RRCO;

    END CASE;
  END PROCESS;

  -- [My Implementation]: Connect the internal integer counter value
  -- to the 4-bit std_logic_vector output port.
  O_maxCount <= std_logic_vector(to_unsigned(SC_maxCountInt, O_maxCount'length));

END ARCHITECTURE archi_fsmMoore;