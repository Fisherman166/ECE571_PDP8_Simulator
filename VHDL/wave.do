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
add wave -noupdate -divider -height 25 TEST
add wave -noupdate -obj -radix octal -radixshowbase 0 /testbenchvhdl/line__181/branch_line
add wave -noupdate -radix octal -radixshowbase 0 /testbenchvhdl/line__181/branch_flag
add wave -noupdate -radix octal -radixshowbase 0 /testbenchvhdl/line__181/cond_flag
add wave -noupdate -radix octal -radixshowbase 0 /testbenchvhdl/line__181/jms_flag
add wave -noupdate -radix octal -radixshowbase 0 /testbenchvhdl/line__181/pc_temp
add wave -noupdate -radix octal -radixshowbase 0 /testbenchvhdl/line__181/pc
add wave -noupdate -radix octal -radixshowbase 0 /testbenchvhdl/line__181/pcp1
add wave -noupdate -radix octal -radixshowbase 0 /testbenchvhdl/line__181/pcp2
add wave -noupdate -radix octal -radixshowbase 0 /testbenchvhdl/line__181/ea
add wave -noupdate -radix octal -radixshowbase 0 /testbenchvhdl/line__181/eap1
add wave -noupdate -radix octal -radixshowbase 0 /testbenchvhdl/line__181/opcode
add wave -noupdate /testbenchvhdl/mem_ready
add wave -noupdate /testbenchvhdl/micro_cond_branch
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {402153905 ps} 0}
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
WaveRestoreZoom {401094609 ps} {403145391 ps}
