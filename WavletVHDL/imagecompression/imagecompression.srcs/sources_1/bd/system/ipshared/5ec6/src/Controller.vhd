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

entity controller is
     Port ( clk : in STD_LOGIC;
            rst_soft : in std_logic;
            start_soft : in std_logic;
            done_soft : out std_logic;
            bwe : out std_logic;
            bae: out std_logic;
            bre : out std_logic;
            bread_in : in std_logic_vector(31 downto 0);
            qdata_out : out std_logic_vector (31 downto 0);
            baddr : out std_logic_vector(31 downto 0));
end controller;

architecture Behavioral of controller is
    component quantize
        Port ( clk : in STD_LOGIC;
                start : in std_logic;
                do_scale : in std_logic;
                amount: in std_logic_vector(31 downto 0);
                input: in std_logic_vector(31 downto 0);
                scale: in std_logic_vector(31 downto 0);
                outVal: out std_logic_vector(63 downto 0);
                quantDone: out std_logic
                );
    end component;
    
    type state_t is (idle,reads,qenable,waitForQuant,write,writewait,inc,done);  
    signal state: state_t := idle;
    signal currAddr : std_logic_vector(31 downto 0);
    
    signal doscale : std_logic := '0';
    signal amount : std_logic_vector(31 downto 0) := X"40A00000";
    signal input : std_logic_vector(31 downto 0) := X"40a00000";
    signal scaleAmount: std_logic_vector(31 downto 0) := X"40800000";
    signal quantOut : std_logic_vector(63 downto 0);
    signal quantDone: std_logic;
    signal qdata : std_logic_vector(31 downto 0);
    signal qStart: std_logic := '0';
begin 
    quant: quantize
        port map(
                clk => clk,
                start => qStart,
                do_scale => doscale,
                amount => amount,
                input => input,
                scale => scaleAmount,
                outVal => quantOut,
                quantDone => quantDone
                );
                
    process(clk)
    begin
        if(rst_soft = '1') then
            state <= idle;
            bwe <= '0';
        elsif (rising_edge(clk)) then
            case state is
                when idle =>
                    currAddr <= (others => '0');
                    bae <= '1';
                    if(start_soft = '1') then
                        state <= reads;
                    elsif (rst_soft <= '1') then
                        state <= idle;
                    else 
                        state <= idle;
                    end if;
                when reads =>
                    bre <= '1';
                when qenable =>
                    qStart <= '1';
                    --set input probs
                    input <= bread_in;
                    state <= waitForQuant;
                    
                when waitForQuant =>
                    bre <= '0';
                    qStart <= '0';
                    if (quantDone = '1') then
                        state <= write;
                    else 
                        state <= waitForQuant;
                    end if;
                when write =>
                    state <= writewait;
                    bwe <= '1';
                   -- doscale <= not(doscale);
                    qdata_out <= quantOut(31 downto 0);
                when writewait =>
                    state <= inc;
                when inc =>
                    currAddr <= std_logic_vector(unsigned(currAddr)+ 1);
                    bae <= '1'; 
                    bwe <= '0';
                    if (unsigned(currAddr) = 1023) then
                        state <= done;
                    else 
                        state <= reads; 
                    end if;
                when done =>
                    done_soft <= '1';
                    if (rst_soft <= '1') then
                        state <= idle;
                    else 
                        state <= done;
                    end if;
            end case;
         end if;
    end process;

end Behavioral;
