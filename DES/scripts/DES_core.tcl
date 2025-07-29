# =============================================
# Design Compiler Synthesis Script for Counter
# =============================================

# Set technology libraries
set search_path [list . /home/Khach103/Documents/me_labs/liberty]
set link_library [list \
  /home/Khach103/Documents/me_labs/liberty/saed14rvt_ff0p88v125c.db \
    /home/Khach103/Documents/me_labs/liberty/saed14rvt_ss0p72vm40c.db \
   /home/Khach103/Documents/me_labs/liberty/saed14rvt_tt0p8v25c.db \
]
set target_library $link_library
set symbol_library ""


# Define working library
define_design_lib WORK -path ./work


# Read and analyze RTL files

analyze -library WORK -format verilog [list \
    /home/Khach103/Documents/me_labs/DES/rtl/DES_core.v \
    /home/Khach103/Documents/me_labs/DES/rtl/DES_Counter.v \
    /home/Khach103/Documents/me_labs/DES/rtl/PC1.v \
    /home/Khach103/Documents/me_labs/DES/rtl/PC2.v \
    /home/Khach103/Documents/me_labs/DES/rtl/IP.v \
    /home/Khach103/Documents/me_labs/DES/rtl/E_Permutation.v \
    /home/Khach103/Documents/me_labs/DES/rtl/S_Box.v \
    /home/Khach103/Documents/me_labs/DES/rtl/P_Permutation.v \
    /home/Khach103/Documents/me_labs/DES/rtl/Inverse_IP.v   \
    /home/Khach103/Documents/me_labs/DES/rtl/DES_DecipherAndKey_Controller.v \
    /home/Khach103/Documents/me_labs/DES/rtl/DES_Encipher_Controller.v \
]

elaborate DES_core -architecture verilog -library WORK
read_sdc /home/Khach103/Documents/me_labs/DES/sdc/DES_core.sdc

set_operating_conditions -min ss0p72vm40c -max ff0p88v125c

set_svf /home/Khach103/Documents/me_labs/DES/outputs/DES_core_formality.svf

# Compile
#compile_ultra -retime
compile
check_design

# Reports

report_area > /home/Khach103/Documents/me_labs/DES/reports/area.rpt
report_timing > /home/Khach103/Documents/me_labs/DES/reports/timing.rpt
report_power > /home/Khach103/Documents/me_labs/DES/reports/power.rpt
report_qor > /home/Khach103/Documents/me_labs/DES/reports/qor.rpt
# Export netlist

write -format verilog -hierarchy -output /home/Khach103/Documents/me_labs/DES/outputs/Des_core_synth.v
set_svf -off
write_sdf /home/Khach103/Documents/me_labs/DES/outputs/DES_core_synth.sdf
# === Formality Preparation ===

# Export DDC (optional)
write -format ddc -hierarchy -output /home/Khach103/Documents/me_labs/DES/outputs/DES_core_synth.ddc

# Export SDC constraints (optional but recommended)
write_sdc /home/Khach103/Documents/me_labs/DES/outputs/DES_core_synth.sdc

# Export environment script for Formality
write_script -output /home/Khach103/Documents/me_labs/DES/outputs/DES_core_env.tcl

# Turn off SVF recording
set_svf -off

# Optionally start GUI
gui_start
