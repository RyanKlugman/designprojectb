library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_ip_demo_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Users to add ports here
		-- User ports ends
		-- Do not modify the ports beyond this line
		
		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
	
end axi_ip_demo_v1_0;

architecture arch_imp of axi_ip_demo_v1_0 is

	-- component declaration
	component axi_ip_demo_v1_0_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic;
		datain0,datain1,datain2,datain3     : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        dataout0,dataout1,dataout2,dataout3 : out  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        latched_waddr,latched_raddr           : out std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0)
		);
	end component axi_ip_demo_v1_0_S00_AXI;
	
	component bram is
    Port ( clk : in STD_LOGIC;
           wdata :  in std_logic_vector(31 downto 0);
           bram_we: in std_logic;
           bram_re: in std_logic;
           bram_read : in std_logic;
           currAdd : out std_logic_vector(31 downto 0);
           bramout : out std_logic_vector(31 downto 0));
    end component;
    
    COMPONENT floating_point_0
      PORT (
        aclk : IN STD_LOGIC;
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
    
        
    signal dataout0_int,dataout1_int,dataout2_int,dataout3_int: std_logic_vector(31 downto 0);
    signal datain0,datain1,datain2,datain3     : std_logic_vector(31 downto 0);
    signal dataout0,dataout1,dataout2,dataout3 : std_logic_vector(31 downto 0);
    signal count : std_logic_vector(31 downto 0);
    signal lwaddr,lraddr           : std_logic_vector(3 downto 0);
    

	signal axi_awaddr	: std_logic_vector(31 downto 0);
	signal axi_awready	: std_logic;
	signal axi_wready	: std_logic;
	signal axi_bresp	: std_logic_vector(1 downto 0);
	signal axi_bvalid	: std_logic;
	signal axi_araddr	: std_logic_vector(31 downto 0);
	signal axi_arready	: std_logic;
	signal axi_rdata	: std_logic_vector(31 downto 0);
	signal axi_rresp	: std_logic_vector(1 downto 0);
	signal axi_rvalid	: std_logic;
	signal readout      : std_logic_vector(31 downto 0);
	signal bramout      : std_logic_vector(31 downto 0);
	
    signal fifo_we      : std_logic;
    signal bram_we      : std_logic;
    signal bram_re      : std_logic;
    signal fifo_re      : std_logic;
    signal currAdd      : std_logic_vector(31 downto 0);
    signal bram_read   : std_logic;
    signal s_axis_a_tvalid :std_logic;
    signal s_axis_b_tvalid      : std_logic;
    signal m_axis_result_tvalid: std_logic;
    signal s_axis_a_tready: std_logic;
    signal s_axis_b_tready: std_logic;
    signal m_axis_result_tready : std_logic;
    signal s_axis_a_tdata : std_logic_vector(31 downto 0);
    signal s_axis_b_tdata : std_logic_vector(31 downto 0);
    signal divo         : std_logic_vector(31 downto 0);
    
    
begin
    S00_AXI_AWREADY	<= axi_awready;
    S00_AXI_WREADY    <= axi_wready;
    --S00_AXI_BVALID    <= axi_bvalid;
    S00_AXI_ARREADY    <= axi_arready;  
    --S00_AXI_RDATA    <= axi_rdata;
    S00_AXI_RVALID    <= axi_rvalid;
-- Instantiation of Axi Bus Interface S00_AXI
axi_ip_demo_v1_0_S00_AXI_inst : axi_ip_demo_v1_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready,
		datain0       => datain0,
		datain1   => datain1,
		datain2 => datain2,
		datain3 => datain3,
		dataout0 => dataout0,
		dataout1 => dataout1,
		dataout2 => dataout2,
		dataout3 => dataout3,
		latched_waddr => lwaddr,
		latched_raddr => lraddr
	);
	
	bram_inst : bram
      Port map ( clk => s00_axi_aclk,
                wdata => s00_axi_wdata,
                bram_we => bram_we,
                bram_re => bram_re,
                bram_read => bram_read,
                currAdd => currAdd,
                bramout => bramout);
                
     your_instance_name : floating_point_0
                  PORT MAP (
                    aclk => s00_axi_aclk,
                    s_axis_a_tvalid => s_axis_a_tvalid,
                    s_axis_a_tready => s_axis_a_tready,
                    s_axis_a_tdata => s_axis_a_tdata,
                    s_axis_b_tvalid => s_axis_b_tvalid,
                    s_axis_b_tready => s_axis_b_tready,
                    s_axis_b_tdata => s_axis_b_tdata,
                    m_axis_result_tvalid => m_axis_result_tvalid,
                    m_axis_result_tready => m_axis_result_tready,
                    m_axis_result_tdata => divo
                  );
   s_axis_a_tvalid <= '1' when datain1(3 downto 0) = "1111" else '0';
   s_axis_b_tvalid <= '1' when datain1(3 downto 0) = "1111" else '0';
   s_axis_a_tdata <= datain0 when datain1(3 downto 0) = "1111" else X"00000000";
   s_axis_b_tdata <= datain3 when datain1(3 downto 0) = "1111" else X"00000000";
   m_axis_result_tready <= '1';
	-- Add user logic here
	--Read out register content.
	--datain0123 are registers that hold the content
	--Slave registers I THINK
	--dataout0123 are registers that hold the write values.
    bram_we <= '1' when ((s00_axi_awaddr(3 downto 2) = "11") AND  (s00_axi_awvalid = '1') AND (s00_axi_wvalid = '1')) else
                '0';     
    bram_re <= '1' when ((s00_axi_awaddr(3 downto 2) = "01") AND  (s00_axi_awvalid = '1') AND (s00_axi_wvalid = '1')) else
               '0';  
    bram_read <= '1' when ((s00_axi_araddr(3 downto 2) = "11") AND (s00_axi_arvalid ='1')) else
              '0';   
    --hold the quotient value
    datain0 <= dataout0;
    --holds the current read addr
    datain1 <= dataout1;
    --datain2 <= X"000000" 
    datain2 <= divo;
    datain3 <= bramout;
	-- User logic ends
    
end arch_imp;
