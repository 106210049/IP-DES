create_clock -name clk -period 1.0 [get_ports clk]

# ========================== INPUT DELAYS ==========================

set_input_delay 0.3 -clock clk [get_ports clk]
set_input_delay 0.3 -clock clk [get_ports rst_n]
set_input_delay 0.3 -clock clk [get_ports des_encipher_en]
set_input_delay 0.3 -clock clk [get_ports des_encipher_en]
set_input_delay 0.3 -clock clk [get_ports des_data]
set_input_delay 0.3 -clock clk [get_ports des_key_in]


# ========================== OUTPUT DELAYS ==========================

set_output_delay 0.3 -clock clk [get_ports desc_ready]
set_output_delay 0.3 -clock clk [get_ports desc_result]


# ========================== ASYNC RESET ==========================


set_case_analysis 0 [get_ports rst_n]
set_false_path -from [get_ports rst_n]
# ========================== DESIGN RULES ==========================

set_clock_transition 0.2 [get_ports clk]
#set_clock_transition 0.2[get_ports rst_n]
#set_clock_transition 0.2[get_ports des_encipher_en]
#set_clock_transition 0.2[get_ports des_encipher_en]
#set_clock_transition 0.2[get_ports des_data]
#set_clock_transition 0.2[get_ports des_key_in]

set_max_transition 0.1 [get_ports clk]
set_max_transition 0.2 [get_ports rst_n]
set_max_transition 0.2 [get_ports des_data]


set_max_fanout 16 [current_design]
set_max_capacitance 8 [current_design]


set_clock_uncertainty 0.175 [get_clocks clk]

