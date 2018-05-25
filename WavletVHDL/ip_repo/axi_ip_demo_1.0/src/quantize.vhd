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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity quantize is
    Port ( clk : in STD_LOGIC;
            start : in std_logic;
            do_scale : in std_logic;
            amount: in std_logic_vector(31 downto 0);
            amountInt: in std_logic_vector(31 downto 0);
            input: in std_logic_vector(31 downto 0);
            scale: in std_logic_vector(31 downto 0);
            outVal: out std_logic_vector(31 downto 0);
            quantDone: out std_logic
            );
end quantize;

architecture Behavioral of quantize is

    COMPONENT floating_point_1
      PORT (
        aclk : IN STD_LOGIC;
        aresetn : IN STD_LOGIC;
        s_axis_a_tvalid : IN STD_LOGIC;
        s_axis_a_tready : OUT STD_LOGIC;
        s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        s_axis_b_tvalid : IN STD_LOGIC;
        s_axis_b_tready : OUT STD_LOGIC;
        s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        m_axis_result_tvalid : OUT STD_LOGIC;
        m_axis_result_tready : IN STD_LOGIC;
        m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
      );
    END COMPONENT;
    
    COMPONENT floating_point_add
          PORT (
            aclk : IN STD_LOGIC;
            aresetn : IN STD_LOGIC;
            s_axis_a_tvalid : IN STD_LOGIC;
            s_axis_a_tready : OUT STD_LOGIC;
            s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            s_axis_b_tvalid : IN STD_LOGIC;
            s_axis_b_tready : OUT STD_LOGIC;
            s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            m_axis_result_tvalid : OUT STD_LOGIC;
            m_axis_result_tready : IN STD_LOGIC;
            m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
          );
    END COMPONENT;
    
    --float to fixed.
    COMPONENT floating_point_0
      PORT (
        aclk : IN STD_LOGIC;
        s_axis_a_tvalid : IN STD_LOGIC;
        s_axis_a_tready : OUT STD_LOGIC;
        s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        m_axis_result_tvalid : OUT STD_LOGIC;
        m_axis_result_tready : IN STD_LOGIC;
        m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
      );
    END COMPONENT;
    
    type state_t is (idle_state,scale_state,divide4_state,add128_state,round_state,multiply4_state);   -- states load_new_ampl, pwm_high, pwm_low
    --fp_div,step1b,fp_add,step3a,step3b,stepwrite

    -----------------DIVIDER-------------------------
    signal m_axis_result_tvalid: std_logic := '0';
    signal m_axis_result_tready : std_logic := '0';
    signal a_div_valid :std_logic := '0';
    signal b_div_valid : std_logic  := '0';
    signal a_div_ready: std_logic;
    signal b_div_ready: std_logic;
    signal div_data_a : std_logic_vector(31 downto 0);
    signal div_data_b : std_logic_vector(31 downto 0);
    signal divReset: std_logic := '1';
    signal divo         : std_logic_vector(31 downto 0);
    ----------------ADDER------------------------------
    signal m_axis_result_tvalid_adder: std_logic := '0';
    signal m_axis_result_tready_adder: std_logic := '0';
    signal a_adder_valid :std_logic := '0';
    signal b_adder_valid : std_logic  := '0';
    signal a_adder_ready: std_logic := '0';
    signal b_adder_ready: std_logic := '0';
    signal adder_data_a : std_logic_vector(31 downto 0) := (others => '0');
    signal adder_data_b : std_logic_vector(31 downto 0) := (others => '0');
    signal adderReset: std_logic := '1';
    signal adderout : std_logic_vector(31 downto 0) := (others => '0');
    -------------Float to Fixed-----------------------------
    signal f2f_m_valid: std_logic := '0';
    signal f2f_m_ready: std_logic := '0';
    signal f2f_valid :std_logic := '0';
    signal f2f_ready: std_logic := '0';
    signal f2f_data : std_logic_vector(31 downto 0) := (others => '0');
    signal f2f_o    : std_logic_vector(31 downto 0) := (others => '0');
   ------------------Other-----------------------------
    signal input_over_scale : std_logic_vector(31 downto 0) := (others => '0');
    signal scaled_input : std_logic_vector(31 downto 0) := (others => '0');
    signal state: state_t := idle_state;
    signal onetwoeight : std_logic_vector(31 downto 0) := X"43000000";
