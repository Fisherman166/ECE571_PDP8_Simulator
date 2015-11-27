
vlib work

################################################################################
## Source Files
################################################################################

.main clear

vlog -sv -mfcu Controller.sv CPU.sv Multiply.sv Divide.sv EAE.sv Front_Panel.sv memory_controller.sv micro_instruction_decoder.sv Top.sv synth_tb.sv

vsim synth_tb

onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider TOP
add wave -noupdate -radix octal -radixshowbase 0 /synth_tb/clk
add wave -noupdate -radix octal -radixshowbase 0 /synth_tb/btnCpuReset
add wave -noupdate -radix binary -radixshowbase 0 /synth_tb/led
add wave -noupdate -radix binary -radixshowbase 0 /synth_tb/sw
add wave -noupdate -radix octal -radixshowbase 0 /synth_tb/TOP0/bus/swreg
add wave -noupdate -radix octal -radixshowbase 0 /synth_tb/Display_Select
add wave -noupdate -radix octal -radixshowbase 0 /synth_tb/Step
add wave -noupdate -radix octal -radixshowbase 0 /synth_tb/Deposit
add wave -noupdate -radix octal -radixshowbase 0 /synth_tb/Load_PC
add wave -noupdate -radix octal -radixshowbase 0 /synth_tb/Load_AC
add wave -noupdate -divider MEMORY
add wave -noupdate -color White -radix octal -radixshowbase 0 /synth_tb/TOP0/bus/AD_ctrl
add wave -noupdate -color White -radix octal -radixshowbase 0 /synth_tb/TOP0/bus/address
add wave -noupdate -color Cyan -radix octal -radixshowbase 0 /synth_tb/TOP0/bus/WD_ctrl
add wave -noupdate -color Cyan -radix octal -radixshowbase 0 /synth_tb/TOP0/bus/write_enable
add wave -noupdate -color Cyan -radix octal -radixshowbase 0 /synth_tb/TOP0/bus/write_data
add wave -noupdate -color Yellow -radix octal -radixshowbase 0 /synth_tb/TOP0/bus/read_enable
add wave -noupdate -color Yellow -radix octal -radixshowbase 0 /synth_tb/TOP0/bus/read_data
add wave -noupdate -color Yellow -radix octal -radixshowbase 0 /synth_tb/TOP0/bus/mem_finished
add wave -noupdate -divider CPU
add wave -noupdate -color White /synth_tb/TOP0/FSM0/Curr_State
add wave -noupdate -color White -radix octal /synth_tb/TOP0/bus/CPU_idle
add wave -noupdate -color Cyan -radix octal -radixshowbase 0 /synth_tb/TOP0/bus/AC_ctrl
add wave -noupdate -color Cyan -radix octal -radixshowbase 0 /synth_tb/TOP0/bus/curr_reg.ac
add wave -noupdate -color Blue -radix octal -radixshowbase 0 /synth_tb/TOP0/bus/LK_ctrl
add wave -noupdate -color Blue -radix octal -radixshowbase 0 /synth_tb/TOP0/bus/curr_reg.lk
add wave -noupdate -color {Cornflower Blue} -radix octal -radixshowbase 0 /synth_tb/TOP0/bus/EA_ctrl
add wave -noupdate -color {Cornflower Blue} -radix octal -childformat {{{[11]} -radix octal} {{[10]} -radix octal} {{[9]} -radix octal} {{[8]} -radix octal} {{[7]} -radix octal} {{[6]} -radix octal} {{[5]} -radix octal} {{[4]} -radix octal} {{[3]} -radix octal} {{[2]} -radix octal} {{[1]} -radix octal} {{[0]} -radix octal}} -radixshowbase 0 -subitemconfig {{/synth_tb/TOP0/bus/curr_reg.ea[11]} {-color {Cornflower Blue} -radix octal -radixshowbase 0} {/synth_tb/TOP0/bus/curr_reg.ea[10]} {-color {Cornflower Blue} -radix octal -radixshowbase 0} {/synth_tb/TOP0/bus/curr_reg.ea[9]} {-color {Cornflower Blue} -radix octal -radixshowbase 0} {/synth_tb/TOP0/bus/curr_reg.ea[8]} {-color {Cornflower Blue} -radix octal -radixshowbase 0} {/synth_tb/TOP0/bus/curr_reg.ea[7]} {-color {Cornflower Blue} -radix octal -radixshowbase 0} {/synth_tb/TOP0/bus/curr_reg.ea[6]} {-color {Cornflower Blue} -radix octal -radixshowbase 0} {/synth_tb/TOP0/bus/curr_reg.ea[5]} {-color {Cornflower Blue} -radix octal -radixshowbase 0} {/synth_tb/TOP0/bus/curr_reg.ea[4]} {-color {Cornflower Blue} -radix octal -radixshowbase 0} {/synth_tb/TOP0/bus/curr_reg.ea[3]} {-color {Cornflower Blue} -radix octal -radixshowbase 0} {/synth_tb/TOP0/bus/curr_reg.ea[2]} {-color {Cornflower Blue} -radix octal -radixshowbase 0} {/synth_tb/TOP0/bus/curr_reg.ea[1]} {-color {Cornflower Blue} -radix octal -radixshowbase 0} {/synth_tb/TOP0/bus/curr_reg.ea[0]} {-color {Cornflower Blue} -radix octal -radixshowbase 0}} /synth_tb/TOP0/bus/curr_reg.ea
add wave -noupdate -color Gold -radix octal -radixshowbase 0 /synth_tb/TOP0/bus/IR_ctrl
add wave -noupdate -color Gold -radix octal -radixshowbase 0 /synth_tb/TOP0/bus/curr_reg.ir
add wave -noupdate -color Magenta -radix octal -radixshowbase 0 /synth_tb/TOP0/bus/MQ_ctrl
add wave -noupdate -color Magenta -radix octal -radixshowbase 0 /synth_tb/TOP0/bus/curr_reg.mq
add wave -noupdate -color Gray30 -radix octal -radixshowbase 0 /synth_tb/TOP0/bus/MB_ctrl
add wave -noupdate -color Gray30 -radix octal -radixshowbase 0 /synth_tb/TOP0/bus/curr_reg.mb
add wave -noupdate -color Yellow -radix octal -radixshowbase 0 /synth_tb/TOP0/bus/PC_ctrl
add wave -noupdate -color Yellow -radix octal -radixshowbase 0 /synth_tb/TOP0/bus/curr_reg.pc
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {982 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 356
configure wave -valuecolwidth 280
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
configure wave -timelineunits ns
update
WaveRestoreZoom {873 ns} {1195 ns}


run 10 ms
