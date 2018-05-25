@echo off
set xv_path=C:\\Xilinx\\Vivado\\2017.2\\bin
call %xv_path%/xsim axi_ip_demo_v1_0_tb_behav -key {Behavioral:sim_1:Functional:axi_ip_demo_v1_0_tb} -tclbatch axi_ip_demo_v1_0_tb.tcl -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
