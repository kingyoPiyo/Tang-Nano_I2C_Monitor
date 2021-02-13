//Copyright (C)2014-2021 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.7 Beta
//Created Time: 2021-02-13 15:13:02
create_clock -name mco -period 41.667 -waveform {0 20.834} [get_ports {mco}]
set_false_path -from [get_ports {i2c_scl}] 
set_false_path -from [get_ports {i2c_sda}] 
set_false_path -from [get_ports {uart_rx}] 
set_false_path -from [get_ports {btn_a}] 
set_false_path -from [get_ports {btn_b}] 
set_false_path -to [get_ports {led_r}] 
set_false_path -to [get_ports {led_g}] 
set_false_path -to [get_ports {led_b}] 
set_false_path -to [get_ports {uart_tx}] 
