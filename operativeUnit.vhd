-------------------------------------------------------------------------------
-- Title      : operativeUnit
-- Project    :
-------------------------------------------------------------------------------
-- File       : operativeUnit.vhd
-- Author     : Jean-Noel BAZIN  <jnbazin@pc-disi-026.enst-bretagne.fr>
-- Company    :
-- Created    : 2018-04-11
-- Last update: 2025-03-28
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Operative unit of a sequential FIR filter. Including shift
-- register for samples, registers for coefficients, a MAC and a register to
-- store the result
-------------------------------------------------------------------------------
-- Copyright (c) 2018
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  A
-- 2025-04-09  1.2      marzel  Renamed some signals and port names to match
--                              the description of lab activity
--                              Modified the sample width to 16 bits
--                              Changed the filter coefficients to have abetter
--                              low-pass filter
-- 2019-02-13  1.1      marzel  Update to provide a 16-tap filter and improve
--                              the user experience ;)
-- 2018-04-11  1.0      jnbazin Created
-- 2018-04-18  1.0      marzel  Modification of SR_Y assignment to a round
--                              instead of a trunc
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity operativeUnit is

    port (
        I_clock          : in  std_logic;                     -- global clock
        I_reset          : in  std_logic;                     -- asynchronous global reset
        I_inputSample    : in  std_logic_vector(15 downto 0);  -- 16 bit input sample
        I_loadShift      : in  std_logic;                     -- Control signal to load the input sample in the sample shift register and shift the register
        I_initAddress    : in  std_logic;                     -- Control signal to initialize register read address
        I_incrAddress    : in  std_logic;                     -- Control signal to increment register read address
        I_initSum        : in  std_logic;                     -- Control signal to initialize the MAC register
        I_loadSum        : in  std_logic;                     -- Control signal to load the MAC register;
        I_loadY          : in  std_logic;                     -- Control signal to load Y register
        O_processingDone : out std_logic;                     -- Indicate that processing is done
        O_filteredSample : out std_logic_vector(15 downto 0)   -- filtered sample
        );

end entity operativeUnit;

architecture arch_operativeUnit of operativeUnit is
    type registerFile is array(0 to 15) of signed(15 downto 0);
    signal SR_coefRegister : registerFile;


    signal SR_shiftRegister : registerFile;           -- shift register file used to store and shift input samples
    signal SC_multOperand1  : signed(15 downto 0);
    signal SC_multOperand2  : signed(15 downto 0);
    signal SC_MultResult    : signed(31 downto 0);    -- Result of the multiplication Xi*Hi
    signal SC_addResult     : signed(35 downto 0);    -- result of the accumulation addition
    signal SR_sum           : signed(35 downto 0);    -- Accumulation register
    signal SR_filteredSample: signed(15 downto 0);     -- filtered sample storage register
    signal SR_readAddress   : integer range 0 to 15;  -- register files read address



begin

    -- Low-pass filter provided with octave (or Matlab ;)) script :
    -- pkg load signal
    -- 
    -- fs=44100
    -- fn=fs/2
    -- n=16
    -- fc=300
    -- fLP=fir1(n-1,fc/fn,"low");
    -- 
    -- function quantized_signal = quantize(signal, q)
    --     % Quantize the signal to q bits
    --     max_val = 2^(q-1) - 1;
    --     min_val = -2^(q-1);
    --     quantized_signal = round(min(max(signal * 2^(q-1), min_val), max_val)) / 2^(q-1);
    -- end
    -- 
    -- q=16
    -- 
    -- fLPq= quantize(fLP,q);
    -- 
    -- for i=1:n
    --   printf("to_signed(%d,%d),\n", fLPq(i)*2^(q-1),q);
    --  endfor
    
    -- Table to store the filter coefficients obtained with the previous script
    SR_coefRegister <= (to_signed(317,16),
                        to_signed(476,16),
                        to_signed(925,16),
                        to_signed(1589,16),
                        to_signed(2354,16),
                        to_signed(3087,16),
                        to_signed(3661,16),
                        to_signed(3975,16),
                        to_signed(3975,16),
                        to_signed(3661,16),
                        to_signed(3087,16),
                        to_signed(2354,16),
                        to_signed(1589,16),
                        to_signed(925,16),
                        to_signed(476,16),
                        to_signed(317,16)
                        );
    
    -- Process to describe the shift register storing the input samples
    shift : process (_BLANK_) is
    begin  -- process shift
        if I_reset = '1' then           -- asynchronous reset (active high)
            SR_shiftRegister <= (others => (others => '0'));
        elsif _BLANK_

        end if;
    end process shift;

    -- Process to describe the counter providing the selection adresses
    -- of the multiplexers
    incr_address : process (_BLANK_) is
    begin
        if I_reset = '1' then               -- asynchronous reset (active high)
            SR_readAddress <= 0;
        elsif _BLANK_

        end if;
    end process incr_address;

    -- Signal detecting that the next cycle will be the one
    -- providing the last product used to compute the convolution
    O_processingDone <= '1' when _BLANK_;

    -- Signals connected with multiplexers (SIMPLY inferred with table indices)
    SC_multOperand1 <= _BLANK_;             -- 16 bits
    SC_multOperand2 <= _BLANK_;             -- 16 bits

    -- Multiplication of the operands
    SC_MultResult   <= _BLANK_;             -- 32 bits

    -- Sum of the multiplication result and the accumulated value
    SC_addResult    <= resize(SC_MultResult, SC_addResult'length) + SR_sum;

    -- Register to store the accumulated value if the loadSum is active
    -- It also reduces the width of the sum to fit to the input and output
    -- signal widths (be careful with truncating/rounding)
    sum_acc : process (_BLANK_) is
    begin
        if I_reset = '1' then               -- asynchronous reset (active high)
            SR_sum <= (others => '0');
        elsif _BLANK_
        end if;
    end process sum_acc;

    -- Register to store the final result if the loadOuput is active
    store_result : process (_BLANK_) is
    begin
        _BLANK_

    end process store_result;

    O_filteredSample <= std_logic_vector(SR_filteredSample);

end architecture arch_operativeUnit;
