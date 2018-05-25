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
    type state_t is (idle,write,read,read_r,contr_read_r);   -- states load_new_ampl, pwm_high, pwm_low
    --Declaration of type and signal of a 1024 element RAM
    --with each element being 16 bit wide.
    type bram_t is array (0 to 1023) of std_logic_vector(31 downto 0);
        --BRAM fifo implementation initalised to 0.
    signal bram : bram_t := (others => (others => '0'));
    signal bramActiveAddr : integer;
    --Current State
    signal state: state_t := idle;
    --Bram Data
    signal bramdata : std_logic_vector(31 downto 0);
    signal bramContdata : std_logic_vector(31 downto 0);
begin 
    process(clk)
    begin
        if(rising_edge(clk)) then
            case state is
                when idle =>
                    if(bram_we = '1') then
                        state <= write;
                    elsif(bram_re = '1') then
                        state <= read;
                    elsif(bram_read = '1') then
                        state <= read_r;
                    elsif(contr_read = '1') then
                        state <= contr_read_r;
                    elsif(contr_we = '1') then
                        state <= write;
                    elsif(contr_bae = '1') then
                        state <= read;
                    else
                        state <= idle;
                    end if;
                when write =>
                    if(contr_we = '1') then
                        bram(bramActiveAddr) <= quantData;
                    else
                        bram(bramActiveAddr) <= wdata(31 downto 0);
                    end if;
                    state <= idle;
                when read =>
                    if(contr_bae = '1') then
                        bramActiveAddr <= to_integer(unsigned(contr_addr));
                    else 
                        bramActiveAddr <= to_integer(unsigned(wdata));
                    end if;
                    state <= idle;
                when read_r =>
                    state <= idle;
                when contr_read_r =>
                    state <= idle;
            end case;
         end if;
    end process;
    process (state)
    begin
        if(state = read_r) then
            bramdata <= bram(bramActiveAddr);
        elsif(state = contr_read_r) then
            bramContdata <= bram(bramActiveAddr);
        end if;
    end process;
    --Data is always ready to be read from active address
    currAdd <= std_logic_vector(to_unsigned(bramActiveAddr, 32));
    bramout <= bramdata;
    bramConOut <= bramContdata;
    
end Behavioral;