library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity quantize_tb is
end;

architecture bench of quantize_tb is

  component quantize
      Port ( clk : in STD_LOGIC;
              start : in std_logic;
              do_scale : in std_logic;
              amount: in std_logic_vector(31 downto 0);
              input: in std_logic_vector(31 downto 0);
              scale: in std_logic_vector(31 downto 0);
              output: out std_logic_vector(7 downto 0);
              done: out std_logic
              );
  end component;

  signal clk: STD_LOGIC;
  signal start: std_logic;
  signal do_scale: std_logic;
  signal amount: std_logic_vector(31 downto 0);
  signal input: std_logic_vector(31 downto 0);
  signal scale: std_logic_vector(31 downto 0);
  signal output: std_logic_vector(7 downto 0);
  signal done: std_logic ;

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  uut: quantize port map ( clk      => clk,
                           start    => start,
                           do_scale => do_scale,
                           amount   => amount,
                           input    => input,
                           scale    => scale,
                           output   => output,
                           done     => done );

  stimulus: process
  begin
  
    -- Put initialisation code here
    do_scale <= '1';
    amount <= X"40800000";
    input <= X"430d3a32";
    scale <= X"40e10000";
    start <= '1';

    -- Put test bench stimulus code here

    --stop_the_clock <= true;
    wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      clk <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end;