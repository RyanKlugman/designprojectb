library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity controller is
     Port ( clk : in STD_LOGIC;
            rst_soft : in std_logic;
            start_soft : in std_logic;
            done_soft : out std_logic;
            do_scale : in std_logic;
            amount: in std_logic_vector(31 downto 0);
            scale: in std_logic_vector(31 downto 0);
            image_width: in std_logic_vector(31 downto 0);
            bram_write_en : out std_logic;
            bram_addr : out std_logic_vector (31 downto 0);
            bram_data_in : out std_logic_vector(31 downto 0);
            bram_data_out : in std_logic_vector(31 downto 0)
      );
end controller;

architecture Behavioral of controller is
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
    
    type state_t is (idle_state, quant_start_state, quant_wait_state, write_state, inc_state, inc_wait_state, done_state);  
    signal state: state_t := idle_state;
    signal quant_start: std_logic := '0';
    signal quant_input : std_logic_vector(31 downto 0) := (others => '0');
    signal quant_output : std_logic_vector(7 downto 0) := (others => '0');
    signal quant_done : std_logic := '0';
    signal address : std_logic_vector(31 downto 0) := (others => '0');

begin 
    quant: quantize
        port map(
                clk => clk,
                start => quant_start,
                do_scale => do_scale,
                amount => amount,
                input => quant_input,
                scale => scale,
                output => quant_output,
                done => quant_done
        );
                
    process(clk)
    begin
        if rising_edge(clk) then
            case state is
                when idle_state =>
                    bram_write_en <= '0';
                    done_soft <= '0';
                    address <= x"00000000";
                    if start_soft = '1' then
                        state <= quant_start_state;
                    end if;
                when quant_start_state =>
                    quant_input <= bram_data_out;
                    quant_start <= '1';
                    state <= quant_wait_state;
                when quant_wait_state =>
                    quant_start <= '0';
                    if quant_done = '1' then
                        state <= write_state;
                    end if;
                when write_state =>
                    bram_write_en <= '1';
                    bram_data_in <= X"000000" & quant_output;
                    state <= inc_state;
                when inc_state =>
                    bram_write_en <= '0';
                    if (address = image_width) then
                        state <= done_state;
                    else 
                        address <= std_logic_vector(unsigned(address) + 1);
                        state <= inc_wait_state;
                    end if;
                when inc_wait_state =>
                    state <= quant_start_state;
                when done_state =>
                    done_soft <= '1';
                    if rst_soft = '1' then
                        state <= idle_state;
                    end if;
            end case;
         end if;
    end process;
    bram_addr <= address;
end Behavioral;
