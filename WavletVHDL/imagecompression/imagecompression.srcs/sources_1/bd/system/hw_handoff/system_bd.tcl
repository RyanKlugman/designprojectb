
################################################################
# This is a generated script based on design: system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2017.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source system_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z020clg484-1
   set_property BOARD_PART em.avnet.com:zed:part0:1.3 [current_project]
}


# CHANGE DESIGN NAME HERE
set design_name system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]

  # Create ports

  # Create instance: axi_ip_demo_0, and set properties
  set axi_ip_demo_0 [ create_bd_cell -type ip -vlnv user.org:user:axi_ip_demo:9.1 axi_ip_demo_0 ]

  # Create instance: axi_ip_demo_1, and set properties
  set axi_ip_demo_1 [ create_bd_cell -type ip -vlnv user.org:user:axi_ip_demo:9.1 axi_ip_demo_1 ]

  # Create instance: axi_ip_demo_2, and set properties
  set axi_ip_demo_2 [ create_bd_cell -type ip -vlnv user.org:user:axi_ip_demo:9.1 axi_ip_demo_2 ]

  # Create instance: axi_ip_demo_3, and set properties
  set axi_ip_demo_3 [ create_bd_cell -type ip -vlnv user.org:user:axi_ip_demo:9.1 axi_ip_demo_3 ]

  # Create instance: axi_ip_demo_4, and set properties
  set axi_ip_demo_4 [ create_bd_cell -type ip -vlnv user.org:user:axi_ip_demo:9.1 axi_ip_demo_4 ]

  # Create instance: axi_ip_demo_5, and set properties
  set axi_ip_demo_5 [ create_bd_cell -type ip -vlnv user.org:user:axi_ip_demo:9.1 axi_ip_demo_5 ]

  # Create instance: axi_ip_demo_6, and set properties
  set axi_ip_demo_6 [ create_bd_cell -type ip -vlnv user.org:user:axi_ip_demo:9.1 axi_ip_demo_6 ]

  # Create instance: axi_ip_demo_7, and set properties
  set axi_ip_demo_7 [ create_bd_cell -type ip -vlnv user.org:user:axi_ip_demo:9.1 axi_ip_demo_7 ]

  # Create instance: axi_ip_demo_8, and set properties
  set axi_ip_demo_8 [ create_bd_cell -type ip -vlnv user.org:user:axi_ip_demo:9.1 axi_ip_demo_8 ]

  # Create instance: axi_ip_demo_9, and set properties
  set axi_ip_demo_9 [ create_bd_cell -type ip -vlnv user.org:user:axi_ip_demo:9.1 axi_ip_demo_9 ]

  # Create instance: axi_ip_demo_10, and set properties
  set axi_ip_demo_10 [ create_bd_cell -type ip -vlnv user.org:user:axi_ip_demo:9.1 axi_ip_demo_10 ]

  # Create instance: axi_ip_demo_11, and set properties
  set axi_ip_demo_11 [ create_bd_cell -type ip -vlnv user.org:user:axi_ip_demo:9.1 axi_ip_demo_11 ]

  # Create instance: axi_ip_demo_12, and set properties
  set axi_ip_demo_12 [ create_bd_cell -type ip -vlnv user.org:user:axi_ip_demo:9.1 axi_ip_demo_12 ]

  # Create instance: axi_ip_demo_13, and set properties
  set axi_ip_demo_13 [ create_bd_cell -type ip -vlnv user.org:user:axi_ip_demo:9.1 axi_ip_demo_13 ]

  # Create instance: axi_ip_demo_14, and set properties
  set axi_ip_demo_14 [ create_bd_cell -type ip -vlnv user.org:user:axi_ip_demo:9.1 axi_ip_demo_14 ]

  # Create instance: axi_ip_demo_15, and set properties
  set axi_ip_demo_15 [ create_bd_cell -type ip -vlnv user.org:user:axi_ip_demo:9.1 axi_ip_demo_15 ]

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list \
CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
CONFIG.preset {ZedBoard} \
 ] $processing_system7_0

  # Create instance: ps7_0_axi_periph, and set properties
  set ps7_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 ps7_0_axi_periph ]
  set_property -dict [ list \
CONFIG.NUM_MI {16} \
 ] $ps7_0_axi_periph

  # Create instance: rst_ps7_0_100M, and set properties
  set rst_ps7_0_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ps7_0_100M ]

  # Create interface connections
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins ps7_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M00_AXI [get_bd_intf_pins axi_ip_demo_0/S00_AXI] [get_bd_intf_pins ps7_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M01_AXI [get_bd_intf_pins axi_ip_demo_1/S00_AXI] [get_bd_intf_pins ps7_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M02_AXI [get_bd_intf_pins axi_ip_demo_2/S00_AXI] [get_bd_intf_pins ps7_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M03_AXI [get_bd_intf_pins axi_ip_demo_3/S00_AXI] [get_bd_intf_pins ps7_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M04_AXI [get_bd_intf_pins axi_ip_demo_4/S00_AXI] [get_bd_intf_pins ps7_0_axi_periph/M04_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M05_AXI [get_bd_intf_pins axi_ip_demo_5/S00_AXI] [get_bd_intf_pins ps7_0_axi_periph/M05_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M06_AXI [get_bd_intf_pins axi_ip_demo_6/S00_AXI] [get_bd_intf_pins ps7_0_axi_periph/M06_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M07_AXI [get_bd_intf_pins axi_ip_demo_7/S00_AXI] [get_bd_intf_pins ps7_0_axi_periph/M07_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M08_AXI [get_bd_intf_pins axi_ip_demo_8/S00_AXI] [get_bd_intf_pins ps7_0_axi_periph/M08_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M09_AXI [get_bd_intf_pins axi_ip_demo_9/S00_AXI] [get_bd_intf_pins ps7_0_axi_periph/M09_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M10_AXI [get_bd_intf_pins axi_ip_demo_10/S00_AXI] [get_bd_intf_pins ps7_0_axi_periph/M10_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M11_AXI [get_bd_intf_pins axi_ip_demo_11/S00_AXI] [get_bd_intf_pins ps7_0_axi_periph/M11_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M12_AXI [get_bd_intf_pins axi_ip_demo_12/S00_AXI] [get_bd_intf_pins ps7_0_axi_periph/M12_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M13_AXI [get_bd_intf_pins axi_ip_demo_13/S00_AXI] [get_bd_intf_pins ps7_0_axi_periph/M13_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M14_AXI [get_bd_intf_pins axi_ip_demo_14/S00_AXI] [get_bd_intf_pins ps7_0_axi_periph/M14_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M15_AXI [get_bd_intf_pins axi_ip_demo_15/S00_AXI] [get_bd_intf_pins ps7_0_axi_periph/M15_AXI]

  # Create port connections
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins axi_ip_demo_0/s00_axi_aclk] [get_bd_pins axi_ip_demo_1/s00_axi_aclk] [get_bd_pins axi_ip_demo_10/s00_axi_aclk] [get_bd_pins axi_ip_demo_11/s00_axi_aclk] [get_bd_pins axi_ip_demo_12/s00_axi_aclk] [get_bd_pins axi_ip_demo_13/s00_axi_aclk] [get_bd_pins axi_ip_demo_14/s00_axi_aclk] [get_bd_pins axi_ip_demo_15/s00_axi_aclk] [get_bd_pins axi_ip_demo_2/s00_axi_aclk] [get_bd_pins axi_ip_demo_3/s00_axi_aclk] [get_bd_pins axi_ip_demo_4/s00_axi_aclk] [get_bd_pins axi_ip_demo_5/s00_axi_aclk] [get_bd_pins axi_ip_demo_6/s00_axi_aclk] [get_bd_pins axi_ip_demo_7/s00_axi_aclk] [get_bd_pins axi_ip_demo_8/s00_axi_aclk] [get_bd_pins axi_ip_demo_9/s00_axi_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins ps7_0_axi_periph/ACLK] [get_bd_pins ps7_0_axi_periph/M00_ACLK] [get_bd_pins ps7_0_axi_periph/M01_ACLK] [get_bd_pins ps7_0_axi_periph/M02_ACLK] [get_bd_pins ps7_0_axi_periph/M03_ACLK] [get_bd_pins ps7_0_axi_periph/M04_ACLK] [get_bd_pins ps7_0_axi_periph/M05_ACLK] [get_bd_pins ps7_0_axi_periph/M06_ACLK] [get_bd_pins ps7_0_axi_periph/M07_ACLK] [get_bd_pins ps7_0_axi_periph/M08_ACLK] [get_bd_pins ps7_0_axi_periph/M09_ACLK] [get_bd_pins ps7_0_axi_periph/M10_ACLK] [get_bd_pins ps7_0_axi_periph/M11_ACLK] [get_bd_pins ps7_0_axi_periph/M12_ACLK] [get_bd_pins ps7_0_axi_periph/M13_ACLK] [get_bd_pins ps7_0_axi_periph/M14_ACLK] [get_bd_pins ps7_0_axi_periph/M15_ACLK] [get_bd_pins ps7_0_axi_periph/S00_ACLK] [get_bd_pins rst_ps7_0_100M/slowest_sync_clk]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_ps7_0_100M/ext_reset_in]
  connect_bd_net -net rst_ps7_0_100M_interconnect_aresetn [get_bd_pins ps7_0_axi_periph/ARESETN] [get_bd_pins rst_ps7_0_100M/interconnect_aresetn]
  connect_bd_net -net rst_ps7_0_100M_peripheral_aresetn [get_bd_pins axi_ip_demo_0/s00_axi_aresetn] [get_bd_pins axi_ip_demo_1/s00_axi_aresetn] [get_bd_pins axi_ip_demo_10/s00_axi_aresetn] [get_bd_pins axi_ip_demo_11/s00_axi_aresetn] [get_bd_pins axi_ip_demo_12/s00_axi_aresetn] [get_bd_pins axi_ip_demo_13/s00_axi_aresetn] [get_bd_pins axi_ip_demo_14/s00_axi_aresetn] [get_bd_pins axi_ip_demo_15/s00_axi_aresetn] [get_bd_pins axi_ip_demo_2/s00_axi_aresetn] [get_bd_pins axi_ip_demo_3/s00_axi_aresetn] [get_bd_pins axi_ip_demo_4/s00_axi_aresetn] [get_bd_pins axi_ip_demo_5/s00_axi_aresetn] [get_bd_pins axi_ip_demo_6/s00_axi_aresetn] [get_bd_pins axi_ip_demo_7/s00_axi_aresetn] [get_bd_pins axi_ip_demo_8/s00_axi_aresetn] [get_bd_pins axi_ip_demo_9/s00_axi_aresetn] [get_bd_pins ps7_0_axi_periph/M00_ARESETN] [get_bd_pins ps7_0_axi_periph/M01_ARESETN] [get_bd_pins ps7_0_axi_periph/M02_ARESETN] [get_bd_pins ps7_0_axi_periph/M03_ARESETN] [get_bd_pins ps7_0_axi_periph/M04_ARESETN] [get_bd_pins ps7_0_axi_periph/M05_ARESETN] [get_bd_pins ps7_0_axi_periph/M06_ARESETN] [get_bd_pins ps7_0_axi_periph/M07_ARESETN] [get_bd_pins ps7_0_axi_periph/M08_ARESETN] [get_bd_pins ps7_0_axi_periph/M09_ARESETN] [get_bd_pins ps7_0_axi_periph/M10_ARESETN] [get_bd_pins ps7_0_axi_periph/M11_ARESETN] [get_bd_pins ps7_0_axi_periph/M12_ARESETN] [get_bd_pins ps7_0_axi_periph/M13_ARESETN] [get_bd_pins ps7_0_axi_periph/M14_ARESETN] [get_bd_pins ps7_0_axi_periph/M15_ARESETN] [get_bd_pins ps7_0_axi_periph/S00_ARESETN] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]

  # Create address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x43C00000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ip_demo_0/S00_AXI/S00_AXI_reg] SEG_axi_ip_demo_0_S00_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x43CA0000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ip_demo_10/S00_AXI/S00_AXI_reg] SEG_axi_ip_demo_10_S00_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x43CB0000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ip_demo_11/S00_AXI/S00_AXI_reg] SEG_axi_ip_demo_11_S00_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x43CC0000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ip_demo_12/S00_AXI/S00_AXI_reg] SEG_axi_ip_demo_12_S00_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x43CD0000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ip_demo_13/S00_AXI/S00_AXI_reg] SEG_axi_ip_demo_13_S00_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x43CE0000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ip_demo_14/S00_AXI/S00_AXI_reg] SEG_axi_ip_demo_14_S00_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x43CF0000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ip_demo_15/S00_AXI/S00_AXI_reg] SEG_axi_ip_demo_15_S00_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x43C10000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ip_demo_1/S00_AXI/S00_AXI_reg] SEG_axi_ip_demo_1_S00_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x43C20000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ip_demo_2/S00_AXI/S00_AXI_reg] SEG_axi_ip_demo_2_S00_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x43C30000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ip_demo_3/S00_AXI/S00_AXI_reg] SEG_axi_ip_demo_3_S00_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x43C40000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ip_demo_4/S00_AXI/S00_AXI_reg] SEG_axi_ip_demo_4_S00_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x43C50000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ip_demo_5/S00_AXI/S00_AXI_reg] SEG_axi_ip_demo_5_S00_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x43C60000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ip_demo_6/S00_AXI/S00_AXI_reg] SEG_axi_ip_demo_6_S00_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x43C70000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ip_demo_7/S00_AXI/S00_AXI_reg] SEG_axi_ip_demo_7_S00_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x43C80000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ip_demo_8/S00_AXI/S00_AXI_reg] SEG_axi_ip_demo_8_S00_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x43C90000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ip_demo_9/S00_AXI/S00_AXI_reg] SEG_axi_ip_demo_9_S00_AXI_reg


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


