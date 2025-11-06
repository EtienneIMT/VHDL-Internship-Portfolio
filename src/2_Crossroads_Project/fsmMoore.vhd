-------------------------------------------------------------------------------
-- Title      : fsmMoore
-- Project    :
-------------------------------------------------------------------------------
-- File       : fsm.vhd
-- Author     : Jean-Noel BAZIN  <jnbazin@pc-disi-026.enst-bretagne.fr>
-- Company    :
-- Created    : 2018-05-30
-- Last update: 2020-01-27
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Moore type finite state machine. Controler of the traffic light
-- circuit
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

ENTITY fsmMoore IS
  PORT (
    I_clk : IN STD_LOGIC; -- Global clock
    I_rst : IN STD_LOGIC; -- Global asynchronous active high reset
    I_timerDone : IN STD_LOGIC; -- Indicates the timer is done
    I_presence : IN STD_LOGIC; -- A vehicule is present on the track
    O_led : OUT STD_LOGIC_VECTOR(5 DOWNTO 0); -- Drives the leds of the traffic light. Signal format : RV & RO & RR & CV & CO & CR
    O_maxCount : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- Indicates to the timer the time to count
    O_initTimer : OUT STD_LOGIC; -- Initializes the timer
    O_enableTimer : OUT STD_LOGIC); -- Enables timer processing

END ENTITY fsmMoore;
ARCHITECTURE archi_fsmMoore OF fsmMoore IS

  CONSTANT CST_TimerRV : INTEGER := 9; -- Number of second the road light should remain green
  CONSTANT CST_TimerROCO : INTEGER := 3; -- Number of second the road light or the path remains orange
  CONSTANT CST_TimerCV : INTEGER := 7; -- Number of second the path light remains green
  CONSTANT CST_TimerSECU : INTEGER := 2; -- Number of second the road and the path lights remain red together
  CONSTANT CST_RRCR : STD_LOGIC_VECTOR(5 DOWNTO 0) := "001001";
  CONSTANT CST_ROCR : STD_LOGIC_VECTOR(5 DOWNTO 0) := "010001";
  CONSTANT CST_RVCR : STD_LOGIC_VECTOR(5 DOWNTO 0) := "100001";
  CONSTANT CST_RRCV : STD_LOGIC_VECTOR(5 DOWNTO 0) := "001100";
  CONSTANT CST_RRCO : STD_LOGIC_VECTOR(5 DOWNTO 0) := "001010";
  TYPE T_state IS (INIT, RRCR1_Init,
    RRCR1_Count, RVCR1_Init,
    RVCR1_Count, RVCR2,
    ROCR_Init, ROCR_Count,
    RRCR2_Init, RRCR2_Count,
    RRCV_Init, RRCV_Count,
    RRCO_Init, RRCO_Count); -- List of states

  SIGNAL SR_presentState : T_state; -- Signal for the present state (provided by the state register)
  SIGNAL SC_futurState : T_state; -- Result of the evaluation of the futur state
  SIGNAL SC_maxCountInt : INTEGER RANGE 0 TO 9; -- Signal indicating the max value for second counter
