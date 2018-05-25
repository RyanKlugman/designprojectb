----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.03.2018 13:50:09
-- Design Name: 
-- Module Name: fifo - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bram is
    Port ( clk : in STD_LOGIC;
           wdata :  in std_logic_vector(31 downto 0);
           bram_we: in std_logic;
           bram_re: in std_logic;
           bram_read : in std_logic;
           
           contr_we : in std_logic;
           contr_bae: in std_logic;
           contr_read : in std_logic;
           
           contr_addr: in std_logic_vector(31 downto 0);
           quantData : in std_logic_vector(31 downto 0);
           bramConOut : out std_logic_vector(31 downto 0);
           
           currAdd : out std_logic_vector(31 downto 0);
           bramout : out std_logic_vector(31 downto 0));
end bram;

architecture Behavioral of bram is
    --Declaration of type and signal of a 1024 element RAM
    --with each element being 16 bit wide.
    type bram_t is array (0 to 1023) of std_logic_vector(31 downto 0);
        --BRAM fifo implementation initalised to 0.
    signal bram : bram_t := (X"41c1999a", X"4256cccd", X"42ca6666", X"408e353f", X"42b56666", others => (others => '0'));
    -- 24.2, 21
    -- 53.7, 56
    -- 101.2, 98
    -- 4.444, 7
    -- 90.7, 91
     signal bramActiveAddr : integer := 0;
    --Bram Data
    signal bramdata : std_logic_vector(31 downto 0) := (others => '0');
    signal bramContdata : std_logic_vector(31 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if(rising_edge(clk)) then
            if (bram_we = '1') then
                bram(bramActiveAddr) <= wdata(31 downto 0);
            elsif (contr_we = '1') then
                bram(bramActiveAddr) <= quantData;
            elsif (bram_re = '1') then
                bramActiveAddr <= to_integer(unsigned(wdata));
                bramdata <= bram(to_integer(unsigned(wdata)));
            elsif (contr_bae = '1') then
                bramActiveAddr <= to_integer(unsigned(contr_addr));
                bramContdata <= bram(to_integer(unsigned(contr_addr)));         
            elsif (bram_read = '1') then
                bramdata <= bram(bramActiveAddr);
            elsif (contr_read = '1') then
                bramContdata <= bram(bramActiveAddr);
            end if;
         end if;
    end process;
    --Data is always ready to be read from active address
    currAdd <= std_logic_vector(to_unsigned(bramActiveAddr, 32));
    bramout <= bramdata;
    bramConOut <= bramContdata;
    
end Behavioral;