
vlib work

################################################################################
## Source Files
################################################################################

.main clear


vlog Controller.sv
vlog CPU.sv
vlog +define+CPU_DEF_PKG Multiply.sv
vlog +define+CPU_DEF_PKG Divide.sv
vlog +define+CPU_DEF_PKG EAE.sv
vlog +define+CPU_DEF_PKG Front_Panel.sv
vlog +define+CPU_DEF_PKG memory_controller.sv
vlog +define+CPU_DEF_PKG micro_instruction_decoder.sv
vlog +define+CPU_DEF_PKG TestBench001.sv
vlog +define+CPU_DEF_PKG Top.sv



vsim TestBench001

onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestBench001/clk
add wave -noupdate /TestBench001/btnCpuReset
add wave -noupdate -radix binary -radixshowbase 0 /TestBench001/led
add wave -noupdate -radix octal -radixshowbase 0 /TestBench001/sw
add wave -noupdate -radix binary -radixshowbase 0 /TestBench001/Display_Select
add wave -noupdate -radix binary -radixshowbase 0 /TestBench001/Step
add wave -noupdate -radix binary -radixshowbase 0 /TestBench001/Deposit
add wave -noupdate -radix binary -radixshowbase 0 /TestBench001/Load_PC
add wave -noupdate -radix binary -radixshowbase 0 /TestBench001/Load_AC
add wave -noupdate -radix unsigned -radixshowbase 0 /TestBench001/m
add wave -noupdate -radix octal -childformat {{/TestBench001/TOP0/CPU0/curr_reg.ac -radix octal} {/TestBench001/TOP0/CPU0/curr_reg.lk -radix octal} {/TestBench001/TOP0/CPU0/curr_reg.ir -radix octal} {/TestBench001/TOP0/CPU0/curr_reg.mq -radix octal} {/TestBench001/TOP0/CPU0/curr_reg.pc -radix octal} {/TestBench001/TOP0/CPU0/curr_reg.mb -radix octal} {/TestBench001/TOP0/CPU0/curr_reg.ea -radix octal}} -radixshowbase 0 -expand -subitemconfig {/TestBench001/TOP0/CPU0/curr_reg.ac {-color Gold -height 15 -radix octal -radixshowbase 0} /TestBench001/TOP0/CPU0/curr_reg.lk {-height 15 -radix octal -radixshowbase 0} /TestBench001/TOP0/CPU0/curr_reg.ir {-color {Cornflower Blue} -height 15 -radix octal -radixshowbase 0} /TestBench001/TOP0/CPU0/curr_reg.mq {-height 15 -radix octal -radixshowbase 0} /TestBench001/TOP0/CPU0/curr_reg.pc {-height 15 -radix octal -radixshowbase 0} /TestBench001/TOP0/CPU0/curr_reg.mb {-height 15 -radix octal -radixshowbase 0} /TestBench001/TOP0/CPU0/curr_reg.ea {-height 15 -radix octal -radixshowbase 0}} /TestBench001/TOP0/CPU0/curr_reg
add wave -noupdate -radix octal -radixshowbase 0 /TestBench001/TOP0/CPU0/fp/dispout
add wave -noupdate /TestBench001/TOP0/CPU0/SM0/Curr_State
add wave -noupdate /TestBench001/TOP0/CPU0/fsm/AC_ctrl
add wave -noupdate /TestBench001/TOP0/CPU0/fsm/LK_ctrl
add wave -noupdate /TestBench001/TOP0/CPU0/fsm/MQ_ctrl
add wave -noupdate /TestBench001/TOP0/CPU0/fsm/PC_ctrl
add wave -noupdate /TestBench001/TOP0/CPU0/fsm/IR_ctrl
add wave -noupdate /TestBench001/TOP0/CPU0/fsm/EA_ctrl
add wave -noupdate /TestBench001/TOP0/CPU0/fsm/MB_ctrl
add wave -noupdate /TestBench001/TOP0/CPU0/fsm/WD_ctrl
add wave -noupdate /TestBench001/TOP0/CPU0/fsm/AD_ctrl
add wave -noupdate /TestBench001/TOP0/CPU0/fsm/DO_ctrl
add wave -noupdate /TestBench001/TOP0/CPU0/fsm/DT_ctrl
add wave -noupdate -radix octal -radixshowbase 0 /TestBench001/TOP0/CPU0/mem/read_data
add wave -noupdate -radix octal -radixshowbase 0 /TestBench001/TOP0/CPU0/mem/write_data
add wave -noupdate -radix octal -radixshowbase 0 /TestBench001/TOP0/CPU0/mem/address
add wave -noupdate -radix binary -radixshowbase 0 /TestBench001/TOP0/CPU0/mem/mem_finished
add wave -noupdate -radix binary -radixshowbase 0 /TestBench001/TOP0/CPU0/mem/write_enable
add wave -noupdate -radix binary -radixshowbase 0 /TestBench001/TOP0/CPU0/mem/read_enable
add wave -noupdate -radix octal -radixshowbase 0 /TestBench001/TOP0/CPU0/MIC0/i_reg
add wave -noupdate -radix octal -radixshowbase 0 /TestBench001/TOP0/CPU0/MIC0/ac_reg
add wave -noupdate -radix binary -radixshowbase 0 /TestBench001/TOP0/CPU0/MIC0/l_reg
add wave -noupdate -radix octal -radixshowbase 0 /TestBench001/TOP0/CPU0/MIC0/ac_micro
add wave -noupdate -radix binary -radixshowbase 0 /TestBench001/TOP0/CPU0/MIC0/l_micro
add wave -noupdate -radix binary -radixshowbase 0 /TestBench001/TOP0/CPU0/MIC0/skip
add wave -noupdate -radix binary -radixshowbase 0 /TestBench001/TOP0/CPU0/MIC0/micro_g1
add wave -noupdate -radix binary -radixshowbase 0 /TestBench001/TOP0/CPU0/MIC0/micro_g2
add wave -noupdate -radix binary -radixshowbase 0 /TestBench001/TOP0/CPU0/MIC0/micro_g3
add wave -noupdate -radix binary -childformat {{/TestBench001/TOP0/CPU0/MIC0/group1_instruction_bits.CLA -radix binary} {/TestBench001/TOP0/CPU0/MIC0/group1_instruction_bits.CLL -radix binary} {/TestBench001/TOP0/CPU0/MIC0/group1_instruction_bits.CMA -radix binary} {/TestBench001/TOP0/CPU0/MIC0/group1_instruction_bits.CML -radix binary} {/TestBench001/TOP0/CPU0/MIC0/group1_instruction_bits.RAR -radix binary} {/TestBench001/TOP0/CPU0/MIC0/group1_instruction_bits.RAL -radix binary} {/TestBench001/TOP0/CPU0/MIC0/group1_instruction_bits.BSW -radix binary} {/TestBench001/TOP0/CPU0/MIC0/group1_instruction_bits.IAC -radix binary}} -radixshowbase 0 -subitemconfig {/TestBench001/TOP0/CPU0/MIC0/group1_instruction_bits.CLA {-height 15 -radix binary -radixshowbase 0} /TestBench001/TOP0/CPU0/MIC0/group1_instruction_bits.CLL {-height 15 -radix binary -radixshowbase 0} /TestBench001/TOP0/CPU0/MIC0/group1_instruction_bits.CMA {-height 15 -radix binary -radixshowbase 0} /TestBench001/TOP0/CPU0/MIC0/group1_instruction_bits.CML {-height 15 -radix binary -radixshowbase 0} /TestBench001/TOP0/CPU0/MIC0/group1_instruction_bits.RAR {-height 15 -radix binary -radixshowbase 0} /TestBench001/TOP0/CPU0/MIC0/group1_instruction_bits.RAL {-height 15 -radix binary -radixshowbase 0} /TestBench001/TOP0/CPU0/MIC0/group1_instruction_bits.BSW {-height 15 -radix binary -radixshowbase 0} /TestBench001/TOP0/CPU0/MIC0/group1_instruction_bits.IAC {-height 15 -radix binary -radixshowbase 0}} /TestBench001/TOP0/CPU0/MIC0/group1_instruction_bits
add wave -noupdate -radix binary -radixshowbase 0 /TestBench001/TOP0/CPU0/MIC0/group2_instruction_bits
add wave -noupdate -radix binary -radixshowbase 0 /TestBench001/TOP0/CPU0/MIC0/link_and_accumulator
add wave -noupdate -radix binary -radixshowbase 0 /TestBench001/TOP0/CPU0/MIC0/group_select
add wave -noupdate -radix binary -radixshowbase 0 /TestBench001/TOP0/CPU0/MIC0/group1_block3_select
add wave -noupdate -radix binary -radixshowbase 0 /TestBench001/TOP0/CPU0/MIC0/group2_or_select
add wave -noupdate -radix binary -radixshowbase 0 /TestBench001/TOP0/CPU0/MIC0/group2_and_select
add wave -noupdate -radix binary -radixshowbase 0 /TestBench001/TOP0/CPU0/MIC0/skip_or
add wave -noupdate -radix binary -radixshowbase 0 /TestBench001/TOP0/CPU0/MIC0/skip_and
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2541975 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 391
configure wave -valuecolwidth 194
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
WaveRestoreZoom {2541917 ns} {2542239 ns}


run 10 ms
