library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir is

  generic (
    dwidth : natural := 24;
    ntaps  : natural := 15);

  port (
    din          : in  std_logic_vector(dwidth-1 downto 0);
    dout         : out std_logic_vector(dwidth-1 downto 0);
    config_sw    : in  std_logic_vector(5 downto 0);  --inutilise dans le TP majeure
    clk          : in  std_logic;
    rst          : in  std_logic;
    ce           : in  std_logic;  -- signal de validation de din a la frequence des echantillons audio
    dbg_output_0 : out std_logic_vector(7 downto 0);  --inutilise dans le TP majeure
    dbg_output_1 : out std_logic_vector(7 downto 0);  --inutilise dans le TP majeure
    dbg_output_2 : out std_logic;       --inutilise dans le TP majeure
    dbg_output_3 : out std_logic;       --inutilise dans le TP majeure
    dbg_output_4 : out std_logic       --inutilise dans le TP majeure
--    dout_valid   : out std_logic
    );

end fir;

architecture myarch of fir is

  component firUnit is
    port (
      I_clock               : in  std_logic;
      I_reset               : in  std_logic;
      I_inputSample         : in  std_logic_vector(15 downto 0);
      I_inputSampleValid    : in  std_logic;
      O_filteredSample      : out std_logic_vector(15 downto 0);
      O_filteredSampleValid : out std_logic);
  end component firUnit;


  signal D_in, D_out : std_logic_vector(15 downto 0);

begin  -- myarch

-- Quantization on 16 bits or less

-- When config_sw(0)='1', rounding is made by finding the nearest value else rounding is made by truncating.
prc : process (config_sw(4 downto 0), din) is
  variable w : integer;
  begin  -- process prc
    w:=to_integer(unsigned(config_sw(3 downto 0))); -- number of removed bits
    D_in <= (others=> '0');
    if(config_sw(4)='1') then
        D_in(15 downto w) <= din(dwidth-1 downto dwidth-16+w); -- truncate
    else
        if(din(dwidth-16+w-1)='1') then
            D_in(15 downto w) <= std_logic_vector(signed(din(dwidth-1 downto dwidth-16+w))+1); --round to the upper
        else
            D_in(15 downto w) <= din(dwidth-1 downto dwidth-16+w);--round to the lower
        end if;
    end if;
  end process prc;
  
--FIR over 16 bits

  firUnit_1 : entity work.firUnit
    port map (
      I_clock               => clk,
      I_reset               => rst,
      I_inputSample         => D_in,
      I_inputSampleValid    => ce,
      O_filteredSample      => D_out,
      O_filteredSampleValid => open);


-- End of FIR


  dout(dwidth-1 downto dwidth -16) <= D_out when config_sw(5) = '1' else D_in;
  dout(dwidth-17 downto 0)         <= (others => '0');





end myarch;