BEGIN

  --State register
  PROCESS (I_clk, I_rst) IS
  BEGIN
    IF I_rst = '1' THEN
      SR_presentState <= INIT;
    ELSIF rising_edge(I_clk) THEN
      SR_presentState <= SC_futurState;
    END IF;
  END PROCESS;

  -- Computation of next state
  PROCESS (SR_presentState, I_timerDone, I_presence) IS
  BEGIN
    CASE SR_presentState IS

      WHEN INIT =>
        SC_futurState <= RRCR1_Init;

      WHEN RRCR1_Init =>
        SC_futurState <= RRCR1_Count;

      WHEN RRCR1_Count =>
        IF I_timerDone = '1' THEN
          SC_futurState <= RVCR1_Init;
        ELSE
          SC_futurState <= RRCR1_Count;
        END IF;

      WHEN RVCR1_Init =>
        SC_futurState <= RVCR1_Count;

      WHEN RVCR1_Count =>
        IF I_timerDone = '1' THEN
          SC_futurState <= RVCR2;
        ELSE
          SC_futurState <= RVCR1_Count;
        END IF;

      WHEN RVCR2 =>
        IF I_presence = '1' THEN
          SC_futurState <= ROCR_Init;
        ELSE
          SC_futurState <= RVCR2;
        END IF;

      WHEN ROCR_Init =>
        SC_futurState <= ROCR_Count;

      WHEN ROCR_Count =>
        IF I_timerDone = '1' THEN
          SC_futurState <= RRCR2_Init;
        ELSE
          SC_futurState <= ROCR_Count;
        END IF;

      WHEN RRCR2_Init =>
        SC_futurState <= RRCR2_Count;

      WHEN RRCR2_Count =>
        IF I_timerDone = '1' THEN
          SC_futurState <= RRCV_Init;
        ELSE
          SC_futurState <= RRCR2_Count;
        END IF;

      WHEN RRCV_Init =>
        SC_futurState <= RRCV_Count;

      WHEN RRCV_Count =>
        IF I_timerDone = '1' THEN
          SC_futurState <= RRCO_Init;
        ELSE
          SC_futurState <= RRCV_Count;
        END IF;

      WHEN RRCO_Init =>
        SC_futurState <= RRCO_Count;

      WHEN RRCO_Count =>
        IF I_timerDone = '1' THEN
          SC_futurState <= RRCR1_Init;
        ELSE
          SC_futurState <= RRCO_Count;
        END IF;

    END CASE;
  END PROCESS;

  -- Computation of outputs
  PROCESS (SR_presentState)
  BEGIN

    -- Default values
    O_initTimer <= '0';
    O_enableTimer <= '0';
    SC_maxCountInt <= CST_TimerSECU;
    O_led <= CST_RRCR;

    CASE SR_presentState IS
      WHEN RRCR1_Init =>
        O_initTimer <= '1';
        O_enableTimer <= '0';
        SC_maxCountInt <= CST_TimerSECU;
        O_led <= CST_RRCR;

      WHEN RRCR1_Count =>
        O_initTimer <= '0';
        O_enableTimer <= '1';
        SC_maxCountInt <= CST_TimerSECU;
        O_led <= CST_RRCR;

      WHEN RVCR1_Init =>
        O_initTimer <= '1';
        O_enableTimer <= '0';
        SC_maxCountInt <= CST_TimerRV;
        O_led <= CST_RVCR;

      WHEN RVCR1_Count =>
        O_initTimer <= '0';
        O_enableTimer <= '1';
        SC_maxCountInt <= CST_TimerRV;
        O_led <= CST_RVCR;

      WHEN RVCR2 =>
        O_initTimer <= '0';
        O_enableTimer <= '1';
        SC_maxCountInt <= CST_TimerRV;
        O_led <= CST_RVCR;

      WHEN ROCR_Init =>
        O_initTimer <= '1';
        O_enableTimer <= '0';
        SC_maxCountInt <= CST_TimerROCO;
        O_led <= CST_ROCR;

      WHEN ROCR_Count =>
        O_initTimer <= '0';
        O_enableTimer <= '1';
        SC_maxCountInt <= CST_TimerROCO;
        O_led <= CST_ROCR;

      WHEN RRCR2_Init =>
        O_initTimer <= '1';
        O_enableTimer <= '0';
        SC_maxCountInt <= CST_TimerSECU;
        O_led <= CST_RRCR;

      WHEN RRCR2_Count =>
        O_initTimer <= '0';
        O_enableTimer <= '1';
        SC_maxCountInt <= CST_TimerSECU;
        O_led <= CST_RRCR;

      WHEN RRCV_Init =>
        O_initTimer <= '1';
        O_enableTimer <= '0';
        SC_maxCountInt <= CST_TimerCV;
        O_led <= CST_RRCV;

      WHEN RRCV_Count =>
        O_initTimer <= '0';
        O_enableTimer <= '1';
        SC_maxCountInt <= CST_TimerCV;
        O_led <= CST_RRCV;

      WHEN RRCO_Init =>
        O_initTimer <= '1';
        O_enableTimer <= '0';
        SC_maxCountInt <= CST_TimerROCO;
        O_led <= CST_RRCO;

      WHEN RRCO_Count =>
        O_initTimer <= '0';
        O_enableTimer <= '1';
        SC_maxCountInt <= CST_TimerROCO;
        O_led <= CST_RRCO;

    END CASE;
  END PROCESS;

  O_maxCount <= SC_maxCount;
END ARCHITECTURE archi_fsmMoore;