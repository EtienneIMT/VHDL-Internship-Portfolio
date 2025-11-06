-------------------------------------------------------------------------------
-- Title      : firUnit
-- Project    : 
-------------------------------------------------------------------------------
-- File       : operativeUnit.vhd
-- Author     : Jean-Noel BAZIN  <jnbazin@pc-disi-026.enst-bretagne.fr>
-- Company    : 
-- Created    : 2018-04-11
-- Last update: 2018-04-11
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 8 bit FIR
-------------------------------------------------------------------------------
-- Copyright (c) 2018 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2025-04-09  1.1      marzel  Renamed some signals and port names to match
--                              the description of lab activity
--                              Modified the sample width to 16 bits
-- 2018-04-11  1.0      jnbazin Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity firUnit is

  port (
    I_clock               : in  std_logic;  -- global clock
    I_reset               : in  std_logic;  -- asynchronous global reset
    I_inputSample         : in  std_logic_vector(15 downto 0);  -- 8 bit input sample
    I_inputSampleValid    : in  std_logic;
    O_filteredSample      : out std_logic_vector(15 downto 0);  -- filtered sample
    O_filteredSampleValid : out std_logic
    );

end entity firUnit;

architecture archi_firUnit of firUnit is

  component controlUnit is
    port (
      I_clock               : in  std_logic;
      I_reset               : in  std_logic;
      I_inputSampleValid    : in  std_logic;
      I_processingDone      : in  std_logic;
      O_loadShift           : out std_logic;
      O_initAddress         : out std_logic;
      O_incrAddress         : out std_logic;
      O_initSum             : out std_logic;
      O_loadSum             : out std_logic;
      O_loadOutput          : out std_logic;
      O_FilteredSampleValid : out std_logic);
  end component controlUnit;

  component operativeUnit is
    port (
      I_clock          : in  std_logic;
      I_reset          : in  std_logic;
      I_inputSample    : in  std_logic_vector(15 downto 0);
      I_loadShift      : in  std_logic;
      I_initAddress    : in  std_logic;
      I_incrAddress    : in  std_logic;
      I_initSum        : in  std_logic;
      I_loadSum        : in  std_logic;
      I_loadOutput     : in  std_logic;
      O_processingDone : out std_logic;
      O_filteredSample : out std_logic_vector(15 downto 0));
  end component operativeUnit;

  signal SC_processingDone : std_logic;
  signal SC_loadShift      : std_logic;
  signal SC_initAddress    : std_logic;
  signal SC_incrAddress    : std_logic;
  signal SC_initSum        : std_logic;
  signal SC_loadSum        : std_logic;
  signal SC_loadOutput     : std_logic;

begin

  controlUnit_1 : entity work.controlUnit
    port map (
      I_clock               => I_clock,
      I_reset               => I_reset,
      I_inputSampleValid    => I_inputSampleValid,
      I_processingDone      => SC_processingDone,
      O_loadShift           => SC_loadShift,
      O_initAddress         => SC_initAddress,
      O_incrAddress         => SC_incrAddress,
      O_initSum             => SC_initSum,
      O_loadSum             => SC_loadSum,
      O_loadOutput          => SC_loadOutput,
      O_FilteredSampleValid => O_FilteredSampleValid);

  operativeUnit_1 : entity work.operativeUnit
    port map (
      I_clock          => I_clock,
      I_reset          => I_reset,
      I_inputSample    => I_inputSample,
      I_loadShift      => SC_loadShift,
      I_initAddress    => SC_initAddress,
      I_incrAddress    => SC_incrAddress,
      I_initSum        => SC_initSum,
      I_loadSum        => SC_loadSum,
      I_loadOutput     => SC_loadOutput,
      O_processingDone => SC_processingDone,
      O_filteredSample => O_filteredSample);

end architecture archi_firUnit;
