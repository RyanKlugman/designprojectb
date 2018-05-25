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

entity quantize is
    Port ( clk : in STD_LOGIC;
            start : in std_logic;
            do_scale : in std_logic;
            amount: in std_logic_vector(31 downto 0);
            input: in std_logic_vector(31 downto 0);
            scale: in std_logic_vector(31 downto 0);
            outVal: out std_logic_vector(63 downto 0);
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
    
    type state_t is (idle,step1a,add128,floattofixeds,lastStep);   -- states load_new_ampl, pwm_high, pwm_low
    --fp_div,step1b,fp_add,step3a,step3b,stepwrite

    -----------------DIVIDER-------------------------
    signal m_axis_result_tvalid: std_logic;
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
    signal m_axis_result_tvalid_adder: std_logic;
    signal m_axis_result_tready_adder: std_logic := '0';
    signal a_adder_valid :std_logic := '0';
    signal b_adder_valid : std_logic  := '0';
    signal a_adder_ready: std_logic;
    signal b_adder_ready: std_logic;
    signal adder_data_a : std_logic_vector(31 downto 0);
    signal adder_data_b : std_logic_vector(31 downto 0);
    signal adderReset: std_logic := '1';
    signal adderout        : std_logic_vector(31 downto 0);
    -------------Float to Fixed-----------------------------
    signal f2f_m_valid: std_logic;
    signal f2f_m_ready: std_logic := '0';
    signal f2f_valid :std_logic := '0';
    signal f2f_ready: std_logic;
    signal f2f_data : std_logic_vector(31 downto 0);
    signal f2f_o    : std_logic_vector(31 downto 0);
   ------------------Other-----------------------------
    signal temp :std_logic := '0';
    signal divAmount: std_logic:= '0';
    signal outputVal     : std_logic_vector(31 downto 0);
    signal state: state_t := idle;
    signal lastVal : std_logic_vector(31 downto 0);
    signal onetwoeight : std_logic_vector(31 downto 0) := X"43000000";
    signal k : std_logic_vector(31 downto 0):= X"00000005";
    signal quantizeOut: std_logic_vector(63 downto 0);
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
        if(rising_edge(clk)) then
            case state is
                when idle =>
                    quantDone <= '0';
                    if(start = '1' and do_scale ='1') then
                        state <= step1a;
                        divAmount <= '0';
                    elsif(start = '1' and do_scale = '0') then
                        state <= step1a;
                        divAmount <= '1';
                    else
                        state <= idle;
                    end if;
                ---scale
                when step1a =>
                    if(divAmount = '1') then
                        --Just divide by amount
                       --10
                       if(do_scale = '0') then
                           div_data_a <= input;
                       else 
                           div_data_a <= outputVal;
                       end if;

                                               --1.5
                       div_data_b <= amount;
                    else 
                        --do scale.
                        --4
                        --div_data_a <= X"40800000";
                        div_data_a <= input;
                        div_data_b <= scale;
                        --1.5
                        --div_data_b <= X"3fc00000";
                    end if;
                    --a/b
                    a_div_valid <= '1';
                    b_div_valid <= '1';
                    m_axis_result_tready <= '1';
                    temp <= '1';
                    divReset <= '1';
                    if(m_axis_result_tvalid = '1') then
                        --state <= idle;
                        a_div_valid <= '0';
                        b_div_valid <= '0';
                        --When reset is loweered, the FP unit will reset after 2 clk cycles.
                        divReset <= '0';
                        outputVal <= divo;
                        if(divAmount = '1') then
                            state <= floattofixeds;
                        else
                            state <= add128;
                        end if;
                    else 
                        state <= step1a;
                    end if;
                when add128 =>
                    adder_data_a <= onetwoeight;
                    adder_data_b <= outputVal;
                    --a/b
                    a_adder_valid <= '1';
                    b_adder_valid <= '1';
                    m_axis_result_tready_adder <= '1';
                    adderReset <= '1';
                    if(m_axis_result_tvalid_adder = '1') then
                        --state <= idle;
                        a_adder_valid <= '0';
                        b_adder_valid <= '0';
                        --When reset is loweered, the FP unit will reset after 2 clk cycles.
                        adderReset <= '0';
                        divAmount <= '1';
                        outputVal <= adderout;
                        state <= step1a;
                    else 
                        state <= add128;
                    end if;
                 when floattofixeds =>
                    f2f_data <= outputVal;
                    --a/b
                    f2f_valid <= '1';
                    f2f_m_ready <= '1';
                    if(f2f_m_valid = '1') then
                        --state <= idle;
                        f2f_valid <= '0';
                        b_adder_valid <= '0';
                        lastVal <= f2f_o;
                        state <= lastStep;
                    else 
                        state <= floattofixeds;
                    end if;
                when lastStep =>
                    quantizeOut <= std_logic_vector(unsigned(lastVal) * unsigned(k));
                    outVal <= std_logic_vector(unsigned(lastVal) * unsigned(k));
                    quantDone <= '1';
                    --do the if statement blah blah blah
                    state <= idle;
            end case;
         end if;
    end process;
    
end Behavioral;
