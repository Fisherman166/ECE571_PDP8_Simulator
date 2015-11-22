
vlib work

################################################################################
## Source Files
################################################################################

.main clear



vlog -mfcu Controller.sv CPU.sv Multiply.sv Divide.sv EAE.sv Front_Panel.sv memory_controller.sv micro_instruction_decoder.sv TestBench001.sv Top.sv

vsim TestBench001

onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label Clock -radix binary -radixshowbase 0 /TestBench001/clk
add wave -noupdate -label Reset -radix binary -radixshowbase 0 /TestBench001/btnCpuReset
add wave -noupdate -label LED -radix binary -radixshowbase 0 /TestBench001/led
add wave -noupdate -label SWITCHES -radix binary -radixshowbase 0 /TestBench001/sw
add wave -noupdate -label Registers -radix octal -childformat {{/TestBench001/TOP0/bus/curr_reg.ac -radix octal} {/TestBench001/TOP0/bus/curr_reg.lk -radix octal} {/TestBench001/TOP0/bus/curr_reg.ir -radix octal} {/TestBench001/TOP0/bus/curr_reg.mq -radix octal} {/TestBench001/TOP0/bus/curr_reg.pc -radix octal} {/TestBench001/TOP0/bus/curr_reg.mb -radix octal} {/TestBench001/TOP0/bus/curr_reg.ea -radix octal}} -radixshowbase 0 -expand -subitemconfig {/TestBench001/TOP0/bus/curr_reg.ac {-color White -height 15 -radix octal -radixshowbase 0} /TestBench001/TOP0/bus/curr_reg.lk {-color {Cornflower Blue} -height 15 -radix octal -radixshowbase 0} /TestBench001/TOP0/bus/curr_reg.ir {-color Orange -height 15 -radix octal -radixshowbase 0} /TestBench001/TOP0/bus/curr_reg.mq {-color Turquoise -height 15 -radix octal -radixshowbase 0} /TestBench001/TOP0/bus/curr_reg.pc {-color Blue -height 15 -radix octal -radixshowbase 0} /TestBench001/TOP0/bus/curr_reg.mb {-color Violet -height 15 -radix octal -radixshowbase 0} /TestBench001/TOP0/bus/curr_reg.ea {-color Salmon -height 15 -radix octal -radixshowbase 0}} /TestBench001/TOP0/bus/curr_reg
add wave -noupdate -label Curr_State /TestBench001/TOP0/FSM0/Curr_State
add wave -noupdate /TestBench001/TOP0/bus/AC_ctrl
add wave -noupdate /TestBench001/TOP0/bus/LK_ctrl
add wave -noupdate /TestBench001/TOP0/bus/MQ_ctrl
add wave -noupdate /TestBench001/TOP0/bus/PC_ctrl
add wave -noupdate /TestBench001/TOP0/bus/IR_ctrl
add wave -noupdate /TestBench001/TOP0/bus/EA_ctrl
add wave -noupdate /TestBench001/TOP0/bus/MB_ctrl
add wave -noupdate /TestBench001/TOP0/bus/WD_ctrl
add wave -noupdate /TestBench001/TOP0/bus/AD_ctrl
add wave -noupdate /TestBench001/TOP0/bus/DO_ctrl
add wave -noupdate /TestBench001/TOP0/bus/DT_ctrl
add wave -noupdate -divider -height 25 MEMORY
add wave -noupdate -color White -radix octal -radixshowbase 0 /TestBench001/TOP0/bus/address
add wave -noupdate -color {Cornflower Blue} -radix octal -radixshowbase 0 /TestBench001/TOP0/bus/read_enable
add wave -noupdate -color {Cornflower Blue} -radix octal -radixshowbase 0 /TestBench001/TOP0/bus/read_data
add wave -noupdate -color Gold -radix octal -radixshowbase 0 /TestBench001/TOP0/bus/write_data
add wave -noupdate -color Gold -radix octal -radixshowbase 0 /TestBench001/TOP0/bus/write_enable
add wave -noupdate -color Cyan -radix octal -radixshowbase 0 /TestBench001/TOP0/bus/mem_finished
add wave -noupdate -color Cyan -radix octal -radixshowbase 0 /TestBench001/TOP0/bus/read_type
add wave -noupdate -divider -height 25 {BRANCH TRACE}
add wave -noupdate /TestBench001/CPU_State
add wave -noupdate /TestBench001/pc_temp
add wave -noupdate /TestBench001/cond_skip_flag
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2541195 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 261
configure wave -valuecolwidth 100
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
WaveRestoreZoom {2541049 ns} {2541371 ns}

run 10 ms
