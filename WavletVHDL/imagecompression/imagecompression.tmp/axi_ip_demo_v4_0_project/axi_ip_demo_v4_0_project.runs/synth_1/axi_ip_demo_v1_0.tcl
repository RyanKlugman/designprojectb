# 
# Synthesis run script generated by Vivado
# 

create_project -in_memory -part xc7z020clg484-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir C:/Users/Ryan/Desktop/WavletVHDL/imagecompression/imagecompression.tmp/axi_ip_demo_v4_0_project/axi_ip_demo_v4_0_project.cache/wt [current_project]
set_property parent.project_path C:/Users/Ryan/Desktop/WavletVHDL/imagecompression/imagecompression.tmp/axi_ip_demo_v4_0_project/axi_ip_demo_v4_0_project.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
set_property board_part em.avnet.com:zed:part0:1.3 [current_project]
set_property ip_repo_paths c:/Users/Ryan/Desktop/WavletVHDL/ip_repo/axi_ip_demo_1.0 [current_project]
set_property ip_output_repo c:/Users/Ryan/Desktop/WavletVHDL/imagecompression/imagecompression.tmp/axi_ip_demo_v4_0_project/axi_ip_demo_v4_0_project.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_vhdl -library xil_defaultlib {
  C:/Users/Ryan/Desktop/WavletVHDL/ip_repo/axi_ip_demo_1.0/src/Controller.vhd
  C:/Users/Ryan/Desktop/WavletVHDL/ip_repo/axi_ip_demo_1.0/hdl/axi_ip_demo_v1_0_S00_AXI.vhd
  C:/Users/Ryan/Desktop/WavletVHDL/ip_repo/axi_ip_demo_1.0/src/bram.vhd
  C:/Users/Ryan/Desktop/WavletVHDL/ip_repo/axi_ip_demo_1.0/src/quantize.vhd
  C:/Users/Ryan/Desktop/WavletVHDL/ip_repo/axi_ip_demo_1.0/hdl/axi_ip_demo_v1_0.vhd
}
read_ip -quiet C:/Users/Ryan/Desktop/WavletVHDL/ip_repo/axi_ip_demo_1.0/src/floating_point_0_1/floating_point_0.xci
set_property used_in_implementation false [get_files -all c:/Users/Ryan/Desktop/WavletVHDL/ip_repo/axi_ip_demo_1.0/src/floating_point_0_1/floating_point_0_ooc.xdc]
set_property is_locked true [get_files C:/Users/Ryan/Desktop/WavletVHDL/ip_repo/axi_ip_demo_1.0/src/floating_point_0_1/floating_point_0.xci]

read_ip -quiet C:/Users/Ryan/Desktop/WavletVHDL/ip_repo/axi_ip_demo_1.0/src/floating_point_add_1/floating_point_add.xci
set_property used_in_implementation false [get_files -all c:/Users/Ryan/Desktop/WavletVHDL/ip_repo/axi_ip_demo_1.0/src/floating_point_add_1/floating_point_add_ooc.xdc]
set_property is_locked true [get_files C:/Users/Ryan/Desktop/WavletVHDL/ip_repo/axi_ip_demo_1.0/src/floating_point_add_1/floating_point_add.xci]

read_ip -quiet C:/Users/Ryan/Desktop/WavletVHDL/ip_repo/axi_ip_demo_1.0/src/floating_point_1_1/floating_point_1.xci
set_property used_in_implementation false [get_files -all c:/Users/Ryan/Desktop/WavletVHDL/ip_repo/axi_ip_demo_1.0/src/floating_point_1_1/floating_point_1_ooc.xdc]
set_property is_locked true [get_files C:/Users/Ryan/Desktop/WavletVHDL/ip_repo/axi_ip_demo_1.0/src/floating_point_1_1/floating_point_1.xci]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}

synth_design -top axi_ip_demo_v1_0 -part xc7z020clg484-1


write_checkpoint -force -noxdef axi_ip_demo_v1_0.dcp

catch { report_utilization -file axi_ip_demo_v1_0_utilization_synth.rpt -pb axi_ip_demo_v1_0_utilization_synth.pb }
