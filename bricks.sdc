## Generated SDC file "bricks.sdc"

## Copyright (C) 1991-2013 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition"

## DATE    "Tue Jun 06 10:49:06 2017"

##
## DEVICE  "EP2C70F672C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clock:u_c|clk_out_t} -period 100.000 -waveform { 0.000 50.000 } [get_registers {clock:u_c|clk_out_t}]
create_clock -name {state_control:u_state|clock:u_c|clk_out_t} -period 1000.000 -waveform { 0.000 500.000 } [get_registers { state_control:u_state|clock:u_c|clk_out_t }]
create_clock -name {clk_100m} -period 10.000 -waveform { 0.000 5.000 } [get_ports {clk_100m}]
create_clock -name {keyboard_decoder:u_keyboard|KeyboardReader:kb|dataok} -period 1000.000 -waveform { 0.000 500.000 } [get_registers { keyboard_decoder:u_keyboard|KeyboardReader:kb|dataok }]
create_clock -name {state_control:u_state|buff_control:u_buff|buff_time_control:u_btc|clock:u_c|clk_out_t} -period 1000.000 -waveform { 0.000 500.000 } [get_registers { state_control:u_state|buff_control:u_buff|buff_time_control:u_btc|clock:u_c|clk_out_t }]
create_clock -name {state_control:u_state|buff_control:u_buff|card_generator:\gen_card_gens:1:u_cg|clock:u_c|clk_out_t} -period 1000.000 -waveform { 0.000 500.000 } [get_registers { state_control:u_state|buff_control:u_buff|card_generator:\gen_card_gens:1:u_cg|clock:u_c|clk_out_t }]
create_clock -name {state_control:u_state|buff_control:u_buff|card_generator:\gen_card_gens:0:u_cg|clock:u_c|clk_out_t} -period 1000.000 -waveform { 0.000 500.000 } [get_registers { state_control:u_state|buff_control:u_buff|card_generator:\gen_card_gens:0:u_cg|clock:u_c|clk_out_t }]
create_clock -name {state_control:u_state|buff_control:u_buff|card_generator:\gen_card_gens:2:u_cg|clock:u_c|clk_out_t} -period 1000.000 -waveform { 0.000 500.000 } [get_registers { state_control:u_state|buff_control:u_buff|card_generator:\gen_card_gens:2:u_cg|clock:u_c|clk_out_t }]
create_clock -name {display_control:u_display|img_reader:u2|dataok} -period 40.000 -waveform { 0.000 20.000 } [get_registers {display_control:u_display|img_reader:u2|dataok}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

