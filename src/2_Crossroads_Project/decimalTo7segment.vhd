-------------------------------------------------------------------------------
-- Title      :
-- Project    :
-------------------------------------------------------------------------------
-- File       : carrefourUnit.vhd
-- Author     : Jean-Noel BAZIN  <jnbazin@pc-disi-026.enst-bretagne.fr>
-- Company    :
-- Created    : 2018-05-30
-- Last update: 2019-10-16
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: converts the 4-bit representation of a decimal (I_dataIn) into a 7-segment display command (O_7segment). 
-- A display command is active low:  to turn on a segment, apply 0. 
-- a (= O_7segment(6)) is the MSB, g (=O_7segment(0)) is the LSB.
-- So, for digit 3 the output will be represented by "0000110".
--      _______
--     |   a   |
--    f|       |b
--     |       |
--     |_______|
--     |   g   |
--    e|       |c
--     |       |
--     |_______|
--         d
--
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

ENTITY decimalTo7segment IS
  PORT (
    I_dataIn : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- four bit representation of a decimal digit
    O_7segment : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) -- 7 segment representation of the input
  );
END ENTITY decimalTo7segment;

ARCHITECTURE archi_decimalTo7segment OF decimalTo7segment IS

BEGIN -- architecture archi_decimalTo7segment

  PROCESS (I_dataIn)
  BEGIN
    CASE I_dataIn IS
      WHEN "0000" => -- 0
        O_7segment <= "0000001"; -- a,b,c,d,e,f on, g off
      WHEN "0001" => -- 1
        O_7segment <= "1001111"; -- b,c on
      WHEN "0010" => -- 2
        O_7segment <= "0010010"; -- a,b,d,e,g on
      WHEN "0011" => -- 3
        O_7segment <= "0000110"; -- a,b,c,d,g on
      WHEN "0100" => -- 4
        O_7segment <= "1001100"; -- b,c,f,g on
      WHEN "0101" => -- 5
        O_7segment <= "0100100"; -- a,c,d,f,g on
      WHEN "0110" => -- 6
        O_7segment <= "0100000"; -- a,c,d,e,f,g on
      WHEN "0111" => -- 7
        O_7segment <= "0001111"; -- a,b,c on
      WHEN "1000" => -- 8
        O_7segment <= "0000000"; -- all on
      WHEN "1001" => -- 9
        O_7segment <= "0000100"; -- a,b,c,d,f,g on
      WHEN OTHERS =>
        O_7segment <= "1111111"; -- all segments off
    END CASE;
  END PROCESS;

END ARCHITECTURE archi_decimalTo7segment;