.main clear

vlib work

################################################################################
## Source Files
################################################################################

vcom Multiply.vhd
vcom Divide.vhd
vcom EAE.vhd
vcom Adder.vhd
vcom Adder12.vhd
vcom Micro.vhd
vcom State_Machine.vhd
vcom CPU.vhd                      
vcom ROM.vhd
vcom RAM.vhd
vcom Memory.vhd                       
vcom front_panel.vhd                                      
vcom Top_VHDL.vhd
vcom TestBenchVHDL.vhd




vsim -g period=5ns -g data_file="basic1.txt" -t 1ps TestBenchVHDL

onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix octal /testbenchvhdl/clk
add wave -noupdate -radix binary -radixshowbase 0 /testbenchvhdl/led
add wave -noupdate -radix octal -radixshowbase 0 /testbenchvhdl/an
add wave -noupdate -radix octal -radixshowbase 0 /testbenchvhdl/seg
add wave -noupdate -radix octal -radixshowbase 0 /testbenchvhdl/dp
add wave -noupdate -radix binary -radixshowbase 0 /testbenchvhdl/sw
add wave -noupdate -radix octal -radixshowbase 0 /testbenchvhdl/Display_Select
add wave -noupdate -radix octal -radixshowbase 0 /testbenchvhdl/Step
add wave -noupdate -radix octal -radixshowbase 0 /testbenchvhdl/Deposit
add wave -noupdate -radix octal -radixshowbase 0 /testbenchvhdl/Load_PC
add wave -noupdate -radix octal -radixshowbase 0 /testbenchvhdl/Load_AC
add wave -noupdate -radix octal -radixshowbase 0 /testbenchvhdl/line_num
add wave -noupdate -radix octal -radixshowbase 0 /testbenchvhdl/TOP1/CPU0/swreg
add wave -noupdate -radix octal -radixshowbase 0 /testbenchvhdl/TOP1/CPU0/halt
add wave -noupdate -divider -height 25 REGISTERS
add wave -noupdate -color White -radix octal -radixshowbase 0 /testbenchvhdl/TOP1/CPU0/ac_reg
add wave -noupdate -color {Cornflower Blue} -radix octal -radixshowbase 0 /testbenchvhdl/TOP1/CPU0/l_reg
add wave -noupdate -color Orange -radix octal -radixshowbase 0 /testbenchvhdl/TOP1/CPU0/i_reg
add wave -noupdate -color Cyan -radix octal -radixshowbase 0 /testbenchvhdl/TOP1/CPU0/mq_reg
add wave -noupdate -color Blue -radix octal -radixshowbase 0 /testbenchvhdl/TOP1/CPU0/pc_reg
add wave -noupdate -color Salmon -radix octal -radixshowbase 0 /testbenchvhdl/TOP1/CPU0/temp_reg
add wave -noupdate -color Gray80 -radix octal -radixshowbase 0 /testbenchvhdl/TOP1/CPU0/ea_reg
add wave -noupdate -divider -height 25 MEMORY
add wave -noupdate -color White -radix octal -radixshowbase 0 /testbenchvhdl/TOP1/CPU0/address
add wave -noupdate -color {Cornflower Blue} -radix octal /testbenchvhdl/TOP1/CPU0/read_enable
add wave -noupdate -color {Cornflower Blue} -radix octal -radixshowbase 0 /testbenchvhdl/TOP1/CPU0/read_data
add wave -noupdate -color Gold -radix octal -radixshowbase 0 /testbenchvhdl/TOP1/CPU0/write_data
add wave -noupdate -color Gold -radix octal /testbenchvhdl/TOP1/CPU0/write_enable
add wave -noupdate -color Cyan -radix octal /testbenchvhdl/TOP1/CPU0/mem_finished
add wave -noupdate -divider -height 25 MICRO
add wave -noupdate -radix octal /testbenchvhdl/TOP1/CPU0/skip
add wave -noupdate -radix octal /testbenchvhdl/TOP1/CPU0/ea_reg_8_to_15
add wave -noupdate -radix octal /testbenchvhdl/TOP1/CPU0/micro_g1
add wave -noupdate -radix octal /testbenchvhdl/TOP1/CPU0/micro_g2
add wave -noupdate -radix octal /testbenchvhdl/TOP1/CPU0/micro_g3
add wave -noupdate -radix octal /testbenchvhdl/TOP1/CPU0/srchange
add wave -noupdate -radix octal /testbenchvhdl/TOP1/CPU0/eae_fin
add wave -noupdate -radix octal /testbenchvhdl/TOP1/CPU0/eae_start
add wave -noupdate -divider -height 25 TEST
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {365325067 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 388
configure wave -valuecolwidth 165
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {1250 ns} {526250 ns}

run
