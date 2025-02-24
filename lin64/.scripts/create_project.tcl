##################################################################################
#                                 _             _
#                                | |_  ___ _ __(_)__ _
#                                | ' \/ -_) '_ \ / _` |
#                                |_||_\___| .__/_\__,_|
#                                         |_|
#
##################################################################################
#
# Company: HEPIA // HES-SO
# Author: Laurent Gantel <laurent.gantel@hesge.ch>
#
# Project Name: pong
# Target Device: digilentinc.com:nexys_video:part0:1.2 xc7a200tsbg484-1
# Tool version: 2024.1
# Description: TCL script for re-creating Vivado project 'pong'
#
# Last update: 2024-12-17
#
##################################################################################

#----------------------------------------------------------------
# Include files
#----------------------------------------------------------------

source utils.tcl

#----------------------------------------------------------------
# Setup configuration
#----------------------------------------------------------------

set PRJ_DIR ".."
set prj_name "pong"
set board_name "digilentinc.com:nexys_video:part0:1.2"
set part_name "xc7a200tsbg484-1"

# Set the original project directory path for adding/importing sources in the new project
set src_dir "${PRJ_DIR}/../src"

#----------------------------------------------------------------
# Create a variable to store the start time
#----------------------------------------------------------------

set start_time [clock format [clock seconds] -format {%b. %d, %Y %I:%M:%S %p}]

#----------------------------------------------------------------
# Create the project
#----------------------------------------------------------------

create_project $prj_name ${PRJ_DIR}/$prj_name -part $part_name
#set_property board_part $board_name [current_project]
set_property target_language VHDL [current_project]
print_status "Create project" "OK"

#----------------------------------------------------------------
# Add project sources
#----------------------------------------------------------------

# Get HDL source files directory
set hdl_src_dir "${src_dir}/hdl"
set sim_src_dir "${src_dir}/sim"

# Add HDL source files
set vhdl_src_file_list [findFiles $hdl_src_dir *.vhd]

if {$vhdl_src_file_list != ""} {
  add_files -norecurse $vhdl_src_file_list
} else {
  print_status "No sources to be added" "WARNING"
}

# Set VHDL version (VHDL, VHDL 2008, or VHDL 2019)
foreach j $vhdl_src_file_list {
  set_property file_type {VHDL 2008} [get_files $j]
  print_status "VHDL mode 2008 configured for the file $j" "OK"
}
print_status "Add project sources" "OK"

#----------------------------------------------------------------
# Launch the TCL script to generate the IPI design
#----------------------------------------------------------------
source $src_dir/ipi_tcl/${prj_name}_ipi.tcl
print_status "Add IPI design" "OK"

#----------------------------------------------------------------
# Set the top level design
#----------------------------------------------------------------

set_property top $prj_name [current_fileset]
update_compile_order -fileset sources_1

#----------------------------------------------------------------
# Add simulation sources
#----------------------------------------------------------------

set vhdl_sim_file_list [findFiles $sim_src_dir *.vhd]

if {$vhdl_sim_file_list != ""} {
  add_files -fileset sim_1 -norecurse $vhdl_sim_file_list
  update_compile_order -fileset sim_1
} else {
  print_status "No simulation sources to be added" "WARNING"
}

foreach j $vhdl_sim_file_list {
  set_property file_type {VHDL 2008} [get_files $j]
  print_status "VHDL mode 2008 configured for the file $j" "OK"
}

# Add simulation packages sources
#set_property library sim_axi [get_files  $sim_src_dir/sim_axi_rd_pkg.vhd]
#set_property library sim_axi [get_files  $sim_src_dir/sim_axi_wr_pkg.vhd]
update_compile_order -fileset sim_1

print_status "Add simulation sources" "OK"

#----------------------------------------------------------------
# Set the top level simulation file
#----------------------------------------------------------------

set_property top $prj_name [get_filesets sim_1]
update_compile_order -fileset sim_1

#----------------------------------------------------------------
# Set the completion time
#----------------------------------------------------------------

set end_time [clock format [clock seconds] -format {%b. %d, %Y %I:%M:%S %p}]

#----------------------------------------------------------------
# Display the start and end time to the screen
#----------------------------------------------------------------

puts $start_time
puts $end_time

exit