--    signal quantizeOut: std_logic_vector(63 downto 0); -- Removed this
begin 
     divider : floating_point_1
                  PORT MAP (
                    aclk => clk,                
                    aresetn => divReset,
                    s_axis_a_tvalid => a_div_valid,
                    s_axis_a_tready => a_div_ready,
                    s_axis_a_tdata => div_data_a,
                    s_axis_b_tvalid => b_div_valid,
                    s_axis_b_tready => b_div_ready,
                    s_axis_b_tdata => div_data_b,
                    m_axis_result_tvalid => m_axis_result_tvalid,
                    m_axis_result_tready => m_axis_result_tready,
                    m_axis_result_tdata => divo
                  );
                  
     adder : floating_point_add
     PORT MAP   (   aclk => clk,
                    aresetn => adderReset,
                    s_axis_a_tvalid => a_adder_valid,
                    s_axis_a_tready => a_adder_ready,
                    s_axis_a_tdata => adder_data_a,
                    s_axis_b_tvalid => b_adder_valid,
                    s_axis_b_tready => b_adder_ready,
                    s_axis_b_tdata => adder_data_b,
                    m_axis_result_tvalid => m_axis_result_tvalid_adder,
                    m_axis_result_tready => m_axis_result_tready_adder,
                    m_axis_result_tdata => adderout
                );
    floattofixed : floating_point_0
                      PORT MAP (
                        aclk => clk,
                        s_axis_a_tvalid => f2f_valid,
                        s_axis_a_tready => f2f_ready,
                        s_axis_a_tdata => f2f_data,
                        m_axis_result_tvalid => f2f_m_valid,
                        m_axis_result_tready => f2f_m_ready,
                        m_axis_result_tdata => f2f_o
                      );
    process(clk)
    begin
        if rising_edge(clk) then
            case state is
                when idle_state =>
                    quantDone <= '0';
                    if start = '1' then
                        if do_scale ='1' then
                            state <= scale_state;
                        else
                            scaled_input <= input; -- Don't need to scale
                            state <= divide4_state;
                        end if;
                    end if;
                when scale_state =>
                    div_data_a <= input;
                    div_data_b <= scale;
                    a_div_valid <= '1';
                    b_div_valid <= '1';
                    m_axis_result_tready <= '1';
                    divReset <= '1';
                    if(m_axis_result_tvalid = '1') then
                        --state <= idle;
                        a_div_valid <= '0';
                        b_div_valid <= '0';
                        --When reset is loweered, the FP unit will reset after 2 clk cycles.
                        divReset <= '0';
                        input_over_scale <= divo;
                        state <= add128_state;
                    end if;
                when add128_state =>
                    adder_data_a <= onetwoeight;
                    adder_data_b <= input_over_scale;
                    a_adder_valid <= '1';
                    b_adder_valid <= '1';
                    m_axis_result_tready_adder <= '1';
                    adderReset <= '1';
                    if(m_axis_result_tvalid_adder = '1') then
                        a_adder_valid <= '0';
                        b_adder_valid <= '0';
                        --When reset is loweered, the FP unit will reset after 2 clk cycles.
                        adderReset <= '0';
                        scaled_input <= adderout;
                        state <= divide4_state;
                    end if;
                 when divide4_state =>
                    scaled_input(30 downto 23) <= scaled_input(30 downto 23) - X"02"; -- divide by 4 (subtract 2 from exponent)
                    state <= round_state;
                 when round_state =>
                    f2f_data <= scaled_input;
                    --a/b
                    f2f_valid <= '1';
                    f2f_m_ready <= '1';
                    if(f2f_m_valid = '1') then
                        --state <= idle;
                        f2f_valid <= '0';
                        b_adder_valid <= '0';
                        scaled_input <= f2f_o;
                        state <= multiply4_state;
                    end if;
                when multiply4_state =>
                    outVal <= scaled_input(29 downto 0) & "00"; -- multiply by 4
                    quantDone <= '1';
                    state <= idle_state;
            end case;
         end if;
    end process;
    
end Behavioral;
