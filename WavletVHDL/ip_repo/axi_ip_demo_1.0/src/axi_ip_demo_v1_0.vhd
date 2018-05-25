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
		C_S00_AXI_ADDR_WIDTH	: integer	:= 6
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
		C_S_AXI_ADDR_WIDTH	: integer	:= 6
		);
	   port (
            -- Users to add ports here
            -- User ports ends
            -- Do not modify the ports beyond this line
    
            -- Global Clock Signal
            S_AXI_ACLK    : in std_logic;
            -- Global Reset Signal. This Signal is Active LOW
            S_AXI_ARESETN    : in std_logic;
            -- Write address (issued by master, acceped by Slave)
            S_AXI_AWADDR    : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
            -- Write channel Protection type. This signal indicates the
                -- privilege and security level of the transaction, and whether
                -- the transaction is a data access or an instruction access.
            S_AXI_AWPROT    : in std_logic_vector(2 downto 0);
            -- Write address valid. This signal indicates that the master signaling
                -- valid write address and control information.
            S_AXI_AWVALID    : in std_logic;
            -- Write address ready. This signal indicates that the slave is ready
                -- to accept an address and associated control signals.
            S_AXI_AWREADY    : out std_logic;
            -- Write data (issued by master, acceped by Slave) 
            S_AXI_WDATA    : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            -- Write strobes. This signal indicates which byte lanes hold
                -- valid data. There is one write strobe bit for each eight
                -- bits of the write data bus.    
            S_AXI_WSTRB    : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
            -- Write valid. This signal indicates that valid write
                -- data and strobes are available.
            S_AXI_WVALID    : in std_logic;
            -- Write ready. This signal indicates that the slave
                -- can accept the write data.
            S_AXI_WREADY    : out std_logic;
            -- Write response. This signal indicates the status
                -- of the write transaction.
            S_AXI_BRESP    : out std_logic_vector(1 downto 0);
            -- Write response valid. This signal indicates that the channel
                -- is signaling a valid write response.
            S_AXI_BVALID    : out std_logic;
            -- Response ready. This signal indicates that the master
                -- can accept a write response.
            S_AXI_BREADY    : in std_logic;
            -- Read address (issued by master, acceped by Slave)
            S_AXI_ARADDR    : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
            -- Protection type. This signal indicates the privilege
                -- and security level of the transaction, and whether the
                -- transaction is a data access or an instruction access.
            S_AXI_ARPROT    : in std_logic_vector(2 downto 0);
            -- Read address valid. This signal indicates that the channel
                -- is signaling valid read address and control information.
            S_AXI_ARVALID    : in std_logic;
            -- Read address ready. This signal indicates that the slave is
                -- ready to accept an address and associated control signals.
            S_AXI_ARREADY    : out std_logic;
            -- Read data (issued by slave)
            S_AXI_RDATA    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            -- Read response. This signal indicates the status of the
                -- read transfer.
            S_AXI_RRESP    : out std_logic_vector(1 downto 0);
            -- Read valid. This signal indicates that the channel is
                -- signaling the required read data.
            S_AXI_RVALID    : out std_logic;
            -- Read ready. This signal indicates that the master can
                -- accept the read data and response information.
            S_AXI_RREADY    : in std_logic;
            datain0,datain1,datain2,datain3,datain4,datain5,datain6,datain7,datain8,datain9,datain10,datain11,datain12,datain13,datain14,datain15     : in  std_logic_vector(31 downto 0);
            dataout0,dataout1,dataout2,dataout3,dataout4,dataout5,dataout6,dataout7,dataout8,dataout9,dataout10,dataout11,dataout12,dataout13,dataout14,dataout15     : out  std_logic_vector(31 downto 0);
            latched_waddr,latched_raddr : out std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0)
        );
	end component axi_ip_demo_v1_0_S00_AXI;
	
	signal datain0,datain1,datain2,datain3,datain4,datain5,datain6,datain7,datain8,datain9,datain10,datain11,datain12,datain13,datain14,datain15     :  std_logic_vector(31 downto 0);
    signal dataout0,dataout1,dataout2,dataout3,dataout4,dataout5,dataout6,dataout7,dataout8,dataout9,dataout10,dataout11,dataout12,dataout13,dataout14,dataout15     :   std_logic_vector(31 downto 0);
    signal latched_waddr,latched_raddr :  std_logic_vector(5 downto 0);
    signal lwaddr,lraddr : std_logic_vector(5 downto 0);
    
begin

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
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready,
		
		datain0 => datain0,
        datain1 => datain1,
        datain2 => datain2,
        datain3 => datain3,
        datain4 => datain4,
        datain5 => datain5,
        datain6 => datain6,
        datain7  => datain7,
        datain8  => datain8,
        datain9  => datain9,
        datain10 => datain10,
        datain11 => datain11,
        datain12 => datain12,
        datain13 => datain13,
        datain14 => datain14,
        datain15 => datain15,
        
        dataout0 => dataout0,
        dataout1 => dataout1,
        dataout2 => dataout2,
        dataout3 => dataout3,
        dataout4 => dataout4,
        dataout5 => dataout5,
        dataout6 => dataout6,
        dataout7 => dataout7,
        dataout8 => dataout8,
        dataout9 => dataout9,
        dataout10 => dataout10,
        dataout11 => dataout11,
        dataout12 => dataout12,
        dataout13 => dataout13,
        dataout14 => dataout14,
        dataout15 => dataout15,
        
        latched_waddr => lwaddr,
        latched_raddr => lraddr
	);

	-- Add user logic here

	-- User logic ends

end arch_imp;
