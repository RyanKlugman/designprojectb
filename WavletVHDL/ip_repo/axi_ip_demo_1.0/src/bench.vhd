library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity axi_ip_demo_v1_0_tb is
end;

architecture bench of axi_ip_demo_v1_0_tb is
     constant CLOCK_PERIOD   : Time := 10 ns; -- 100MHz 
     constant AXI_DATA_WIDTH : integer := 32;
     constant AXI_ADDR_WIDTH : integer := 6;
     
  component axi_ip_demo_v1_0
  	generic (
  		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
  		C_S00_AXI_ADDR_WIDTH	: integer	:= 6
  	);
  	port (
  		s00_axi_aclk	: in std_logic;
  		s00_axi_aresetn	: in std_logic;
  		s00_axi_awaddr	: in std_logic_vector(5 downto 0);
  		s00_axi_awprot	: in std_logic_vector(2 downto 0);
  		s00_axi_awvalid	: in std_logic;
  		s00_axi_awready	: out std_logic;
  		s00_axi_wdata	: in std_logic_vector(31 downto 0);
  		s00_axi_wstrb	: in std_logic_vector((32/8)-1 downto 0);
  		s00_axi_wvalid	: in std_logic;
  		s00_axi_wready	: out std_logic;
  		s00_axi_bresp	: out std_logic_vector(1 downto 0);
  		s00_axi_bvalid	: out std_logic;
  		s00_axi_bready	: in std_logic;
  		s00_axi_araddr	: in std_logic_vector(5 downto 0);
  		s00_axi_arprot	: in std_logic_vector(2 downto 0);
  		s00_axi_arvalid	: in std_logic;
  		s00_axi_arready	: out std_logic;
  		s00_axi_rdata	: out std_logic_vector(31 downto 0);
  		s00_axi_rresp	: out std_logic_vector(1 downto 0);
  		s00_axi_rvalid	: out std_logic;
  		s00_axi_rready	: in std_logic;
        rst_soft : in std_logic;
        start_soft: in std_logic 
  	);
  end component;

  signal s00_axi_aclk: std_logic;
  signal s00_axi_aresetn: std_logic;
  signal s00_axi_awaddr: std_logic_vector(5 downto 0);
  signal s00_axi_awprot: std_logic_vector(2 downto 0);
  signal s00_axi_awvalid: std_logic;
  signal s00_axi_awready: std_logic;
  signal s00_axi_wdata: std_logic_vector(31 downto 0);
  signal s00_axi_wstrb: std_logic_vector((32/8)-1 downto 0);
  signal s00_axi_wvalid: std_logic;
  signal s00_axi_wready: std_logic;
  signal s00_axi_bresp: std_logic_vector(1 downto 0);
  signal s00_axi_bvalid: std_logic;
  signal s00_axi_bready: std_logic;
  signal s00_axi_araddr: std_logic_vector(5 downto 0);
  signal s00_axi_arprot: std_logic_vector(2 downto 0);
  signal s00_axi_arvalid: std_logic;
  signal s00_axi_arready: std_logic;
  signal s00_axi_rdata: std_logic_vector(31 downto 0);
  signal s00_axi_rresp: std_logic_vector(1 downto 0);
  signal s00_axi_rvalid: std_logic;
  signal s00_axi_rready: std_logic ;
  signal stop_the_clock: boolean;
  signal rst_soft : std_logic;
  signal start_soft: std_logic;
  
begin

  -- Insert values for generic parameters !!
  uut: axi_ip_demo_v1_0 generic map ( C_S00_AXI_DATA_WIDTH => AXI_DATA_WIDTH,
                                      C_S00_AXI_ADDR_WIDTH =>  AXI_ADDR_WIDTH)
                           port map ( s00_axi_aclk         => s00_axi_aclk,
                                      s00_axi_aresetn      => s00_axi_aresetn,
                                      s00_axi_awaddr       => s00_axi_awaddr,
                                      s00_axi_awprot       => s00_axi_awprot,
                                      s00_axi_awvalid      => s00_axi_awvalid,
                                      s00_axi_awready      => s00_axi_awready,
                                      s00_axi_wdata        => s00_axi_wdata,
                                      s00_axi_wstrb        => s00_axi_wstrb,
                                      s00_axi_wvalid       => s00_axi_wvalid,
                                      s00_axi_wready       => s00_axi_wready,
                                      s00_axi_bresp        => s00_axi_bresp,
                                      s00_axi_bvalid       => s00_axi_bvalid,
                                      s00_axi_bready       => s00_axi_bready,
                                      s00_axi_araddr       => s00_axi_araddr,
                                      s00_axi_arprot       => s00_axi_arprot,
                                      s00_axi_arvalid      => s00_axi_arvalid,
                                      s00_axi_arready      => s00_axi_arready,
                                      s00_axi_rdata        => s00_axi_rdata,
                                      s00_axi_rresp        => s00_axi_rresp,
                                      s00_axi_rvalid       => s00_axi_rvalid,
                                      s00_axi_rready       => s00_axi_rready,
                                      rst_soft => rst_soft,
                                      start_soft => start_soft
                                      );

  stimulus: process
  begin
    rst_soft <= '1';
    start_soft <= '0';
    wait for clock_period * 5;
    rst_soft <= '0';
    wait for clock_period * 5;
    start_soft <= '1';
    wait;
  end process;
  
  clocking: process
    begin
      while not stop_the_clock loop
        s00_axi_aclk <= '0', '1' after clock_period / 2;
        wait for clock_period;
      end loop;
      wait;
    end process;

    -- Put test bench stimulus code here




end;
  